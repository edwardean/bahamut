//
//  MUMusicManager.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "MUMusicManager.h"

#import <AVFoundation/AVFoundation.h>

#import "MAKVONotificationCenter.h"

@interface MUMusicManager ()

@property MUPlaylistCollection* rootNode;

@end

@implementation MUMusicManager

+ (MUMusicManager*) sharedMusicManager {
    static MUMusicManager* sharedMusicManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMusicManager = [[MUMusicManager alloc] init];
    });
    return sharedMusicManager;
}

- (id) init {
    if (self = [super init]) {
        self.rootNode = [[MUPlaylistCollection alloc] init];
        
        self.masterPlaylist = [[MUMasterPlaylist alloc] init];
        [self.rootNode.playlists addObject:self.masterPlaylist];
        
        self.userPlaylistsNode = [[MUPlaylistCollection alloc] init];
        [self.rootNode.playlists addObject:self.userPlaylistsNode];
        
//        [[MAKVONotificationCenter defaultCenter] observeTarget:self
//                                                       keyPath:@"allSongsPlaylist.songs"
//                                                       options:0
//                                                         block:^(MAKVONotification *notification) {
//                                                             NSLog(@"songs changed");
//                                                         }];
//        
//        [[MAKVONotificationCenter defaultCenter] observeTarget:self
//                                                       keyPath:@"userPlaylistsNode.playlists"
//                                                       options:0
//                                                         block:^(MAKVONotification *notification) {
//                                                             NSLog(@"playlists changed");
//                                                         }];
        
//        [[MAKVONotificationCenter defaultCenter] observeTarget:self
//                                                       keyPath:@"userPlaylistsNode.playlists.@unionOfObjects.title"
//                                                       options:0
//                                                         block:^(MAKVONotification *notification) {
//                                                             NSLog(@"playlist title changed");
//                                                         }];
        
//        [self.userPlaylistsNode.playlists addObject:[[MUPlaylist alloc] init]];
//        [self.userPlaylistsNode.playlists addObject:[[MUPlaylist alloc] init]];
//        [self.userPlaylistsNode.playlists addObject:[[MUPlaylist alloc] init]];
    }
    return self;
}

- (void) loadUserData {
    
}

- (void) importSongsUnderURLs:(NSArray*)urls {
    [MUMusicManager filterOnlyPlayableURLs:urls completionHandler:^(NSArray *urls) {
        [self.masterPlaylist addSongsWithURLs:urls];
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

+ (void) userDataChanged {
    
}

@end
