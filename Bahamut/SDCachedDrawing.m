//
//  SDCachedDrawing.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDCachedDrawing.h"



#import "SDColors.h"

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
    
    [[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] setFill];
    [NSBezierPath fillRect:NSMakeRect(1, 0, 3, 10)];
    [NSBezierPath fillRect:NSMakeRect(6, 0, 3, 10)];
    
    [image unlockFocus];
    [image setTemplate:YES];
    [image setName:@"SDPause"];
    return image;
}

@end





#define SDButtonRadius 2.0




static void SDDrawButtonBackground(NSRect cellFrame, BOOL isPressed) {
//    [NSGraphicsContext saveGraphicsState];
//    [isPressed ? SDButtonBackgroundColorPressed : SDButtonBackgroundColor setFill];
//    [[NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:SDButtonRadius yRadius:SDButtonRadius] fill];
//    [NSGraphicsContext restoreGraphicsState];
}

static void SDSetupButtonLine(NSBezierPath* path) {
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
}

static NSRect SDButtonInset(NSRect cellFrame) {
    return NSInsetRect(cellFrame, 9.0, 6.0);
}





@interface SDPlayButtonCell : NSButtonCell
@end

@implementation SDPlayButtonCell

- (void) drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSRect cellFrame = [controlView bounds];
    
    [([self isHighlighted] ? SDButtonHighlightColor : SDButtonNormalColor) set];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    SDSetupButtonLine(path);
    SDDrawButtonBackground(cellFrame, [self isHighlighted]);
    cellFrame = SDButtonInset(cellFrame);
    
    BOOL isPlaying = ([[image name] isEqualToString: NSImageNameRightFacingTriangleTemplate]);
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
    SDDrawButtonBackground(cellFrame, isPressed);
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

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    SDDrawNavButton([controlView bounds],
                    [self isHighlighted],
                    [self isEnabled],
                    NO);
}

@end

@interface SDNextButtonCell : NSButtonCell
@end
@implementation SDNextButtonCell

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    SDDrawNavButton([controlView bounds],
                    [self isHighlighted],
                    [self isEnabled],
                    YES);
}

@end












@interface SDCheckboxCell : NSButtonCell
@end

@implementation SDCheckboxCell

- (void) drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    BOOL ticked = [self intValue];
    
    CGFloat d = 2.0;
    frame = NSInsetRect(frame, d, d);
    
    NSColor* backgroundColor;
    NSColor* backgroundColorPressed;
    
    NSColor* checkmarkColor = [NSColor colorWithCalibratedWhite:0.96 alpha:1.0];
    NSColor* checkmarkColorPressed = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
    
    if (ticked) {
        backgroundColor = SDDarkBlue;
        backgroundColorPressed = SDMediumBlue;
    }
    else {
        backgroundColor = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
        backgroundColorPressed = [NSColor colorWithCalibratedWhite:0.97 alpha:1.0];
    }
    
    [([self isHighlighted] ? backgroundColorPressed : backgroundColor) setFill];
    
    CGFloat r = 2.0;
    NSBezierPath* backgroundPath = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:r yRadius:r];
    [backgroundPath fill];
    
    if (ticked) {
        d = 4.0;
        frame = NSInsetRect(frame, d, d);
        
        NSBezierPath* checkPath = [NSBezierPath bezierPath];
        
        [checkPath setLineWidth:3.0];
        [checkPath setLineCapStyle:NSRoundLineCapStyle];
        [checkPath setLineJoinStyle:NSRoundLineJoinStyle];
        
//        [checkPath moveToPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame))];
//        [checkPath lineToPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame))];
//        [checkPath moveToPoint:NSMakePoint(NSMinX(frame), NSMinY(frame))];
//        [checkPath lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame))];
        
        [checkPath moveToPoint:NSMakePoint(NSMinX(frame), NSMidY(frame) + 1.0)];
        [checkPath lineToPoint:NSMakePoint(NSMidX(frame) - 1.0, NSMaxY(frame))];
        [checkPath lineToPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame))];
        
        [([self isHighlighted] ? checkmarkColorPressed : checkmarkColor) setStroke];
        [checkPath stroke];
    }
}

@end




@interface SDTitlebarCloseButtonCell : NSButtonCell
@end

@implementation SDTitlebarCloseButtonCell

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if ([self isHighlighted])
        [[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
    else
        [[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
    
//    [[self isHighlighted] ? [NSColor colorWithCalibratedWhite:0.90 alpha:1.0] : [NSColor colorWithCalibratedWhite:0.93 alpha:1.0] setFill];
//    [[NSBezierPath bezierPathWithRoundedRect:[controlView bounds] xRadius:SDButtonRadius yRadius:SDButtonRadius] fill];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    SDSetupButtonLine(path);
    CGFloat d = 7.0;
    cellFrame = NSInsetRect(cellFrame, d, d);
    
    [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMaxY(cellFrame))];
    
    [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame))];
    
    [path stroke];
}

@end




@interface SDTitlebarMaxButtonCell : NSButtonCell
@end

@implementation SDTitlebarMaxButtonCell

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if ([self isHighlighted])
        [[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
    else
        [[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
    
    //    [[self isHighlighted] ? [NSColor colorWithCalibratedWhite:0.90 alpha:1.0] : [NSColor colorWithCalibratedWhite:0.93 alpha:1.0] setFill];
    //    [[NSBezierPath bezierPathWithRoundedRect:[controlView bounds] xRadius:SDButtonRadius yRadius:SDButtonRadius] fill];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    SDSetupButtonLine(path);
    CGFloat d = 7.0;
    cellFrame = NSInsetRect(cellFrame, d, d);
    
    [path moveToPoint:NSMakePoint(NSMidX(cellFrame), NSMinY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMidX(cellFrame), NSMaxY(cellFrame))];
    
    [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMidY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
    
    [path stroke];
}

@end



@interface SDTitlebarMinButtonCell : NSButtonCell
@end

@implementation SDTitlebarMinButtonCell

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if ([self isHighlighted])
        [[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
    else
        [[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
    
    //    [[self isHighlighted] ? [NSColor colorWithCalibratedWhite:0.90 alpha:1.0] : [NSColor colorWithCalibratedWhite:0.93 alpha:1.0] setFill];
    //    [[NSBezierPath bezierPathWithRoundedRect:[controlView bounds] xRadius:SDButtonRadius yRadius:SDButtonRadius] fill];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    SDSetupButtonLine(path);
    CGFloat d = 7.0;
    cellFrame = NSInsetRect(cellFrame, d, d);
    
    [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMidY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
    
    [path stroke];
}

@end
