//
//  SDPlaylistViewController.h
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDPlaylist.h"

@interface SDSongListViewController : NSViewController

@property (weak) SDPlaylist* playlist;

- (NSArray*) selectedSongs;

- (void) selectSongs:(NSArray*)songs;

@end
