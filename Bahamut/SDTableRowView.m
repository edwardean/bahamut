//
//  SDTableRowView.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDTableRowView.h"

#import "SDColors.h"

@implementation SDTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if ([[self window] firstResponder] == [self superview] && [[self window] isKeyWindow]) {
        [SDTableRowSelectionColor setFill];
        [[NSBezierPath bezierPathWithRect:self.bounds] fill];
    }
    else {
        [SDTableRowSelectionUnfocusedColor setFill];
        [[NSBezierPath bezierPathWithRect:self.bounds] fill];
    }
}

@end
