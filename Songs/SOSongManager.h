//
//  SOSongManager.h
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SOAllSongsPlaylist.h"
#import "SOPlaylist.h"

#define SOMusicUserDataChangedNotification @"SOMusicUserDataChangedNotification"

#define SOMusicImportBeginNotification @"SOMusicImportBeginNotification"
#define SOMusicImportEndNotification @"SOMusicImportEndNotification"

@interface SOSongManager : NSObject

+ (SOSongManager*) sharedSongManager;

@property (readonly) SOAllSongsPlaylist* allSongsPlaylist;
@property (readonly) NSArray* userPlaylists;

@property (weak) SOPlaylist* selectedPlaylist;

- (void) loadData;

- (SOPlaylist*) makeNewPlaylist;

- (void) importSongsUnderURLs:(NSArray*)urls;

+ (void) userDataDidChange;

@end
