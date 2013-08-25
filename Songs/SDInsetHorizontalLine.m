//
//  SDInsetHorizontalLine.m
//  Zephyros
//
//  Created by Steven Degutis on 8/1/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDInsetHorizontalLine.h"

@implementation SDInsetHorizontalLine

- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds], garbage;
    NSDivideRect(bounds, &bounds, &garbage, 2.0, NSMaxYEdge);
    
	NSRect topLine, bottomLine;
	NSDivideRect(bounds, &topLine, &bottomLine, 1.0, NSMaxYEdge);
	
	[[NSColor lightGrayColor] setFill];
	[NSBezierPath fillRect:topLine];
	
	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect:bottomLine];
}

@end
