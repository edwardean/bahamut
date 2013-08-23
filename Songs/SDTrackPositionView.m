//
//  SDTrackPositionView.m
//  Songs
//
//  Created by Steven Degutis on 3/26/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDTrackPositionView.h"

#import "SDColors.h"

@interface SDTrackPositionView ()

@property CGFloat _currentValue;
@property CGFloat _maxValue;

@property BOOL isDragging;

@end

@implementation SDTrackPositionView

- (void) setCurrentValue:(CGFloat)currentValue {
    if (self.isDragging)
        return;
    
    if (isnan(currentValue))
        self._currentValue = 0;
    else
        self._currentValue = currentValue;
    
    [self setNeedsDisplay:YES];
}

- (void) setMaxValue:(CGFloat)maxValue {
    if (self.isDragging)
        return;
    
    if (isnan(maxValue))
        self._maxValue = 0;
    else
        self._maxValue = maxValue;
    
    [self setNeedsDisplay:YES];
}

- (CGFloat) maxValue {
    return self._maxValue;
}

- (CGFloat) currentValue {
    return self._currentValue;
}

- (void)drawRect:(NSRect)dirtyRect {
    [NSGraphicsContext saveGraphicsState];
    
    NSRect bounds = [self bounds];
    bounds = NSIntegralRect(bounds);
    
    CGFloat outerRadius = 2.0;
    [[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRoundedRect:bounds xRadius:outerRadius yRadius:outerRadius] fill];
    
    
    
    
    CGFloat innerRadius = 1.0;
    
    NSRect box = bounds;
    box.size.width = 10.0;
    
    CGFloat minWidth = 2;
    CGFloat maxWidth = bounds.size.width - box.size.width - 2;
    CGFloat percentage = self._currentValue / self._maxValue;
    box.origin.x += (percentage * (maxWidth - minWidth)) + minWidth;
    
    box = NSIntegralRect(box);
    box = NSInsetRect(box, 1.0, 2.0);
    
    [SDDarkBlue setFill];
    [[NSBezierPath bezierPathWithRoundedRect:box xRadius:innerRadius yRadius:innerRadius] fill];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void) userDraggedWithEvent:(NSEvent*)event {
    NSRect trackableRect = NSInsetRect([self bounds], 1, 1);
    CGFloat x = [self convertPoint:[event locationInWindow] fromView:nil].x;
    
    CGFloat percentage = x / trackableRect.size.width;
    percentage = MAX(0, percentage);
    percentage = MIN(1, percentage);
    
    self._currentValue = percentage * self._maxValue;
    [self.trackPositionDelegate trackPositionMovedTo:self._currentValue];
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
