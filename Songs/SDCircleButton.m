//
//  SDCircleButtonCell.m
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDCircleButton.h"

@implementation SDCircleButton

//- (void) resetCursorRects {
//    NSCursor* c = [NSCursor pointingHandCursor];
//    [self addCursorRect:[self bounds] cursor:c];
//    [c setOnMouseEntered:YES];
//}

//- (void)awakeFromNib {
//    NSColor *color = [NSColor whiteColor];
//    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
//    
//    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
//    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
//    
//    [self setAttributedTitle:colorTitle];
//}

@end

@implementation SDCircleButtonCell

- (BOOL) isOpaque {
    return NO;
}

- (void) drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    if ([self isHighlighted]) {
        [[NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:1.0] setFill];
    }
    else {
        [[NSColor colorWithDeviceWhite:1.0 alpha:1.0] setFill];
    }
    
    [[NSBezierPath bezierPathWithOvalInRect:frame] fill];
}

@end
