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
    
//    [[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] setFill];
//    [ fill];
    
//    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.70 alpha:1.0]
//                                                         endingColor:[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]];
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:SDLightBlue
                                                         endingColor:SDMediumBlue];
    
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:innerRadius yRadius:innerRadius];
    
    [gradient drawInBezierPath:path angle:90.0];
}

- (void) drawBarInside:(NSRect)aRect flipped:(BOOL)flipped {
    aRect = NSIntegralRect(aRect);
    
    aRect.origin.y += 1.0;
    aRect.size.height -= 1.0;
    
    aRect = NSInsetRect(aRect, 1.5, 1.5);
    
    CGFloat outerRadius = 3.0;
    
    aRect.origin.y++;
    
    [[NSColor colorWithCalibratedWhite:0.98 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRoundedRect:aRect xRadius:outerRadius yRadius:outerRadius] fill];
    
    aRect.origin.y--;
    
    [[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRoundedRect:aRect xRadius:outerRadius yRadius:outerRadius] fill];
    
    aRect = NSInsetRect(aRect, 1.0, 1.0);
    outerRadius--;
    
    [SDTrackBackgroundColor setFill];
    [[NSBezierPath bezierPathWithRoundedRect:aRect xRadius:outerRadius yRadius:outerRadius] fill];
}

@end
