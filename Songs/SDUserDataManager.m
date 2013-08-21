//
//  MUMusicManager.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDUserDataManager.h"

#import <AVFoundation/AVFoundation.h>

#import "SDMasterPlaylist.h"

#import "iTunes.h"


@interface SDUserDataManager ()

@property BOOL canSave;

@property NSMutableArray* allSongs;
@property NSMutableArray* playlists;

@end

@implementation SDUserDataManager

+ (SDUserDataManager*) sharedMusicManager {
    static SDUserDataManager* sharedMusicManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMusicManager = [[SDUserDataManager alloc] init];
        sharedMusicManager.undoManager = [[NSUndoManager alloc] init];
    });
    return sharedMusicManager;
}

- (NSString*) dataFile {
    NSError *error;
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                  inDomain:NSUserDomainMask
                                                         appropriateForURL:nil
                                                                    create:YES
                                                                     error:&error];
    
    NSURL* dataDirURL = [appSupportDir URLByAppendingPathComponent:@"Songs"];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:dataDirURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    
    return [[dataDirURL URLByAppendingPathComponent:@"data"] path];
}

- (void) loadUserData {
//    NSLog(@"loading");
    
    self.allSongs = [NSMutableArray array];
    self.playlists = [NSMutableArray array];
    
    NSData* savedData = [[NSFileManager defaultManager] contentsAtPath:[self dataFile]];
    
    if (savedData) {
        NSDictionary* stuff = [NSKeyedUnarchiver unarchiveObjectWithData:savedData];
        [self.allSongs addObjectsFromArray: [stuff objectForKey:@"allSongs"]];
        [self.playlists addObjectsFromArray: [stuff objectForKey:@"playlists"]];
    }
    else {
        [self.playlists addObject: [[SDMasterPlaylist alloc] init]];
    }
    
    self.canSave = YES;
}

- (void) reallySaveData {
//    NSLog(@"saving");
    
    NSDictionary* contents = @{@"allSongs": [self allSongs], @"playlists": [self playlists]};
    NSData* contentsData = [NSKeyedArchiver archivedDataWithRootObject:contents];
    
    [[NSFileManager defaultManager] createFileAtPath:[self dataFile]
                                            contents:contentsData
                                          attributes:nil];
}

- (void) saveUserData {
    if (!self.canSave)
        return;
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reallySaveData) object:nil];
    [self performSelector:@selector(reallySaveData) withObject:nil afterDelay:1.0];
}

- (void) importSongsUnderURLs:(NSArray*)urls {
    [SDUserDataManager filterOnlyPlayableURLs:urls completionHandler:^(NSArray *urls) {
        NSArray* existingURLs = [self.allSongs valueForKeyPath:@"url"];
        
        for (NSURL* url in urls) {
            if ([existingURLs containsObject: url])
                continue;
            
            SDSong* song = [[SDSong alloc] init];
            song.url = [url fileReferenceURL];
            [song prefetchData];
            
            [self.allSongs addObject:song];
        }
        
        [self saveUserData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SDAllSongsDidChangeNotification object:nil];
    }];
}

+ (void) filterOnlyPlayableURLs:(NSArray*)urls completionHandler:(void(^)(NSArray* urls))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* list = [NSMutableArray array];
        
        NSFileManager* fileManager = [[NSFileManager alloc] init];
        
        for (NSURL* url in urls) {
            BOOL isDir;
            BOOL exists = [fileManager fileExistsAtPath:[url path] isDirectory:&isDir];
            if (!exists)
                continue;
            
            if (isDir) {
                NSDirectoryEnumerator* dirEnum = [fileManager enumeratorAtURL:url
                                                   includingPropertiesForKeys:@[]
                                                                      options:NSDirectoryEnumerationSkipsPackageDescendants & NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                     NSLog(@"error for [%@]! %@", url, error);
                                                                     return YES;
                                                                 }];
                
                for (NSURL* file in dirEnum) {
                    AVURLAsset* asset = [AVURLAsset assetWithURL:file];
                    if ([asset isPlayable]) {
                        [list addObject:file];
                    }
                }
            }
            else {
                AVURLAsset* asset = [AVURLAsset assetWithURL:url];
                if ([asset isPlayable]) {
                    [list addObject:url];
                }
            }
        }
        
        NSArray* urls = [list valueForKeyPath:@"fileReferenceURL"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(urls);
        });
    });
}

- (SDSong*) songForURL:(NSURL*)songURL {
    NSArray* allSongs = [[SDUserDataManager sharedMusicManager] allSongs];
    allSongs = [allSongs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"url = %@", songURL]];
    return [allSongs lastObject];
}

