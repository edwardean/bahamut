//
//  SDSongsTableHeaderCell.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSongsTableHeaderCell.h"

@implementation SDSongsTableHeaderCell

- (NSRect)drawingRectForBounds:(NSRect)theRect {
    theRect.origin.y += 7;
    return theRect;
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)view {
//    NSRect border, bla;
//    NSDivideRect(cellFrame, &border, &bla, 1.0, NSMaxYEdge);
    
    [[NSColor colorWithCalibratedWhite:0.98 alpha:1.0] setFill];
    [NSBezierPath fillRect:cellFrame];
    
//    [[NSColor colorWithCalibratedWhite:0.80 alpha:1.0] setFill];
//    [NSBezierPath fillRect:border];
    
    [self drawInteriorWithFrame:cellFrame inView:view];
}

@end
