//
//  SDButtons.m
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//






@interface SDPlayerStatusImageTransformer : NSValueTransformer
@end
@implementation SDPlayerStatusImageTransformer

+ (Class)transformedValueClass { return [NSImage self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    int val = [value intValue];
    if (val == 0)
        return nil;
    else if (val == 1)
        return [NSImage imageNamed: @"SDPause"];
    else
        return [NSImage imageNamed: NSImageNameRightFacingTriangleTemplate];
}

@end






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
//    [NSGraphicsContext saveGraphicsState];
//    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
//    [NSBezierPath fillRect:NSInsetRect(cellFrame, 5.0, 3.0)];
//    [NSGraphicsContext restoreGraphicsState];
    
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
//    [NSGraphicsContext saveGraphicsState];
//    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
//    [NSBezierPath fillRect:NSInsetRect(cellFrame, 5.0, 3.0)];
//    [NSGraphicsContext restoreGraphicsState];
    
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
//    [NSGraphicsContext saveGraphicsState];
//    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
//    [NSBezierPath fillRect:cellFrame];
//    [NSGraphicsContext restoreGraphicsState];
    
    cellFrame = NSInsetRect(cellFrame, 8.0, 5.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    if ([[[self title] lowercaseString] isEqualToString: @"pause"]) {
        cellFrame = NSInsetRect(cellFrame, 5.0, 1.0);
        
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














@interface SDCreatePlaylistButton : NSButton
@property NSTrackingArea* trackingArea;
@property BOOL hovered;
@end

@implementation SDCreatePlaylistButton

- (void) dealloc {
    [self removeTrackingArea:self.trackingArea];
    // im pretty sure this isnt sufficient, but i cant figure out what is.
}

- (void) viewDidMoveToSuperview {
    [super viewDidMoveToSuperview];
    
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                     options:NSTrackingInVisibleRect | NSTrackingActiveInKeyWindow | NSTrackingMouseEnteredAndExited
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void) drawRect:(NSRect)dirtyRect {
    if (self.hovered) {
        [[NSColor colorWithDeviceWhite:0.89 alpha:1.0] setFill];
        [NSBezierPath fillRect:dirtyRect];
    }
    [super drawRect:dirtyRect];
}

- (void) mouseEntered:(NSEvent *)theEvent {
    self.hovered = YES;
    [self setNeedsDisplay:YES];
}

- (void) mouseExited:(NSEvent *)theEvent {
    self.hovered = NO;
    [self setNeedsDisplay:YES];
}

@end






@interface SDCreatePlaylistButtonCell : NSButtonCell
@end

@implementation SDCreatePlaylistButtonCell

- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    frame.origin.x += 7.0;
    [super drawImage:image withFrame:frame inView:controlView];
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    frame.origin.x += 8;
    frame.size.width -= 8;
    return [super drawTitle:title withFrame:frame inView:controlView];
}

@end
