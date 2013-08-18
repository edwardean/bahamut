//
//  SDTrackPositionView.m
//  Songs
//
//  Created by Steven Degutis on 3/26/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDTrackPositionView.h"












@interface SDFlatButton : NSButton
@end
@implementation SDFlatButton

- (void) drawRect:(NSRect)dirtyRect {
    
}

@end











@interface SDPlaylistView : NSView

@property NSTrackingArea* area;
@property BOOL hovering;

@end

@implementation SDPlaylistView

- (void)viewDidMoveToSuperview {
    if (self.area)
        [self removeTrackingArea:self.area];
    
    self.area = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                             options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect
                                               owner:self
                                            userInfo:nil];
    [self addTrackingArea:self.area];
}

- (void) drawRect:(NSRect)dirtyRect {
    NSColor* backgroundColor = [NSColor colorWithCalibratedWhite:0.3 alpha:1.0];
    NSColor* hoveredBackgroundColor = [NSColor colorWithCalibratedWhite:0.5 alpha:1.0];
    
    NSColor* color = (self.hovering ? hoveredBackgroundColor : backgroundColor);
    [color drawSwatchInRect:[self bounds]];
}

- (void) mouseEntered:(NSEvent *)theEvent {
    self.hovering = YES;
    [self setNeedsDisplay:YES];
}

- (void) mouseExited:(NSEvent *)theEvent {
    self.hovering = NO;
    [self setNeedsDisplay:YES];
}

- (void) mouseDown:(NSEvent *)theEvent {
    NSLog(@"%ld", [theEvent clickCount]);
}

- (void) dealloc {
    if (self.area)
        [self removeTrackingArea:self.area];
}

@end









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
    NSRect prototypeSliderBounds = bounds;
    bounds = NSInsetRect(bounds, 0.0, 4.0);
    
    bounds = NSIntegralRect(bounds);
    bounds = NSInsetRect(bounds, 0.5, 0.5);
    
    CGFloat wholeThingRadius = 5.0;
    NSBezierPath* thePath = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:wholeThingRadius yRadius:wholeThingRadius];
    [thePath setLineWidth:0.5];
    [thePath setLineJoinStyle:NSRoundLineJoinStyle];
    [thePath setLineCapStyle:NSRoundLineCapStyle];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = NSMakeSize(0.0, -1.0);
    shadow.shadowBlurRadius = 0.5;
    shadow.shadowColor = [NSColor whiteColor];
    [shadow set];
    
    NSGradient* innerWholeGradient = [[NSGradient alloc] initWithColors:@[
                                                                          [NSColor colorWithCalibratedWhite:0.80 alpha:1.0],
                                      [NSColor colorWithCalibratedWhite:0.70 alpha:1.0],
                                      ]];
    [innerWholeGradient drawInBezierPath:thePath angle:90.0];
    
    [NSGraphicsContext restoreGraphicsState];
    
    [[NSColor colorWithCalibratedWhite:0.45 alpha:1.0] setStroke];
    [thePath stroke];
    
    
    
    
    NSRect box = prototypeSliderBounds;
    box.size.width = 7.0;
    
    CGFloat minWidth = 3;
    CGFloat maxWidth = bounds.size.width - box.size.width - 3;
    CGFloat percentage = self.realCurrentValue / self.realMaxValue;
    box.origin.x += (percentage * (maxWidth - minWidth)) + minWidth;
    
    box = NSIntegralRect(box);
    box = NSInsetRect(box, 0.0, 1.0);
    
    CGFloat sliderRadius = 4.0;
    NSBezierPath* sliderPath = [NSBezierPath bezierPathWithRoundedRect:box xRadius:sliderRadius yRadius:sliderRadius];
    [sliderPath setLineWidth:0.5];
    [sliderPath setLineJoinStyle:NSRoundLineJoinStyle];
    [sliderPath setLineCapStyle:NSRoundLineCapStyle];
    
    [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] setFill];
    [sliderPath fill];
    
    [[NSColor colorWithCalibratedWhite:0.45 alpha:1.0] setStroke];
    [sliderPath stroke];
    
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
