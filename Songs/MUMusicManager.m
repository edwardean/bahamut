//
//  MUMusicManager.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "MUMusicManager.h"

#import "MUPlaylistNode.h"
#import "MUPlaylist.h"
#import "MUAllSongsPlaylist.h"

@interface MUMusicManager ()

@property MUPlaylistNode* rootNode;

@property MUAllSongsPlaylist* allSongsPlaylist;
@property MUPlaylistNode* userPlaylistsNode;

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
        self.rootNode = [[MUPlaylistNode alloc] init];
        
        self.allSongsPlaylist = [[MUAllSongsPlaylist alloc] init];
        [self.rootNode.playlists addObject:self.allSongsPlaylist];
        
        self.userPlaylistsNode = [[MUPlaylistNode alloc] init];
        [self.rootNode.playlists addObject:self.userPlaylistsNode];
        
        [self.userPlaylistsNode.playlists addObject:[[MUPlaylist alloc] init]];
        [self.userPlaylistsNode.playlists addObject:[[MUPlaylist alloc] init]];
        [self.userPlaylistsNode.playlists addObject:[[MUPlaylist alloc] init]];
    }
    return self;
}

@end
