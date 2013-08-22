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

@property NSImage* playButtonImage;
@property NSImage* playButtonImagePressed;
@property NSImage* pauseButtonImage;
@property NSImage* pauseButtonImagePressed;

@property NSImage* enabledPrevButtonImage;
@property NSImage* enabledPrevButtonImagePressed;
@property NSImage* disabledPrevButtonImage;
@property NSImage* disabledPrevButtonImagePressed;

@property NSImage* enabledNextButtonImage;
@property NSImage* enabledNextButtonImagePressed;
@property NSImage* disabledNextButtonImage;
@property NSImage* disabledNextButtonImagePressed;

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
    [[self singleton] drawThings];
}

- (void) drawThings {
    self.pauseImage = [self makePauseIcon];
    
    self.playButtonImage = [self makePlayButtonImage:@"SDPlayButtonImage" playing:YES pressed:NO];
    self.playButtonImagePressed = [self makePlayButtonImage:@"SDPressedPlayButtonImage" playing:YES pressed:YES];
    self.pauseButtonImage = [self makePlayButtonImage:@"SDPauseButtonImage" playing:NO pressed:NO];
    self.pauseButtonImagePressed = [self makePlayButtonImage:@"SDPressedPauseButtonImage" playing:NO pressed:YES];
    
    self.enabledPrevButtonImage = [self makeNavButtonImage:@"SDEnabledPrevButtonImage" sel:@selector(drawPrevButton:inFrame:) enabled:YES pressed:NO];
    self.enabledPrevButtonImagePressed = [self makeNavButtonImage:@"SDPressedEnabledPrevButtonImage" sel:@selector(drawPrevButton:inFrame:) enabled:YES pressed:YES];
    self.disabledPrevButtonImage = [self makeNavButtonImage:@"SDDisabledPrevButtonImage" sel:@selector(drawPrevButton:inFrame:) enabled:NO pressed:NO];
    self.disabledPrevButtonImagePressed = [self makeNavButtonImage:@"SDPressedDisabledPrevButtonImage" sel:@selector(drawPrevButton:inFrame:) enabled:NO pressed:YES];
    
    self.enabledNextButtonImage = [self makeNavButtonImage:@"SDEnabledNextButtonImage" sel:@selector(drawNextButton:inFrame:) enabled:YES pressed:NO];
    self.enabledNextButtonImagePressed = [self makeNavButtonImage:@"SDPressedEnabledNextButtonImage" sel:@selector(drawNextButton:inFrame:) enabled:YES pressed:YES];
    self.disabledNextButtonImage = [self makeNavButtonImage:@"SDDisabledNextButtonImage" sel:@selector(drawNextButton:inFrame:) enabled:NO pressed:NO];
    self.disabledNextButtonImagePressed = [self makeNavButtonImage:@"SDPressedDisabledNextButtonImage" sel:@selector(drawNextButton:inFrame:) enabled:NO pressed:YES];
}

- (NSImage*) makePauseIcon {
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

- (NSImage*) makePlayButtonImage:(NSString*)name playing:(BOOL)isPlaying pressed:(BOOL)isPressed {
    NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(40, 40)];
    [image lockFocus];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    NSColor* color = (isPressed ? [NSColor lightGrayColor] : [NSColor grayColor]);
    [color set];
    
    [self drawPlayButton:path inFrame:NSMakeRect(0, 0, 40, 40) isPlaying:isPlaying];
    
    [path stroke];
    
    [image unlockFocus];
    [image setName:name];
    return image;
}

- (NSImage*) makeNavButtonImage:(NSString*)name sel:(SEL)sel enabled:(BOOL)isEnabled pressed:(BOOL)isPressed {
    NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(40, 40)];
    [image lockFocus];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    NSColor* color;
    if (!isEnabled)
        color = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    else if (isPressed)
        color = [NSColor lightGrayColor];
    else
        color = [NSColor grayColor];
    [color set];
    
    IMP meth = [self methodForSelector:sel];
    meth(self, sel, path, NSMakeRect(0, 0, 40, 40));
    
    [path stroke];
    
    [image unlockFocus];
    [image setName:name];
    return image;
}



- (void) drawPlayButton:(NSBezierPath*)path inFrame:(NSRect)cellFrame isPlaying:(BOOL)isPlaying {
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [NSBezierPath fillRect:cellFrame];
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
}

- (void) drawPrevButton:(NSBezierPath*)path inFrame:(NSRect)cellFrame {
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [NSBezierPath fillRect:cellFrame];
    [NSGraphicsContext restoreGraphicsState];
    
    cellFrame = NSInsetRect(cellFrame, 12.0, 8.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    [path moveToPoint:NSMakePoint(NSMaxX(cellFrame), NSMaxY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMidY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame))];
}

- (void) drawNextButton:(NSBezierPath*)path inFrame:(NSRect)cellFrame {
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [NSBezierPath fillRect:cellFrame];
    [NSGraphicsContext restoreGraphicsState];
    
    cellFrame = NSInsetRect(cellFrame, 12.0, 8.0);
    cellFrame = NSInsetRect(cellFrame, 3.0, 3.0);
    
    [path setLineWidth:3.0];
    [path setLineCapStyle:NSSquareLineCapStyle];
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    [path moveToPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
    [path lineToPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
}

@end
