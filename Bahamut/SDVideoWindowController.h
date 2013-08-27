//
//  SDVideoWindowController.h
//  Bahamut
//
//  Created by Steven Degutis on 8/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SDVideoWindowController : NSWindowController <NSWindowDelegate>

@property (copy) void(^died)();

@end
