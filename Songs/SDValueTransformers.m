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
    if (currentSong == nil)
        return @"Bahamut";
    
    NSArray* parts = @[currentSong.title ?: @"", currentSong.artist ?: @"", currentSong.album ?: @""];
    parts = [parts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    return [parts componentsJoinedByString:@"  -  "];
}

@end









@interface SDPlayingImageTransformer : NSValueTransformer
@end

@implementation SDPlayingImageTransformer

+ (Class)transformedValueClass { return [NSImage self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return [value boolValue] ? [NSImage imageNamed:@"SDPauseButtonImage"] : [NSImage imageNamed:@"SDPlayButtonImage"];
}

@end






@interface SDPlayingAlternateImageTransformer : NSValueTransformer
@end

@implementation SDPlayingAlternateImageTransformer

+ (Class)transformedValueClass { return [NSImage self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return [value boolValue] ? [NSImage imageNamed:@"SDPressedPauseButtonImage"] : [NSImage imageNamed:@"SDPressedPlayButtonImage"];
}

@end










@interface SDCanGoPrevImageTransformer : NSValueTransformer
@end

@implementation SDCanGoPrevImageTransformer

+ (Class)transformedValueClass { return [NSImage self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return [value boolValue] ? [NSImage imageNamed:@"SDDisabledPrevButtonImage"] : [NSImage imageNamed:@"SDEnabledPrevButtonImage"];
}

@end







@interface SDCanGoPrevAlternateImageTransformer : NSValueTransformer
@end

@implementation SDCanGoPrevAlternateImageTransformer

+ (Class)transformedValueClass { return [NSImage self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return [value boolValue] ? [NSImage imageNamed:@"SDPressedDisabledPrevButtonImage"] : [NSImage imageNamed:@"SDPressedEnabledPrevButtonImage"];
}

@end

















@interface SDCanGoNextImageTransformer : NSValueTransformer
@end

@implementation SDCanGoNextImageTransformer

+ (Class)transformedValueClass { return [NSImage self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return [value boolValue] ? [NSImage imageNamed:@"SDDisabledNextButtonImage"] : [NSImage imageNamed:@"SDEnabledNextButtonImage"];
}

@end







@interface SDCanGoNextAlternateImageTransformer : NSValueTransformer
@end

@implementation SDCanGoNextAlternateImageTransformer

+ (Class)transformedValueClass { return [NSImage self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return [value boolValue] ? [NSImage imageNamed:@"SDPressedDisabledNextButtonImage"] : [NSImage imageNamed:@"SDPressedEnabledNextButtonImage"];
}

@end
