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
    aRect = NSInsetRect(aRect, 4.0, 0.0);
    
    CGFloat r = 2.0;
    NSBezierPath* wholePath = [NSBezierPath bezierPathWithRoundedRect:aRect xRadius:r yRadius:r];
    
    [SDVolumeSliderBackColor setFill];
    [wholePath fill];
    
    CGFloat inset = 1.0;
    NSRect knobRect = NSInsetRect(aRect, inset, inset);
    
    NSRect bla;
    NSDivideRect(knobRect, &knobRect, &bla, NSHeight(knobRect) * ([self doubleValue]), NSMaxYEdge);
    
//    CGFloat h = ;
//    CGFloat y = ;
    
//    knobRect.origin.y = h - y;
//    knobRect.size.height = h;
    
    r = 1.0;
    NSBezierPath* knobPath = [NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:r yRadius:r];
    
    [SDVolumeSliderForeColor setFill];
    [knobPath fill];
}

- (void)drawKnob:(NSRect)knobRect {
}

- (CGFloat)knobThickness {
    return 1.0;
}

- (NSRect)knobRectFlipped:(BOOL)flipped {
    [[self controlView] setNeedsDisplay:YES];
    
    NSRect r = [super knobRectFlipped:flipped];
    r.size.height = 1.0;
    return r;
}

@end
