//
//  MUMusicManager.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MUPlaylist.h"
#import "MUPlaylistNode.h"
#import "MUAllSongsPlaylist.h"

@interface MUMusicManager : NSObject

@property MUAllSongsPlaylist* allSongsPlaylist;
@property MUPlaylistNode* userPlaylistsNode;

+ (MUMusicManager*) sharedMusicManager;

- (void) loadUserData;

- (void) importSongsUnderURLs:(NSArray*)urls;

@end
