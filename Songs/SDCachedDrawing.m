//
//  SDCachedDrawing.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDCachedDrawing.h"

@interface SDCachedDrawing ()

@property NSImage* pauseImage;

@end

@implementation SDCachedDrawing

+ (SDCachedDrawing*) singleton {
    static SDCachedDrawing* singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[SDCachedDrawing alloc] init];
    });
    return singleton;
}

+ (void) drawThings {
    [self singleton].pauseImage = [self makePauseIcon];
}

+ (NSImage*) makePauseIcon {
    NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(10, 10)];
    [image lockFocus];
    
    [[NSColor colorWithDeviceWhite:0.0 alpha:1.0] setFill];
    [NSBezierPath fillRect:NSMakeRect(1, 0, 3, 10)];
    [NSBezierPath fillRect:NSMakeRect(6, 0, 3, 10)];
    
    [image unlockFocus];
    [image setTemplate:YES];
    [image setName:@"SDPause"];
    return image;
}

@end












@interface SDPrevButtonCell : NSButtonCell
@end

@implementation SDPrevButtonCell

- (void) drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSRect cellFrame = [controlView bounds];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    NSColor* color;
    if (![self isEnabled])
        color = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    else if ([self isHighlighted])
        color = [NSColor lightGrayColor];
    else
        color = [NSColor grayColor];
    [color set];
    
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRect:cellFrame] fill];
    [NSGraphicsContext restoreGraphicsState];
    
    cellFrame = NSInsetRect(cellFrame, 12.0, 8.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    [path moveToPoint:NSMakePoint(NSMaxX(cellFrame), NSMaxY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMidY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame))];
    
    [path stroke];
}

@end









@interface SDPlayButtonCell : NSButtonCell
@end

@implementation SDPlayButtonCell

- (void) drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSRect cellFrame = [controlView bounds];
    
    BOOL isPlaying = ([image name] == NSImageNameRightFacingTriangleTemplate);
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    NSColor* color = ([self isHighlighted] ? [NSColor lightGrayColor] : [NSColor grayColor]);
    [color set];
    
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRect:cellFrame] fill];
    [NSGraphicsContext restoreGraphicsState];
    
    cellFrame = NSInsetRect(cellFrame, 8.0, 5.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    if (!isPlaying) {
        cellFrame = NSInsetRect(cellFrame, 4.0, 1.0);
        
        [path setLineWidth:4.0];
        
        [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
        
        [path moveToPoint:NSMakePoint(NSMaxX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame))];
    }
    else {
        cellFrame.origin.x += 2.0;
        
        [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
        [path closePath];
    }
    
    [path stroke];
}

@end







@interface SDNextButtonCell : NSButtonCell
@end

@implementation SDNextButtonCell

- (void) drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSRect cellFrame = [controlView bounds];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    NSColor* color;
    if (![self isEnabled])
        color = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    else if ([self isHighlighted])
        color = [NSColor lightGrayColor];
    else
        color = [NSColor grayColor];
    [color set];
    
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [[NSBezierPath bezierPathWithRect:cellFrame] fill];
    [NSGraphicsContext restoreGraphicsState];
    
    cellFrame = NSInsetRect(cellFrame, 12.0, 8.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
    
    [path stroke];
}

@end
