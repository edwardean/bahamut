//
//  SDPlaylistChooserView.h
//  Songs
//
//  Created by Steven on 8/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDPlaylist.h"

@protocol SDPlaylistChooserDelegate <NSObject>

- (void) didChoosePlaylist:(SDPlaylist*)playlist;

@end

@interface SDPlaylistChooserView : NSView

@property (weak) NSArray* playlists;

- (void) redrawPlaylists;

@property (weak) IBOutlet id<SDPlaylistChooserDelegate> delegate;

@end
