//
//  SDView.h
//  Songs
//
//  Created by Steven on 8/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SDView : NSView

@property (copy) void(^draw)();

@property (copy) void(^mouseUp)(NSEvent* event);
@property (copy) void(^mouseDown)(NSEvent* event);
@property (copy) void(^mouseDragged)(NSEvent* event);

@property (copy) void(^mouseEntered)(NSEvent* event);
@property (copy) void(^mouseExited)(NSEvent* event);
@property NSCursor* hoverCursor;

@property (copy) void(^clicked)();
@property (copy) void(^doubleClicked)();

@property BOOL hovered;
@property BOOL selected;
@property BOOL focused;

@property BOOL canGetKeyboard;
@property (copy) void(^pressedUp)();
@property (copy) void(^pressedDown)();
@property (copy) void(^pressedRight)();
@property (copy) void(^pressedLeft)();
@property (copy) void(^pressedEnter)();
@property (copy) void(^pressedSpace)();

@end
