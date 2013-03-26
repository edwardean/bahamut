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

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

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
    NSRect bounds = [self bounds];
    [[NSColor blackColor] setFill];
    [[NSBezierPath bezierPathWithRect:bounds] fill];
    
    bounds = NSInsetRect([self bounds], 1, 1);
    [[NSColor grayColor] setFill];
    [[NSBezierPath bezierPathWithRect:bounds] fill];
    
    NSRect box = bounds;
    box.size.width = box.size.height;
    
    CGFloat maxWidth = bounds.size.width - box.size.width;
    CGFloat percentage = self.realCurrentValue / self.realMaxValue;
    box.origin.x += percentage * maxWidth;
    
    box = NSIntegralRect(box);
    
    [[NSColor lightGrayColor] setFill];
    [[NSBezierPath bezierPathWithRect:box] fill];
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
