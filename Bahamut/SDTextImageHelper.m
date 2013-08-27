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
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: foreColor,
                                 };
	
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
	
	NSSize frameSize = [title sizeWithAttributes:attributes];
	NSImage *image = [[NSImage alloc] initWithSize:frameSize];
	[image lockFocus];
	[attributedTitle drawAtPoint:NSMakePoint(0, 0)];
	[image unlockFocus];
    
    [image setTemplate:YES];
    
	return image;
}

@end
