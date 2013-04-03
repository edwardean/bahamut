//
//  SDPlayButtonValueTransformer.m
//  Songs
//
//  Created by Steven Degutis on 3/29/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlayButtonValueTransformer.h"

#import "SDMusicPlayer.h"

@implementation SDPlayButtonValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(NSNumber*)value {
    if ([value intValue] == SDMusicPlayerStatusPlaying) {
        return @"Pause";
    }
    else {
        return @"Play";
    }
}

@end
