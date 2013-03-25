//
//  SOSongManager.h
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SOMusicImportBeginNotification @"SOMusicImportBeginNotification"
#define SOMusicImportEndNotification @"SOMusicImportEndNotification"

@interface SOSongManager : NSObject

+ (SOSongManager*) sharedSongManager;

- (NSArray*) allSongs;

- (NSArray*) playlists;

- (void) loadSongs;

- (void) importSongsUnderURLs:(NSArray*)urls;

@end
