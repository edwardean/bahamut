//
//  SDTrackPositionView.m
//  Songs
//
//  Created by Steven Degutis on 3/26/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDTrackPositionView.h"

@interface SDTrackPositionView ()

@property (nonatomic) CGFloat realCurrentValue;
@property (nonatomic) CGFloat realMaxValue;

@property BOOL isDragging;

@end

@implementation SDTrackPositionView

- (void) setCurrentValue:(CGFloat)currentValue {
    if (self.isDragging)
        return;
    
    if (isnan(currentValue))
        self.realCurrentValue = 0;
    else
        self.realCurrentValue = currentValue;
    
    [self setNeedsDisplay:YES];
}

- (void) setMaxValue:(CGFloat)maxValue {
    if (self.isDragging)
        return;
    
    if (isnan(maxValue))
        self.realMaxValue = 0;
    else
        self.realMaxValue = maxValue;
    
    [self setNeedsDisplay:YES];
}

- (CGFloat) maxValue {
    return self.realMaxValue;
}

- (CGFloat) currentValue {
    return self.realCurrentValue;
}

- (void)drawRect:(NSRect)dirtyRect {
    [NSGraphicsContext saveGraphicsState];
    
    NSRect bounds = [self bounds];
    
    bounds = NSIntegralRect(bounds);
    bounds = NSInsetRect(bounds, 0.5, 0.5);
    
    [[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRect:bounds] fill];
    
    
    
    
    NSRect box = bounds;
    box.size.width = 10.0;
    
    CGFloat minWidth = 2;
    CGFloat maxWidth = bounds.size.width - box.size.width - 2;
    CGFloat percentage = self.realCurrentValue / self.realMaxValue;
    box.origin.x += (percentage * (maxWidth - minWidth)) + minWidth;
    
    box = NSIntegralRect(box);
    box = NSInsetRect(box, 0.0, 2.5);
    
    [[NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRect:box] fill];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void) userDraggedWithEvent:(NSEvent*)event {
    NSRect trackableRect = NSInsetRect([self bounds], 1, 1);
    CGFloat x = [self convertPoint:[event locationInWindow] fromView:nil].x;
    
    CGFloat percentage = x / trackableRect.size.width;
    percentage = MAX(0, percentage);
    percentage = MIN(1, percentage);
    
    self.realCurrentValue = percentage * self.realMaxValue;
    [self.trackPositionDelegate trackPositionMovedTo:self.realCurrentValue];
}

- (void) mouseDown:(NSEvent *)theEvent {
    self.isDragging = YES;
    [self userDraggedWithEvent:theEvent];
    [self setNeedsDisplay:YES];
}

- (void) mouseDragged:(NSEvent *)theEvent {
    self.isDragging = YES;
    [self userDraggedWithEvent:theEvent];
    [self setNeedsDisplay:YES];
}

- (void) mouseUp:(NSEvent *)theEvent {
    self.isDragging = NO;
    [self setNeedsDisplay:YES];
}

@end
