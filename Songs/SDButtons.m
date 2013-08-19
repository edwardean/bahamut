//
//  SDButtons.m
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//


@interface SDPrevButtonCell : NSButtonCell @end
@implementation SDPrevButtonCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    cellFrame = NSInsetRect(cellFrame, 12.0, 8.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    [path moveToPoint:NSMakePoint(NSMaxX(cellFrame), NSMaxY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMidY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame))];
    
    if ([self isHighlighted])
        [[NSColor lightGrayColor] setStroke];
    else
        [[NSColor grayColor] setStroke];
    
    [path stroke];
}
@end

@interface SDNextButtonCell : NSButtonCell @end
@implementation SDNextButtonCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    cellFrame = NSInsetRect(cellFrame, 12.0, 8.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
    
    if ([self isHighlighted])
        [[NSColor lightGrayColor] setStroke];
    else
        [[NSColor grayColor] setStroke];
    
    [path stroke];
}
@end

@interface SDPlayButtonCell : NSButtonCell @end
@implementation SDPlayButtonCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    NSColor* color = ([self isHighlighted] ? [NSColor lightGrayColor] : [NSColor grayColor]);
    
    cellFrame = NSInsetRect(cellFrame, 8.0, 5.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    if ([[[self title] lowercaseString] isEqualToString: @"pause"]) {
        cellFrame = NSInsetRect(cellFrame, 5.0, 0.0);
        
        [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
        
        [path moveToPoint:NSMakePoint(NSMaxX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame))];
    }
    else {
        cellFrame.origin.x += 2.0;
        
        [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
        [path closePath];
    }
    
    [color setStroke];
    [path stroke];
}
@end
