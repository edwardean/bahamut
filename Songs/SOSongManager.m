//
//  SOSongManager.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOSongManager.h"

#import "SOPlaylist.h"
#import "SOSong.h"

@interface SOSongManager ()

@property NSMutableArray* cachedSongs;
@property NSMutableArray* cachedPlaylists;

@end

@implementation SOSongManager

+ (SOSongManager*) sharedSongManager {
    static SOSongManager* sharedSongManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSongManager = [[SOSongManager alloc] init];
        sharedSongManager.cachedSongs = [NSMutableArray array];
        sharedSongManager.cachedPlaylists = [NSMutableArray array];
        
//        // TEMP:
//        for (NSString* n in @[@1, @2, @3]) {
//            SOPlaylist* playlist = [[SOPlaylist alloc] init];
//            playlist.title = [NSString stringWithFormat:@"my playlist %@", n];
//            [sharedSongManager.cachedPlaylists addObject:playlist];
//        }
    });
    return sharedSongManager;
}

- (NSArray*) playlists {
    return [self.cachedPlaylists copy];
}

- (NSArray*) allSongs {
    return [self.cachedSongs copy];
}

- (void) loadSongs {
    NSData* songsData = [[NSUserDefaults standardUserDefaults] dataForKey:@"songs"];
    if (songsData) {
        self.cachedSongs = [NSKeyedUnarchiver unarchiveObjectWithData:songsData];
    }
}

- (void) saveSongs {
    NSData* songsData = [NSKeyedArchiver archivedDataWithRootObject:self.cachedSongs];
    [[NSUserDefaults standardUserDefaults] setObject:songsData forKey:@"songs"];
}

- (void) importSongsUnderURLs:(NSArray*)urls {
    [[NSNotificationCenter defaultCenter] postNotificationName:SOMusicImportBeginNotification object:nil];
    
    [SOSongManager filterOnlyPlayableURLs:urls completionHandler:^(NSArray *urls) {
        for (NSURL* url in urls) {
            if ([[self.cachedSongs valueForKeyPath:@"url"] containsObject: url])
                continue;
            
            SOSong* song = [[SOSong alloc] init];
            song.url = url;
            
            [self.cachedSongs addObject:song];
        }
        
        [self saveSongs];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SOMusicImportEndNotification object:nil];
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

@end
