//
//  SDVolumeSliderCell.m
//  Bahamut
//
//  Created by Steven on 8/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDVolumeSliderCell.h"

#import "SDColors.h"

@implementation SDVolumeSliderCell

- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped {
    
    [NSGraphicsContext saveGraphicsState];
    
    aRect = NSInsetRect(aRect, 4.0, 0.0);
    
    CGFloat r = 2.0;
    NSBezierPath* wholePath = [NSBezierPath bezierPathWithRoundedRect:aRect xRadius:r yRadius:r];
    
    [wholePath addClip];
    
    [SDVolumeSliderBackColor setFill];
    [wholePath fill];
    
    
    
    
    CGFloat h = NSHeight(aRect);
    CGFloat y = h * ([self doubleValue]);
    
    NSRect knobRect = aRect;
    knobRect.origin.y = h - y;
    knobRect.size.height = h;
    
    [SDVolumeSliderForeColor setFill];
    [[NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:r yRadius:r] fill];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawKnob:(NSRect)knobRect {
}

//- (NSRect)knobRectFlipped:(BOOL)flipped {
//    NSRect r = [super knobRectFlipped:flipped];
//    r.size.height = 1.0;
//    return r;
//}

@end
