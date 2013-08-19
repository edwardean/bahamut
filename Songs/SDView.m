//
//  SDView.m
//  Songs
//
//  Created by Steven on 8/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDView.h"

@interface SDView ()

@property NSTrackingArea* area;

@end

@implementation SDView

- (void) viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    
    if (self.area)
        [self removeTrackingArea:self.area];
    
    self.area = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                             options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect
                                               owner:self
                                            userInfo:nil];
    [self addTrackingArea:self.area];
}

- (void) dealloc {
    if (self.area)
        [self removeTrackingArea:self.area];
}

- (BOOL) canBecomeKeyView {
    return self.canGetKeyboard;
}

- (BOOL) acceptsFirstResponder {
    return self.canGetKeyboard;
}

- (void) mouseEntered:(NSEvent *)theEvent {
    self.hovered = YES;
    
    if (self.hoverCursor) [self.hoverCursor push];
    if (self.mouseEntered) self.mouseEntered(theEvent);
    
    [self setNeedsDisplay:YES];
}

- (void) keyDown:(NSEvent *)theEvent {
    NSString* chars = [theEvent charactersIgnoringModifiers];
    unichar code = [chars characterAtIndex:0];
    
    if (code == NSUpArrowFunctionKey) {
        if (self.pressedUp) self.pressedUp();
    }
    else if (code == NSDownArrowFunctionKey) {
        if (self.pressedDown) self.pressedDown();
    }
    else if (code == NSLeftArrowFunctionKey) {
        if (self.pressedLeft) self.pressedLeft();
    }
    else if (code == NSRightArrowFunctionKey) {
        if (self.pressedRight) self.pressedRight();
    }
    else if (code == '\r') {
        if (self.pressedEnter) self.pressedEnter();
    }
    else if (code == ' ') {
        if (self.pressedSpace) self.pressedSpace();
    }
}

- (void) mouseExited:(NSEvent *)theEvent {
    self.hovered = NO;
    
    if (self.hoverCursor) [self.hoverCursor pop];
    if (self.mouseExited) self.mouseExited(theEvent);
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    if (self.draw) self.draw();
}

- (void) mouseDown:(NSEvent *)theEvent {
    if (self.mouseDown) self.mouseDown(theEvent);
    [self setNeedsDisplay:YES];
}

- (void) mouseUp:(NSEvent *)theEvent {
    if (self.mouseUp) self.mouseUp(theEvent);
    
    if ([theEvent clickCount] == 1) {
        if (self.clicked) self.clicked();
    }
    else if ([theEvent clickCount] == 2) {
        if (self.doubleClicked) self.doubleClicked();
    }
    [self setNeedsDisplay:YES];
}

- (void) mouseDragged:(NSEvent *)theEvent {
    if (self.mouseDragged) self.mouseDragged(theEvent);
    [self setNeedsDisplay:YES];
}

@end
