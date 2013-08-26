//
//  SDVideoWindowController.m
//  Bahamut
//
//  Created by Steven Degutis on 8/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDVideoWindowController.h"

#import "SDMusicPlayer.h"


#define SD_TRACKER_HIDE_DELAY (1.0)

@interface SDVideoWindowController ()

@property (weak) IBOutlet NSSlider* playerTrackSlider;

@property (readonly) NSSize ratio;

@property NSTrackingArea* area;

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
    
    [self.playerTrackSlider bind:@"maxValue" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentSong.duration" options:nil];
    [self.playerTrackSlider bind:@"doubleValue" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentTime" options:nil];
    
    playerLayer.zPosition = -1.0;
    
    [superlayer addSublayer:playerLayer];
    
    [self hideTracker];
    
    [self performSelector:@selector(hideTracker) withObject:nil afterDelay:SD_TRACKER_HIDE_DELAY];
    
    self.area = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                             options:NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect
                                               owner:self
                                            userInfo:nil];
    [[[self window] contentView] addTrackingArea:self.area];
}

- (void) hideTracker {
    [[self.playerTrackSlider animator] setHidden:YES];
}

- (void) mouseEntered:(NSEvent *)theEvent {
    [self mouseMoved:theEvent];
}

- (void) mouseExited:(NSEvent *)theEvent {
    [[self.playerTrackSlider animator] setHidden:YES];
}

- (void) mouseMoved:(NSEvent *)theEvent {
    [[self.playerTrackSlider animator] setHidden:NO];
    
    NSPoint pointRelativeToTracker = [[[self window] contentView] convertPoint:[theEvent locationInWindow]
                                                                      fromView:nil];
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTracker) object:nil];
    
    BOOL mouseOverTracker = NSPointInRect(pointRelativeToTracker, [self.playerTrackSlider frame]);
    if (!mouseOverTracker) {
        [self performSelector:@selector(hideTracker) withObject:nil afterDelay:SD_TRACKER_HIDE_DELAY];
    }
}

- (void) windowWillClose:(NSNotification *)notification {
    [[[self window] contentView] removeTrackingArea:self.area];
    
    [self.playerTrackSlider unbind:@"maxValue"];
    [self.playerTrackSlider unbind:@"doubleValue"];
    
    self.died();
}

- (AVPlayer*) player {
    return [SDMusicPlayer sharedPlayer].player;
}

+ (NSSet*) keyPathsForValuesAffectingRatio {
    return [NSSet setWithArray:@[@"player.currentItem"]];
}

- (IBAction) manuallyChangeSongPosition:(id)sender {
    [[SDMusicPlayer sharedPlayer] seekToTime:[self.playerTrackSlider doubleValue]];
}

@end
