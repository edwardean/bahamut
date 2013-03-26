//
//  MUMusicManager.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MUPlaylist.h"
#import "MUPlaylistCollection.h"
#import "MUMasterPlaylist.h"

@interface MUMusicManager : NSObject

@property MUMasterPlaylist* masterPlaylist;
@property MUPlaylistCollection* userPlaylistsNode;

+ (MUMusicManager*) sharedMusicManager;

- (void) loadUserData;

- (void) importSongsUnderURLs:(NSArray*)urls;

+ (void) userDataChanged;

@end
