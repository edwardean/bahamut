//
//  SDCreatePlaylistButtonCell.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDCreatePlaylistButtonCell.h"

#import "SDColors.h"

@implementation SDCreatePlaylistButtonCell

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSMutableAttributedString* attrTitle = [[self attributedTitle] mutableCopy];
    
    if ([self isHighlighted]) {
        [attrTitle addAttribute:NSForegroundColorAttributeName value:SDDarkBlue range:NSMakeRange(0, [attrTitle length])];
    }
    else {
        [attrTitle addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0, [attrTitle length])];
    }
    
    [self setAttributedTitle:attrTitle];
    
    [super drawWithFrame:cellFrame inView:controlView];
}

- (NSRect) drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    frame.origin.x -= 3.0;
    return [super drawTitle:title withFrame:frame inView:controlView];
}

@end
