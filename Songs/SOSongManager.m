//
//  SOSongManager.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOSongManager.h"

#import "SOSong.h"

@interface SOSongManager ()

@property SOAllSongsPlaylist* allSongsPlaylist;
@property NSMutableArray* cachedUserPlaylists;

@end

@implementation SOSongManager

+ (SOSongManager*) sharedSongManager {
    static SOSongManager* sharedSongManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSongManager = [[SOSongManager alloc] init];
        sharedSongManager.allSongsPlaylist = [[SOAllSongsPlaylist alloc] init];
        sharedSongManager.cachedUserPlaylists = [NSMutableArray array];
        
        sharedSongManager.selectedPlaylist = sharedSongManager.allSongsPlaylist;
    });
    return sharedSongManager;
}

- (NSArray*) userPlaylists {
    return [self.cachedUserPlaylists copy];
}

- (void) loadData {
    NSData* allSongsPlaylistData = [[NSUserDefaults standardUserDefaults] dataForKey:@"allSongsPlaylist"];
    if (allSongsPlaylistData)
        self.allSongsPlaylist = [NSKeyedUnarchiver unarchiveObjectWithData:allSongsPlaylistData];
    
    NSData* userPlaylistsData = [[NSUserDefaults standardUserDefaults] dataForKey:@"userPlaylists"];
    if (userPlaylistsData)
        self.cachedUserPlaylists = [NSKeyedUnarchiver unarchiveObjectWithData:userPlaylistsData];
}

- (void) saveSongs {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.userPlaylists] forKey:@"userPlaylists"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.allSongsPlaylist] forKey:@"allSongsPlaylist"];
}

- (void) importSongsUnderURLs:(NSArray*)urls {
    [[NSNotificationCenter defaultCenter] postNotificationName:SOMusicImportBeginNotification object:nil];
    
    [SOSongManager filterOnlyPlayableURLs:urls completionHandler:^(NSArray *urls) {
        for (NSURL* url in urls) {
            SOSong* song = [[SOSong alloc] init];
            song.url = url;
            
            [self.allSongsPlaylist addSong:song];
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
