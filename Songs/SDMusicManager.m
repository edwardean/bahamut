//
//  MUMusicManager.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDMusicManager.h"

#import <AVFoundation/AVFoundation.h>

#import "MAKVONotificationCenter.h"

@interface SDMusicManager ()

@property BOOL canSave;

@property SDPlaylistCollection* rootNode;

@property SDMasterPlaylist* masterPlaylist;
@property SDPlaylistCollection* userPlaylistsCollection;

@end

@implementation SDMusicManager

+ (SDMusicManager*) sharedMusicManager {
    static SDMusicManager* sharedMusicManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMusicManager = [[SDMusicManager alloc] init];
    });
    return sharedMusicManager;
}

- (id) init {
    if (self = [super init]) {
        self.rootNode = [[SDPlaylistCollection alloc] init];
        
        [[MAKVONotificationCenter defaultCenter] observeTarget:self
                                                       keyPath:@"userPlaylistsCollection.playlists"
                                                       options:0
                                                         block:^(MAKVONotification *notification) {
                                                             [SDMusicManager userDataChanged];
                                                         }];
    }
    return self;
}

- (void) loadUserData {
    NSLog(@"loading data");
    
    NSData* allSongsData = [[NSUserDefaults standardUserDefaults] dataForKey:@"allSongs"];
    NSData* userPlaylistsData = [[NSUserDefaults standardUserDefaults] dataForKey:@"userPlaylists"];
    
    self.masterPlaylist = [[SDMasterPlaylist alloc] init];
    [self.rootNode.playlists addObject:self.masterPlaylist];
    
    self.userPlaylistsCollection = [[SDPlaylistCollection alloc] init];
    [self.rootNode.playlists addObject:self.userPlaylistsCollection];
    
    if (allSongsData) {
        NSArray* songs = [NSKeyedUnarchiver unarchiveObjectWithData:allSongsData];
        NSLog(@"loading songs: %@", songs);
        [self.masterPlaylist loadSongs: songs];
    }
    
    if (userPlaylistsData) {
        NSArray* playlists = [NSKeyedUnarchiver unarchiveObjectWithData:userPlaylistsData];
        [self.userPlaylistsCollection.playlists addObjectsFromArray:playlists];
    }
    
    self.canSave = YES;
}

- (void) saveUserData {
    if (!self.canSave)
        return;
    
    NSLog(@"saving");
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[self.masterPlaylist songs]] forKey:@"allSongs"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[self userPlaylists]] forKey:@"userPlaylists"];
}

- (void) importSongsUnderURLs:(NSArray*)urls {
    [SDMusicManager filterOnlyPlayableURLs:urls completionHandler:^(NSArray *urls) {
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
    [[SDMusicManager sharedMusicManager] saveUserData];
}

- (NSArray*) allSongs {
    return [self.masterPlaylist songs];
}

- (NSArray*) userPlaylists {
    return [self.userPlaylistsCollection playlists];
}

@end
