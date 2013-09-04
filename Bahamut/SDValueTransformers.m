//
//  SDValueTransformers.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//



#import "SDMusicPlayer.h"
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

- (id)transformedValue:(NSOrderedSet*)set {
    return [set array];
}

- (id)reverseTransformedValue:(NSArray*)array {
	return [NSOrderedSet orderedSetWithArray:array];
}

@end









@interface SDTimeForSeconds : NSValueTransformer
@end

@implementation SDTimeForSeconds

+ (Class)transformedValueClass { return [NSString self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    CGFloat seconds = [value doubleValue];
    return SDGetTimeForSeconds(seconds);
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
    
    NSArray* parts = @[currentSong.title ?: @"", currentSong.artist ?: @""
//                       , currentSong.album ?: @""
                       ];
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
    return [NSImage imageNamed: ([value boolValue] ? NSImageNameRightFacingTriangleTemplate : NSImageNameStatusNone)];
}

@end









@interface SDHasVideoIconTransformer : NSValueTransformer
@end

@implementation SDHasVideoIconTransformer

+ (Class)transformedValueClass { return [NSImage self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return [NSImage imageNamed: ([value boolValue] ? NSImageNameStatusAvailable : NSImageNameStatusNone)];
}

@end
