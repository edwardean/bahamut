//
//  SDScroller.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDScroller.h"

@implementation SDScroller

- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag {
    [[NSColor whiteColor] setFill];
    [NSBezierPath fillRect:slotRect];
}

@end
