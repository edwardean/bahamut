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





#define SDButtonRadius 2.0
#define SDButtonBackgroundColor [NSColor colorWithDeviceWhite:0.97 alpha:1.0]
#define SDButtonNormalColor [NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:1.0]
#define SDButtonHighlightColor [NSColor colorWithDeviceHue:206.0/360.0 saturation:0.27 brightness:0.92 alpha:1.0]
#define SDButtonDisabledColor [NSColor colorWithDeviceWhite:0.85 alpha:1.0]




static void SDDrawButtonBackground(NSBezierPath* path, NSRect cellFrame) {
    [NSGraphicsContext saveGraphicsState];
    [SDButtonBackgroundColor setFill];
//    [[NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:SDButtonRadius yRadius:SDButtonRadius] fill];
    [NSGraphicsContext restoreGraphicsState];
}

static void SDSetupButtonLine(NSBezierPath* path) {
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
}

static NSRect SDButtonInset(NSRect cellFrame) {
    return NSInsetRect(cellFrame, 14.0, 11.0);
}





@interface SDPlayButtonCell : NSButtonCell
@end

@implementation SDPlayButtonCell

- (void) drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSRect cellFrame = [controlView bounds];
    
    [([self isHighlighted] ? SDButtonHighlightColor : SDButtonNormalColor) set];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    SDSetupButtonLine(path);
    SDDrawButtonBackground(path, cellFrame);
    cellFrame = SDButtonInset(cellFrame);
    
    BOOL isPlaying = ([image name] == NSImageNameRightFacingTriangleTemplate);
    if (isPlaying) {
        // pause button
        
        cellFrame = NSInsetRect(cellFrame, 2.0, 0.0);
        
        [path setLineWidth: [path lineWidth] + 1];
        
        [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
        
        [path moveToPoint:NSMakePoint(NSMaxX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame))];
    }
    else {
        // play button
        
        cellFrame.origin.x += 1.0;
        
        [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
        [path closePath];
        
        [path fill];
    }
    
    [path stroke];
}

@end











static void SDDrawNavButton(NSRect cellFrame, BOOL isPressed, BOOL isEnabled, BOOL isNext) {
    if (!isEnabled)
        [SDButtonDisabledColor set];
    else if (isPressed)
        [SDButtonHighlightColor set];
    else
        [SDButtonNormalColor set];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    SDSetupButtonLine(path);
    SDDrawButtonBackground(path, cellFrame);
    cellFrame = SDButtonInset(cellFrame);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    if (isNext) {
        [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
    }
    else {
        [path moveToPoint:NSMakePoint(NSMaxX(cellFrame), NSMaxY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMidY(cellFrame))];
        [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame))];
    }
    
    [path stroke];
}

@interface SDPrevButtonCell : NSButtonCell
@end
@implementation SDPrevButtonCell

- (void) drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    SDDrawNavButton([controlView bounds],
                    [self isHighlighted],
                    [self isEnabled],
                    NO);
}

@end

@interface SDNextButtonCell : NSButtonCell
@end
@implementation SDNextButtonCell

- (void) drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    SDDrawNavButton([controlView bounds],
                    [self isHighlighted],
                    [self isEnabled],
                    YES);
}

@end
