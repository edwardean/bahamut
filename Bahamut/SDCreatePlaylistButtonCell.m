//
//  SDCreatePlaylistButtonCell.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDCreatePlaylistButtonCell.h"

@implementation SDCreatePlaylistButtonCell

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if ([self isHighlighted]) {
        [[NSColor colorWithCalibratedWhite:0.89 alpha:1.0] setFill];
        [NSBezierPath fillRect:cellFrame];
    }
    
    [super drawWithFrame:cellFrame inView:controlView];
}

- (NSRect) drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    frame.origin.x -= 3.0;
    return [super drawTitle:title withFrame:frame inView:controlView];
}

@end
