//
//  SDTrackPositionView.m
//  Songs
//
//  Created by Steven Degutis on 3/26/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDTrackSliderCell.h"

#import "SDColors.h"

@implementation SDTrackSliderCell

- (void) setDoubleValue:(double)aDouble {
    if (![self isHighlighted])
        [super setDoubleValue:aDouble];
}

- (void) drawKnob:(NSRect)knobRect {
    if (fabs([self maxValue]) < 0.0005)
        return;
    
    knobRect = [[self controlView] bounds];
    knobRect = NSInsetRect(knobRect, 4.5, 4.0);
    
    knobRect.origin.y += 1.0;
    knobRect.size.height -= 1.0;
    
    CGFloat knobWidth = 8.0;
    
    CGFloat availWidth = knobRect.size.width - knobWidth;
    
    knobRect.origin.x += (([self doubleValue] / [self maxValue]) * availWidth);
    knobRect.size.width = knobWidth;
    
    knobRect = NSIntegralRect(knobRect);
    
    CGFloat innerRadius = 1.0;
    [SDMediumBlue setFill];
    [[NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:innerRadius yRadius:innerRadius] fill];
}

- (void) drawBarInside:(NSRect)aRect flipped:(BOOL)flipped {
    aRect = NSIntegralRect(aRect);
    
    aRect.origin.y += 1.0;
    aRect.size.height -= 1.0;
    
    aRect = NSInsetRect(aRect, 2.0, 2.0);
    
    CGFloat outerRadius = 2.0;
    [SDTrackBackgroundColor setFill];
    [SDMediumBlue setStroke];
    [[NSBezierPath bezierPathWithRoundedRect:aRect xRadius:outerRadius yRadius:outerRadius] fill];
    [[NSBezierPath bezierPathWithRoundedRect:aRect xRadius:outerRadius yRadius:outerRadius] stroke];
}

@end
