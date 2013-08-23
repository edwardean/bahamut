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
//    [self.nowPlayingControlsView bind:@"hidden" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:nil];
    
    [self.prevButton bind:@"enabled" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [self.nextButton bind:@"enabled" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    
    [self.songPositionSlider bind:@"maxValue" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentSong.duration" options:nil];
    [self.songPositionSlider bind:@"currentValue" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentTime" options:nil];
    
    [self.timeElapsedField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentTime" options:@{NSValueTransformerNameBindingOption: @"SDTimeForSeconds"}];
    [self.timeRemainingField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"remainingTime" options:@{NSValueTransformerNameBindingOption: @"SDTimeForSeconds"}];
    
    [self.currentSongInfoField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentSong" options:@{NSValueTransformerNameBindingOption: @"SDSongInfoTransformer"}];
    
    [self.playButton bind:@"image" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"isPlaying" options:@{NSValueTransformerNameBindingOption: @"SDPlayingImageTransformer"}];
    [self.playButton bind:@"alternateImage" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"isPlaying" options:@{NSValueTransformerNameBindingOption: @"SDPlayingAlternateImageTransformer"}];
    
    [self.prevButton bind:@"image" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: @"SDCanGoPrevImageTransformer"}];
    [self.prevButton bind:@"alternateImage" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: @"SDCanGoPrevAlternateImageTransformer"}];
    
    [self.nextButton bind:@"image" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: @"SDCanGoNextImageTransformer"}];
    [self.nextButton bind:@"alternateImage" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: @"SDCanGoNextAlternateImageTransformer"}];
}

- (void) unbindViews {
//    [self.nowPlayingControlsView unbind:@"hidden"];
    
    [self.prevButton unbind:@"enabled"];
    [self.nextButton unbind:@"enabled"];
    
    [self.songPositionSlider unbind:@"maxValue"];
    [self.songPositionSlider unbind:@"currentValue"];
    
    [self.timeElapsedField unbind:@"value"];
    [self.timeRemainingField unbind:@"value"];
    
    [self.currentSongInfoField unbind:@"value"];
    
    [self.playButton unbind:@"image"];
    [self.playButton unbind:@"alternateImage"];
    
    [self.prevButton unbind:@"image"];
    [self.prevButton unbind:@"alternateImage"];
    
    [self.nextButton unbind:@"image"];
    [self.nextButton unbind:@"alternateImage"];
}









- (void) trackPositionMovedTo:(CGFloat)newValue {
    [[SDMusicPlayer sharedPlayer] seekToTime:newValue];
}

@end
