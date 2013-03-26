//
//  MUMusicManager.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDPlaylist.h"
#import "SDPlaylistCollection.h"
#import "SDMasterPlaylist.h"

@interface SDUserDataManager : NSObject

+ (SDUserDataManager*) sharedMusicManager;

- (NSArray*) allSongs;
- (NSArray*) userPlaylists;

- (void) loadUserData;

- (void) importSongsUnderURLs:(NSArray*)urls;

+ (void) userDataChanged;

@end
