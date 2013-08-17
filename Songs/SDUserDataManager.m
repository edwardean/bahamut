//
//  MUMusicManager.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDUserDataManager.h"

#import <AVFoundation/AVFoundation.h>

#import "SDSong.h"

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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SDAllSongsDidChange object:nil];
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

@end
