//
//  MUMusicManager.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDUserDataManager.h"

#import <AVFoundation/AVFoundation.h>

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

- (void) loadUserData {
//    NSLog(@"loading");
    
    self.allSongs = [NSMutableArray array];
    self.playlists = [NSMutableArray array];
    
    NSData* allSongsData = [[NSUserDefaults standardUserDefaults] dataForKey:@"allSongs"];
    NSData* playlistsData = [[NSUserDefaults standardUserDefaults] dataForKey:@"playlists"];
    
    if (allSongsData)
        [self.allSongs addObjectsFromArray: [NSKeyedUnarchiver unarchiveObjectWithData:allSongsData]];
    
    if (playlistsData)
        [self.playlists addObjectsFromArray: [NSKeyedUnarchiver unarchiveObjectWithData:playlistsData]];
    
    self.canSave = YES;
}

- (void) saveUserData {
    if (!self.canSave)
        return;
    
//    NSLog(@"saving");
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[self allSongs]] forKey:@"allSongs"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[self playlists]] forKey:@"playlists"];
}

- (void) importSongsUnderURLs:(NSArray*)urls {
    [SDUserDataManager filterOnlyPlayableURLs:urls completionHandler:^(NSArray *urls) {
        NSArray* existingURLs = [self.allSongs valueForKeyPath:@"url"];
        
        for (NSURL* url in urls) {
            if ([existingURLs containsObject: url])
                continue;
            
            SDSong* song = [[SDSong alloc] init];
            song.url = [url fileReferenceURL];
            
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

+ (void) saveUserData {
    [[SDUserDataManager sharedMusicManager] saveUserData];
}

+ (NSArray*) songsForUUIDs:(NSArray*)songUUIDs {
    NSMutableArray* foundSongs = [NSMutableArray array];
    
    NSArray* allSongs = [[SDUserDataManager sharedMusicManager] allSongs];
    
    for (NSString* uuid in songUUIDs) {
        NSUInteger songIndex = [allSongs indexOfObjectPassingTest:^BOOL(SDSong* otherSong, NSUInteger idx, BOOL *stop) {
            return [[otherSong valueForKey:@"uuid"] isEqualToString:uuid];
        }];
        
        if (songIndex != NSNotFound) {
            SDSong* song = [allSongs objectAtIndex:songIndex];
            [foundSongs addObject:song];
        }
    }
    
    return foundSongs;
}















#pragma mark - Deleting a playlist

- (void) deletePlaylist:(SDPlaylist*)playlist {
    NSMutableArray* playlists = [self playlists];
    
    NSUInteger playlistIndex = [playlists indexOfObject:playlist];
    [SDAddUndo(self) insertPlaylist:playlist atIndex:playlistIndex];
    
    [playlists removeObject:playlist];
    
    SDSaveData();
    SDPostNote(SDPlaylistRemovedNotification, nil);
}

- (void) insertPlaylist:(SDPlaylist*)playlist atIndex:(NSUInteger)idx {
    [SDAddUndo(self) deletePlaylist:playlist];
    
    NSMutableArray* playlists = [[SDUserDataManager sharedMusicManager] playlists];
    
    [playlists insertObject:playlist atIndex:idx];
    
    SDSaveData();
    SDPostNote(SDPlaylistAddedNotification, nil);
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
    SDPostNote(SDPlaylistAddedNotification, nil);
}













@end


SDUserDataManager* SDSharedData() {
    return [SDUserDataManager sharedMusicManager];
}

void SDSaveData() {
    [SDUserDataManager saveUserData];
}

void SDPostNote(NSString* name, id obj) {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj];
}

id SDAddUndo(id target) {
    return [[SDUserDataManager sharedMusicManager].undoManager prepareWithInvocationTarget:target];
}

void SDGroupUndoOps(dispatch_block_t blk) {
    [[SDUserDataManager sharedMusicManager].undoManager beginUndoGrouping];
    blk();
    [[SDUserDataManager sharedMusicManager].undoManager endUndoGrouping];
}
