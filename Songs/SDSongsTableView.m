//
//  SDSongsTableView.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSongsTableView.h"

#import "SDColors.h"

@implementation SDSongsTableView

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
    NSRange aVisibleRowIndexes = [self rowsInRect:clipRect];
    NSIndexSet* aSelectedRowIndexes = [self selectedRowIndexes];
    
    NSUInteger aRow = aVisibleRowIndexes.location;
    NSUInteger anEndRow = aRow + aVisibleRowIndexes.length;
    
    if (self == [[self window] firstResponder] && [[self window] isMainWindow] && [[self window] isKeyWindow]) {
        [SDTableRowSelectionColor setFill];
    }
    else {
        [SDTableRowSelectionUnfocusedColor setFill];
    }
    
    for (; aRow < anEndRow; aRow++) {
        if ([aSelectedRowIndexes containsIndex:aRow]) {
            [[NSBezierPath bezierPathWithRect:[self rectOfRow:aRow]] fill];
        }
    }
}

- (void) keyDown:(NSEvent *)theEvent {
    if ([[theEvent characters] isEqualToString: @"\r"]) {
        [NSApp sendAction:@selector(startPlayingSong:) to:nil from:nil];
    }
    else if ([[theEvent characters] characterAtIndex:0] == NSLeftArrowFunctionKey) {
        [NSApp sendAction:@selector(jumpToPlaylists:) to:nil from:nil];
    }
    else if ([[theEvent characters] isEqualToString: @" "]) {
        [NSApp sendAction:@selector(playPause:) to:nil from:nil];
    }
    else {
//        NSLog(@"%@", theEvent);
        [super keyDown:theEvent];
    }
}

@end
