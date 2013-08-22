//
//  SDValueTransformers.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//



#import "SDSong.h"

@interface SDPlayerStatusImageTransformer : NSValueTransformer
@end
@implementation SDPlayerStatusImageTransformer

+ (Class)transformedValueClass { return [NSImage self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    int val = [value intValue];
    if (val == 0)
        return nil;
    else if (val == 1)
        return [NSImage imageNamed: @"SDPause"];
    else
        return [NSImage imageNamed: NSImageNameRightFacingTriangleTemplate];
}

@end





@interface SDOrderedSetTransformer : NSValueTransformer
@end

@implementation SDOrderedSetTransformer

+ (Class)transformedValueClass { return [NSArray class]; }
+ (BOOL)allowsReverseTransformation { return YES; }

- (id)transformedValue:(id)value {
    return [(NSOrderedSet *)value array];
}

- (id)reverseTransformedValue:(id)value {
	return [NSOrderedSet orderedSetWithArray:value];
}

@end









@interface SDTimeForSeconds : NSValueTransformer
@end

@implementation SDTimeForSeconds

+ (Class)transformedValueClass { return [NSString self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    CGFloat seconds = [value doubleValue];
    CGFloat mins = seconds / 60.0;
    CGFloat secs = fmod(seconds, 60.0);
    return [NSString stringWithFormat:@"%d:%02d", (int)mins, (int)secs];
}

@end










@interface SDSongInfoTransformer : NSValueTransformer
@end

@implementation SDSongInfoTransformer

+ (Class)transformedValueClass { return [NSString self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(SDSong*)currentSong {
    return [NSString stringWithFormat:@"%@  -  %@  -  %@", currentSong.title, currentSong.artist, currentSong.album];
}

@end









@interface SDPlayingTitleTransformer : NSValueTransformer
@end

@implementation SDPlayingTitleTransformer

+ (Class)transformedValueClass { return [NSString self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return [value boolValue] ? @"Pause" : @"Play";
}

@end
