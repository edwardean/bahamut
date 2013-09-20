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
    aRect = NSInsetRect(aRect, 0.0, 5.0);
    
    CGFloat r = 2.0;
    NSBezierPath* wholePath = [NSBezierPath bezierPathWithRoundedRect:aRect xRadius:r yRadius:r];
    
    [SDVolumeSliderBackColor setFill];
    [wholePath fill];
}

- (void)drawKnob:(NSRect)knobRect {
    knobRect = NSInsetRect(knobRect, 0.0, 5.0);
    knobRect = NSInsetRect(knobRect, 2.0, 2.0);
    
    CGFloat r = 1.0;
    NSBezierPath* knobPath = [NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:r yRadius:r];
    
    [SDVolumeSliderForeColor setFill];
    [knobPath fill];
}

//- (CGFloat)knobThickness {
//    NSLog(@"%f", [super knobThickness]);
//    return 1.0;
//    return [super knobThickness];
//}

//- (NSRect)knobRectFlipped:(BOOL)flipped {
//    NSRect r = [super knobRectFlipped:flipped];
//    r.size.height /= 2.0;
//    r.origin.y += r.size.height / 2.0;
//    return r;
//}

@end
