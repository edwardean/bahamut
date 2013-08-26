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

- (void) dealloc {
    NSLog(@"bye");
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
    
//    BOOL hasVideo = [[asset tracksWithMediaCharacteristic:AVMediaCharacteristicVisual] count] > 0;
    
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
