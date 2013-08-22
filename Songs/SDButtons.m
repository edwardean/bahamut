//
//  SDButtons.m
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//












@interface SDButtonCell : NSButtonCell
@end
@implementation SDButtonCell

- (void) sd_drawPath:(NSBezierPath*)path inFrame:(NSRect)cellFrame {
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    NSColor* color;
    if (![self isEnabled])
        color = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    else if ([self isHighlighted])
        color = [NSColor lightGrayColor];
    else
        color = [NSColor grayColor];
    [color set];
    
    [self sd_drawPath:path inFrame:cellFrame];
    
    [path stroke];
    
    [NSGraphicsContext restoreGraphicsState];
}

@end




@interface SDPrevButtonCell : SDButtonCell @end
@implementation SDPrevButtonCell
- (void) sd_drawPath:(NSBezierPath*)path inFrame:(NSRect)cellFrame {
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [NSBezierPath fillRect:cellFrame];
    [NSGraphicsContext restoreGraphicsState];
    
    cellFrame = NSInsetRect(cellFrame, 12.0, 8.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    [path moveToPoint:NSMakePoint(NSMaxX(cellFrame), NSMaxY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMidY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame))];
}
@end

@interface SDNextButtonCell : SDButtonCell @end
@implementation SDNextButtonCell
- (void) sd_drawPath:(NSBezierPath*)path inFrame:(NSRect)cellFrame {
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [NSBezierPath fillRect:cellFrame];
    [NSGraphicsContext restoreGraphicsState];
    
    cellFrame = NSInsetRect(cellFrame, 12.0, 8.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
}
@end

@interface SDPlayButtonCell : SDButtonCell @end
@implementation SDPlayButtonCell
- (void) sd_drawPath:(NSBezierPath*)path inFrame:(NSRect)cellFrame {
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [NSBezierPath fillRect:cellFrame];
    [NSGraphicsContext restoreGraphicsState];
    
    cellFrame = NSInsetRect(cellFrame, 8.0, 5.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    if ([[[self title] lowercaseString] isEqualToString: @"pause"]) {
        cellFrame = NSInsetRect(cellFrame, 4.0, 1.0);
        
        [path setLineWidth:4.0];
        
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
}
@end











@interface SDScroller : NSScroller
@end

@implementation SDScroller

- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag {
    [[NSColor whiteColor] setFill];
    [NSBezierPath fillRect:slotRect];
}

@end












@interface SDCreatePlaylistButtonCell : NSButtonCell
@end

@implementation SDCreatePlaylistButtonCell

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if ([self isHighlighted]) {
        [[NSColor colorWithDeviceWhite:0.88 alpha:1.0] setFill];
        [NSBezierPath fillRect:cellFrame];
    }
    
    [super drawWithFrame:cellFrame inView:controlView];
}

@end
