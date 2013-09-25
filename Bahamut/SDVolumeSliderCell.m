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
    aRect = NSInsetRect(aRect, 0.5, 4.5);
    
    CGFloat r = 2.0;
    
    aRect.origin.y++;
    
    [[NSColor colorWithCalibratedWhite:0.83 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRoundedRect:aRect xRadius:r yRadius:r] fill];
    
    aRect.origin.y--;
    
    [[NSColor colorWithCalibratedWhite:0.58 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRoundedRect:aRect xRadius:r yRadius:r] fill];
    
    aRect = NSInsetRect(aRect, 1.0, 1.0);
    r--;
    
    [[NSColor colorWithCalibratedWhite:0.94 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRoundedRect:aRect xRadius:r yRadius:r] fill];
}

- (void)drawKnob:(NSRect)knobRect {
    knobRect = NSInsetRect(knobRect, 0.5, 4.5);
    knobRect = NSInsetRect(knobRect, 2.5, 2.5);
    
    CGFloat r = 1.0;
    
    [SDVolumeSliderForeColor setFill];
    [[NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:r yRadius:r] fill];
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
