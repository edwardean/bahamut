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
    [[[self window] contentView] setWantsLayer:YES];
    
    CALayer *superlayer = [[[self window] contentView] layer];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:[SDMusicPlayer sharedPlayer].player];
    [playerLayer setFrame:superlayer.bounds];
    
    playerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    
//    BOOL hasVideo = [[asset tracksWithMediaCharacteristic:AVMediaCharacteristicVisual] count] > 0;
    
    [self.window bind:@"contentAspectRatio" toObject:self withKeyPath:@"ratio" options:nil];
    
    [superlayer addSublayer:playerLayer];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.window unbind:@"contentAspectRatio"];
    
    self.died();
}

- (AVPlayer*) player {
    return [SDMusicPlayer sharedPlayer].player;
}

+ (NSSet*) keyPathsForValuesAffectingRatio {
    return [NSSet setWithArray:@[@"player.currentItem"]];
}

- (NSSize) ratio {
    NSLog(@"ratio");
    
    AVPlayerItem* item = [[SDMusicPlayer sharedPlayer].player currentItem];
    
    if (item) {
        dispatch_async(dispatch_get_current_queue(), ^{
            NSDisableScreenUpdates();
            [[self window] setContentSize: item.presentationSize];
            NSEnableScreenUpdates();
        });
        
        return item.presentationSize;
    }
    else {
        // TODO: this doesn't help any, it still crashes.
        
        dispatch_async(dispatch_get_current_queue(), ^{
            [[self window] setResizeIncrements:NSMakeSize(1.0, 1.0)];
        });
        
        return NSMakeSize(1.0, 1.0);
    }
}

@end
