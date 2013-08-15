//
//  MUMusicManager.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDAllSongsDidChange @"SDAllSongsDidChange"
#define SDPlaylistsDidVisiblyChange @"SDPlaylistsDidVisiblyChange"

@interface SDUserDataManager : NSObject

+ (SDUserDataManager*) sharedMusicManager;

- (NSMutableArray*) allSongs;
- (NSMutableArray*) playlists;

- (void) loadUserData;
+ (void) saveUserData;

- (void) importSongsUnderURLs:(NSArray*)urls;

@end
