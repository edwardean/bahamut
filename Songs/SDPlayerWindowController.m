//
//  MUPlayerWindowController.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlayerWindowController.h"

#import "SDMusicPlayer.h"
#import "SDTrackPositionView.h"

#import "SDCoreData.h"

#import "SDPlaylistTableDelegate.h"
#import "SDSongTableDelegate.h"




@interface SDPlayerWindowController ()

@property IBOutlet SDPlaylistTableDelegate* playlistTableDelegate;
@property IBOutlet SDSongTableDelegate* songTableDelegate;

@property (weak) IBOutlet NSView* nowPlayingControlsView;
@property (weak) IBOutlet SDTrackPositionView* songPositionSlider;
@property (weak) IBOutlet NSButton* playButton;
@property (weak) IBOutlet NSButton* prevButton;
@property (weak) IBOutlet NSButton* nextButton;
@property (weak) IBOutlet NSTextField* currentSongInfoField;
@property (weak) IBOutlet NSTextField* timeElapsedField;
@property (weak) IBOutlet NSTextField* timeRemainingField;
@property (weak) IBOutlet NSSlider* volumeSlider;

@end

@implementation SDPlayerWindowController

- (NSString*) windowNibName {
    return @"PlayerWindow";
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setNextResponder: self.playlistTableDelegate];
    [self.playlistTableDelegate setNextResponder: self.songTableDelegate];
    
    [[self window] setBackgroundColor:[NSColor colorWithDeviceWhite:0.92 alpha:1.0]];
    
    [self bindViews];
    
    if (![SDMusicPlayer sharedPlayer].stopped) {
        double delayInSeconds = 0.05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [NSApp sendAction:@selector(jumpToCurrentSong:) to:nil from:nil];
        });
    }
}

- (void) windowWillClose:(NSNotification *)notification {
    [self unbindViews];
    [self.killedDelegate playerWindowKilled:self];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[SDCoreData sharedCoreData].managedObjectContext undoManager];
}





- (NSManagedObjectContext*) managedObjectContext {
    return [SDCoreData sharedCoreData].managedObjectContext;
}







- (void) bindViews {
    [self.prevButton bind:@"enabled" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [self.nextButton bind:@"enabled" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [self.playButton bind:@"image" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"isPlaying" options:@{NSValueTransformerNameBindingOption: @"SDPlayingImageTransformer"}];
    
//    [self.volumeSlider setKnobThickness:1.0];
    [self.volumeSlider bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"player.volume" options:nil];
    [self.volumeSlider bind:@"enabled" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    
    [self.songPositionSlider bind:@"maxValue" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentSong.duration" options:nil];
    [self.songPositionSlider bind:@"currentValue" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentTime" options:nil];
    
    [self.timeElapsedField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentTime" options:@{NSValueTransformerNameBindingOption: @"SDTimeForSeconds"}];
    [self.timeRemainingField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"remainingTime" options:@{NSValueTransformerNameBindingOption: @"SDTimeForSeconds"}];
    
    [self.currentSongInfoField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentSong" options:@{NSValueTransformerNameBindingOption: @"SDSongInfoTransformer"}];
}

- (void) unbindViews {
    [self.prevButton unbind:@"enabled"];
    [self.nextButton unbind:@"enabled"];
    [self.playButton unbind:@"image"];
    
    [self.volumeSlider unbind:@"value"];
    [self.volumeSlider unbind:@"enabled"];
    
    [self.songPositionSlider unbind:@"maxValue"];
    [self.songPositionSlider unbind:@"currentValue"];
    
    [self.timeElapsedField unbind:@"value"];
    [self.timeRemainingField unbind:@"value"];
    
    [self.currentSongInfoField unbind:@"value"];
}









- (void) trackPositionMovedTo:(CGFloat)newValue {
    [[SDMusicPlayer sharedPlayer] seekToTime:newValue];
}

@end
