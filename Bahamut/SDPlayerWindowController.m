//
//  MUPlayerWindowController.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlayerWindowController.h"

#import "SDMusicPlayer.h"

#import "SDCoreData.h"

#import "SDPlaylistTableDelegate.h"
#import "SDSongTableDelegate.h"

#import "SDImporter.h"



@interface SDPlayerWindowController ()

@property IBOutlet SDPlaylistTableDelegate* playlistTableDelegate;
@property IBOutlet SDSongTableDelegate* songTableDelegate;

@property (weak) IBOutlet NSView* nowPlayingControlsView;
@property (weak) IBOutlet NSSlider* songPositionSlider;
@property (weak) IBOutlet NSButton* playButton;
@property (weak) IBOutlet NSButton* prevButton;
@property (weak) IBOutlet NSButton* nextButton;
@property (weak) IBOutlet NSTextField* currentSongInfoField;
@property (weak) IBOutlet NSTextField* timeElapsedField;
@property (weak) IBOutlet NSTextField* timeRemainingField;
@property (weak) IBOutlet NSSlider* volumeSlider;

@property NSBox* dragIndicatorBox;

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
    
    [[self window] registerForDraggedTypes:@[NSFilenamesPboardType]];
    
    [self bindViews];
    
    if (![SDMusicPlayer sharedPlayer].stopped) {
        NSDisableScreenUpdates();
        
        double delayInSeconds = 0.05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [NSApp sendAction:@selector(jumpToCurrentSong:) to:nil from:nil];
            
            dispatch_async(dispatch_get_current_queue(), ^{
                NSEnableScreenUpdates();
            });
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







// import via dragging into window

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender {
    self.dragIndicatorBox = [[NSBox alloc] init];
    self.dragIndicatorBox.boxType = NSBoxCustom;
    self.dragIndicatorBox.borderWidth = 0.0;
    self.dragIndicatorBox.fillColor = [[NSColor blackColor] colorWithAlphaComponent:0.2];
    [self.dragIndicatorBox setFrame: [[[self window] contentView] bounds]];
    
    [[[self window] contentView] addSubview: self.dragIndicatorBox];
    
    return NSDragOperationLink;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender {
    [self.dragIndicatorBox removeFromSuperview];
    self.dragIndicatorBox = nil;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
    NSArray *paths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    [SDImporter importSongsUnderPaths:paths];
    
    return YES;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender {
    [self.dragIndicatorBox removeFromSuperview];
    self.dragIndicatorBox = nil;
}







- (NSManagedObjectContext*) managedObjectContext {
    return [SDCoreData sharedCoreData].managedObjectContext;
}







- (void) bindViews {
    [self.prevButton bind:@"enabled" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [self.nextButton bind:@"enabled" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [self.playButton bind:@"image" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"isPlaying" options:@{NSValueTransformerNameBindingOption: @"SDPlayingImageTransformer"}];
    
    [self.volumeSlider bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"player.volume" options:nil];
    
    [self.songPositionSlider bind:@"maxValue" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentSong.duration" options:nil];
    [self.songPositionSlider bind:@"doubleValue" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentTime" options:nil];
    
    [self.timeElapsedField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentTime" options:@{NSValueTransformerNameBindingOption: @"SDTimeForSeconds"}];
    [self.timeRemainingField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"remainingTime" options:@{NSValueTransformerNameBindingOption: @"SDTimeForSeconds"}];
    
    [self.currentSongInfoField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentSong" options:@{NSValueTransformerNameBindingOption: @"SDSongInfoTransformer"}];
}

- (void) unbindViews {
    [self.prevButton unbind:@"enabled"];
    [self.nextButton unbind:@"enabled"];
    [self.playButton unbind:@"image"];
    
    [self.volumeSlider unbind:@"value"];
    
    [self.songPositionSlider unbind:@"maxValue"];
    [self.songPositionSlider unbind:@"doubleValue"];
    
    [self.timeElapsedField unbind:@"value"];
    [self.timeRemainingField unbind:@"value"];
    
    [self.currentSongInfoField unbind:@"value"];
}









- (IBAction) trackPositionMovedTo:(id)sender {
    [[SDMusicPlayer sharedPlayer] seekToTime:[self.songPositionSlider doubleValue]];
}

@end
