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
    NSRect b = self.bounds;
//    NSDivideRect(b, &b, &bla, 18.0, NSMinXEdge);
    
//    b = NSInsetRect(b, 2.0, 6.0);
    
//    b.origin.x += 3.0;
    
//    b = NSInsetRect(b, 0.5, 0.5);
    
    NSBezierPath* path = [NSBezierPath bezierPathWithRect:b];
//    [path setLineWidth:2.0];
    
    NSColor* color;
    
    BOOL isHighlighted = [[self window] firstResponder] == [self superview] && [[self window] isKeyWindow];
    
    if (isHighlighted)
        color = SDTableRowSelectionColor;
    else
        color = SDTableRowSelectionUnfocusedColor;
    
//    if (isHighlighted) {
//        [[NSColor colorWithCalibratedWhite:0.98 alpha:1.0] setFill];
//        [path fill];
//    }
    
//    [color setStroke];
//    [path stroke];
    [color setFill];
    [path fill];
}

//- (NSBackgroundStyle) interiorBackgroundStyle {
//    return NSBackgroundStyleLight;
//}

@end
