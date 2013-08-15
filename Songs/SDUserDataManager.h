//
//  MUMusicManager.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "SDUserPlaylist.h"
//#import "SDPlaylistCollection.h"
//#import "SDMasterPlaylist.h"

@interface SDUserDataManager : NSObject

+ (SDUserDataManager*) sharedMusicManager;

//- (NSArray*) allSongs;
//- (NSArray*) playlists;

- (void) loadUserData;
+ (void) saveUserData;

- (void) importSongsUnderURLs:(NSArray*)urls;

@end