+ (NSArray*) songsForUUIDs:(NSArray*)songUUIDs {
    NSArray* allSongs = [[SDUserDataManager sharedMusicManager] allSongs];
    return [allSongs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uuid in %@", songUUIDs]];
}















#pragma mark - Deleting a playlist

- (void) deletePlaylist:(SDPlaylist*)playlist {
    NSMutableArray* playlists = [self playlists];
    
    NSUInteger playlistIndex = [playlists indexOfObject:playlist];
    [SDAddUndo(self) insertPlaylist:playlist atIndex:playlistIndex];
    
    [playlists removeObject:playlist];
    
    SDSaveData();
    SDPostNote(SDPlaylistRemovedNotification, playlist);
}

- (void) insertPlaylist:(SDPlaylist*)playlist atIndex:(NSUInteger)idx {
    [SDAddUndo(self) deletePlaylist:playlist];
    
    NSMutableArray* playlists = [[SDUserDataManager sharedMusicManager] playlists];
    
    [playlists insertObject:playlist atIndex:idx];
    
    SDSaveData();
    SDPostNote(SDPlaylistAddedNotification, playlist);
}

- (void) movePlaylist:(SDPlaylist*)playlist toIndex:(NSUInteger)newIndex {
    NSMutableArray* playlists = [[SDUserDataManager sharedMusicManager] playlists];
    
    NSUInteger oldIndex = [playlists indexOfObject:playlist];
    
    if (oldIndex == newIndex || oldIndex == newIndex - 1)
        return;
    
    if (oldIndex > newIndex) {
        [playlists removeObjectAtIndex:oldIndex];
        [playlists insertObject:playlist atIndex:newIndex];
        oldIndex++;
    }
    else {
        newIndex--;
        [playlists removeObjectAtIndex:oldIndex];
        [playlists insertObject:playlist atIndex:newIndex];
    }
    
    [SDAddUndo(self) movePlaylist:playlist toIndex:oldIndex];
    
    SDSaveData();
    SDPostNote(SDPlaylistAddedNotification, playlist);
}

- (SDPlaylist*) createPlaylist {
    SDPlaylist* newPlaylist = [[SDPlaylist alloc] init];
    [self insertPlaylist:newPlaylist atIndex:[[self playlists] count]];
    return newPlaylist;
}









- (void) importFromiTunes {
    @autoreleasepool {
        iTunesApplication* iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        iTunesSource* library;
        
        for (iTunesSource* source in [iTunesApp.sources get]) {
            if (source.kind == iTunesESrcLibrary) {
                library = source;
                break;
            }
        }
        
        NSArray* playlists = [library.playlists get];
        
        // we can assume iTunes doesn't have duplicates
        NSArray* currentSongFileURLs = [[SDSharedData() allSongs] valueForKey:@"url"];
        
        for (iTunesPlaylist* playlist in playlists) {
            @autoreleasepool {
                if ([[playlist className] isEqualToString: @"ITunesUserPlaylist"]) {
                    SDPlaylist* newPlaylist = [[SDPlaylist alloc] init];
                    newPlaylist.title = playlist.name;
                    newPlaylist.repeats = (playlist.songRepeat == iTunesERptAll);
                    newPlaylist.shuffles = playlist.shuffle;
                    
                    NSMutableArray* songsToAdd = [NSMutableArray array];
                    
                    for (iTunesFileTrack* track in [playlist.tracks get]) {
                        @autoreleasepool {
                            if ([NSStringFromClass([track class]) isEqualToString: @"ITunesFileTrack"]) {
                                NSURL* trackFileURL = [[track location] fileReferenceURL];
                                BOOL real = [[NSFileManager defaultManager] fileExistsAtPath:[trackFileURL path]];
                                
                                if (real) {
                                    SDSong* song;
                                    
                                    if (![currentSongFileURLs containsObject: trackFileURL]) {
                                        song = [[SDSong alloc] init];
                                        song.url = trackFileURL;
                                        [song prefetchData];
                                        
                                        [self.allSongs addObject:song];
                                    }
                                    else {
                                        song = [self songForURL:trackFileURL];
                                    }
                                    
                                    [songsToAdd addObject: song];
                                }
                            }
                        }
                    }
                    
                    [newPlaylist addSongs: songsToAdd];
                    [self insertPlaylist:newPlaylist
                                 atIndex:[[self playlists] count]];
                }
            }
        }
    }
}



@end


SDUserDataManager* SDSharedData() {
    return [SDUserDataManager sharedMusicManager];
}

void SDSaveData() {
    [[SDUserDataManager sharedMusicManager] saveUserData];
}

void SDPostNote(NSString* name, id obj) {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj];
}

id SDAddUndo(id target) {
    return [[SDUserDataManager sharedMusicManager].undoManager prepareWithInvocationTarget:target];
}
