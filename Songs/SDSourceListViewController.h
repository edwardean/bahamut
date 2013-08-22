//
//  SDPlaylistsViewController.h
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDOldPlaylist.h"

@protocol SDPlaylistsViewDelegate <NSObject>

//- (void) selectPlaylist:(SDOldPlaylist*)playlist;
//- (void) playPlaylist:(SDOldPlaylist*)playlist;

@end

@interface SDSourceListViewController : NSViewController

@property (weak) id<SDPlaylistsViewDelegate> playlistsViewDelegate;

//- (void) selectPlaylist:(SDOldPlaylist*)playlist;
//- (void) editPlaylistTitle;

@end
