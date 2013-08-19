//
//  SDPlaylistsViewController.h
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDPlaylist.h"

@protocol SDPlaylistsViewDelegate <NSObject>

- (void) selectPlaylist:(SDPlaylist*)playlist;
- (void) playPlaylist:(SDPlaylist*)playlist;

@end

@interface SDPlaylistsViewController : NSViewController

@property (weak) id<SDPlaylistsViewDelegate> playlistsViewDelegate;

- (void) selectPlaylist:(SDPlaylist*)playlist;

@end
