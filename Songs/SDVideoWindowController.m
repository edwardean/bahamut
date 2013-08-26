//
//  SDVideoWindowController.m
//  Bahamut
//
//  Created by Steven Degutis on 8/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDVideoWindowController.h"

#import "SDMusicPlayer.h"

@interface SDVideoWindowController ()

@property (readonly) NSSize ratio;

@end

@implementation SDVideoWindowController

- (NSString*) windowNibName {
    return @"VideoWindow";
}

- (void) keyDown:(NSEvent *)theEvent {
    if ([[theEvent characters] isEqualToString: @" "]) {
        [NSApp sendAction:@selector(playPause:) to:nil from:nil];
        return;
    }
    [super keyDown:theEvent];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[self window] setMovableByWindowBackground:YES];
    [[self window] setBackgroundColor:[NSColor blackColor]];
    [[[self window] contentView] setWantsLayer:YES];
    
    CALayer *superlayer = [[[self window] contentView] layer];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:[SDMusicPlayer sharedPlayer].player];
    [playerLayer setFrame:superlayer.bounds];
    playerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    
    [superlayer addSublayer:playerLayer];
}

- (void) windowWillClose:(NSNotification *)notification {
    self.died();
}

- (AVPlayer*) player {
    return [SDMusicPlayer sharedPlayer].player;
}

+ (NSSet*) keyPathsForValuesAffectingRatio {
    return [NSSet setWithArray:@[@"player.currentItem"]];
}

@end
