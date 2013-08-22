//
//  SDPlaylistsTableView.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylistsTableView.h"

@implementation SDPlaylistsTableView

- (void) keyDown:(NSEvent *)theEvent {
    if ([[theEvent characters] isEqualToString: @"\r"]) {
        [NSApp sendAction:@selector(startPlayingPlaylist:) to:nil from:nil];
    }
    else if ([[theEvent characters] characterAtIndex:0] == NSRightArrowFunctionKey) {
        [NSApp sendAction:@selector(jumpToSongs:) to:nil from:nil];
    }
    else {
//        NSLog(@"%@", theEvent);
        [super keyDown:theEvent];
    }
}

@end
