//
//  SDTBStatusItemHelper.h
//  TunesBar
//
//  Created by Steven Degutis on 3/15/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDTextImageHelper : NSObject

+ (NSImage*) imageWithTitle:(NSString*)title
                       font:(NSFont*)font
                  foreColor:(NSColor*)foreColor
              isHighlighted:(BOOL)isHighlighted;

+ (NSImage*) imageFromString:(NSString*)title attributes:(NSDictionary*)attributes;

@end
