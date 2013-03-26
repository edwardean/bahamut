//
//  SDTimeAsSeconds.m
//  Songs
//
//  Created by Steven Degutis on 3/26/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDTimeAsSeconds.h"

#import <AVFoundation/AVFoundation.h>

@implementation SDTimeAsSeconds

+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(NSValue*)value {
    CMTime time = [value CMTimeValue];
    return @(CMTimeGetSeconds(time));
}

@end
