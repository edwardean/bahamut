//
//  SDSongsTableView.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSongsTableView.h"

@implementation SDSongsTableView

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
    NSRange aVisibleRowIndexes = [self rowsInRect:clipRect];
    NSIndexSet* aSelectedRowIndexes = [self selectedRowIndexes];
    
    NSUInteger aRow = aVisibleRowIndexes.location;
    NSUInteger anEndRow = aRow + aVisibleRowIndexes.length;
    
    if (self == [[self window] firstResponder] && [[self window] isMainWindow] && [[self window] isKeyWindow]) {
        [[NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:1.0] setFill];
    }
    else {
        [[NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:0.5] setFill];
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
    else if ([[theEvent characters] isEqualToString: @" "]) {
        [NSApp sendAction:@selector(playPause:) to:nil from:nil];
    }
    else {
//        NSLog(@"%@", theEvent);
        [super keyDown:theEvent];
    }
}

@end
