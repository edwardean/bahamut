//
//  MUMusicManager.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDPlaylist.h"
#import "SDSong.h"


#define SDAllSongsDidChangeNotification @"SDAllSongsDidChangeNotification"
#define SDPlaylistSongsDidChangeNotification @"SDPlaylistSongsDidChangeNotification"
#define SDPlaylistAddedNotification @"SDPlaylistAddedNotification"
#define SDPlaylistRenamedNotification @"SDPlaylistRenamedNotification"
#define SDPlaylistRemovedNotification @"SDPlaylistRemovedNotification"
#define SDPlaylistOptionsChangedNotification @"SDPlaylistOptionsChangedNotification"

@interface SDUserDataManager : NSObject

+ (SDUserDataManager*) sharedMusicManager;

- (NSMutableArray*) allSongs;
- (NSMutableArray*) playlists;

- (void) loadUserData;
+ (void) saveUserData;

- (void) importSongsUnderURLs:(NSArray*)urls;

+ (NSArray*) songsForUUIDs:(NSArray*)songUUIDs;



// manipulative

@property NSUndoManager* undoManager;

- (void) insertPlaylist:(SDPlaylist*)playlist atIndex:(NSUInteger)idx;
- (void) movePlaylist:(SDPlaylist*)playlist toIndex:(NSUInteger)idx;
- (void) deletePlaylist:(SDPlaylist*)playlist;

@end


SDUserDataManager* SDSharedData();

void SDSaveData();
void SDPostNote(NSString* name, id obj);
id SDAddUndo(id target);
void SDGroupUndoOps(dispatch_block_t blk);
