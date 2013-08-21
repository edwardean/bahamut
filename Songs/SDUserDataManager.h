//
//  MUMusicManager.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "SDOldPlaylist.h"
//#import "SDOldSong.h"


#define SDAllSongsDidChangeNotification @"SDAllSongsDidChangeNotification"
#define SDPlaylistSongsDidChangeNotification @"SDPlaylistSongsDidChangeNotification"
#define SDPlaylistAddedNotification @"SDPlaylistAddedNotification"
#define SDPlaylistRenamedNotification @"SDPlaylistRenamedNotification"
#define SDPlaylistRemovedNotification @"SDPlaylistRemovedNotification"
#define SDPlaylistOptionsChangedNotification @"SDPlaylistOptionsChangedNotification"
//
//@interface SDUserDataManager : NSObject
//
//+ (SDUserDataManager*) sharedMusicManager;
//
//- (NSMutableArray*) allSongs;
//- (NSMutableArray*) playlists;
//
//- (void) loadUserData;
//
//- (void) importSongsUnderURLs:(NSArray*)urls;
//
//+ (NSArray*) songsForUUIDs:(NSArray*)songUUIDs;
//
//- (void) importFromiTunes;
//
//
//// manipulative
//
//@property NSUndoManager* undoManager;
//
////- (void) insertPlaylist:(SDOldPlaylist*)playlist atIndex:(NSUInteger)idx;
////- (void) movePlaylist:(SDOldPlaylist*)playlist toIndex:(NSUInteger)idx;
////- (void) deletePlaylist:(SDOldPlaylist*)playlist;
////- (SDOldPlaylist*) createPlaylist;
//
//@end
//
//
//SDUserDataManager* SDSharedData();
//
//void SDSaveData();
//void SDPostNote(NSString* name, id obj);
//id SDAddUndo(id target);
