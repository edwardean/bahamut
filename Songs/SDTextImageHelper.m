//
//  SDTBStatusItemHelper.m
//  TunesBar
//
//  Created by Steven Degutis on 3/15/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDTextImageHelper.h"

@implementation SDTextImageHelper

+ (NSImage*) imageWithTitle:(NSString*)title
                       font:(NSFont*)font
                  foreColor:(NSColor*)foreColor
              isHighlighted:(BOOL)isHighlighted
{
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowBlurRadius:1.0];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.7]];
	[shadow setShadowOffset:NSMakeSize(0, -1)];
	
    NSDictionary *attributes;
    
    if (isHighlighted == NO) {
        attributes = @{
                       NSFontAttributeName: font,
                       NSForegroundColorAttributeName: foreColor,
                       NSShadowAttributeName: shadow,
                       };
    }
    else {
        attributes = @{
                       NSFontAttributeName: font,
                       NSForegroundColorAttributeName: [NSColor whiteColor],
                       };
    }
	
	return [self imageFromString:title attributes:attributes];
}

+ (NSImage*) imageFromString:(NSString*)title attributes:(NSDictionary*)attributes {
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
	
	NSSize frameSize = [title sizeWithAttributes:attributes];
	NSImage *image = [[NSImage alloc] initWithSize:frameSize];
	[image lockFocus];
	[attributedTitle drawAtPoint:NSMakePoint(0, 0)];
	[image unlockFocus];
	return image;
}

@end
