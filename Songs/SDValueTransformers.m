//
//  SDValueTransformers.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//


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
