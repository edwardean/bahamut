//
//  MUPlayerWindowController.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MUPlayerWindowKilledDelegate <NSObject>

- (void) playerWindowKilled:(id)controller;

@end

@interface SDPlayerWindowController : NSWindowController <NSWindowDelegate>

@property (weak) id<MUPlayerWindowKilledDelegate> killedDelegate;

- (IBAction) nextSong:(id)sender;
- (IBAction) prevSong:(id)sender;
- (IBAction) playPause:(id)sender;

@end
