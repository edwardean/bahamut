//
//  MUPlayerWindowController.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlayerWindowController.h"

#import "SDUserDataManager.h"
#import "SDOldPlaylist.h"
#import "SDMusicPlayer.h"
#import "SDTrackPositionView.h"



#import "SDCoreData.h"
#import "SDPlaylist.h"
#import "SDUserData.h"





@interface SDOrderedSetTransformer : NSValueTransformer

@end

@implementation SDOrderedSetTransformer

+ (Class)transformedValueClass {
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    return [(NSOrderedSet *)value array];
}

- (id)reverseTransformedValue:(id)value {
	return [NSOrderedSet orderedSetWithArray:value];
}

@end



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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSongTimeDidChange:) name:SDCurrentSongTimeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSongDidChange:) name:SDCurrentSongDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatusDidChange:) name:SDPlayerStatusDidChangeNotification object:nil];
    
    [self setNextResponder: self.playlistTableDelegate];
    [self.playlistTableDelegate setNextResponder: self.songTableDelegate];
    
    [[self window] setBackgroundColor:[NSColor colorWithDeviceWhite:0.92 alpha:1.0]];
    
    [self updatePlayerViews];
    
//    self.window.styleMask = NSBorderlessWindowMask;
//    [self.window setMovableByWindowBackground:YES];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.killedDelegate playerWindowKilled:self];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[SDCoreData sharedCoreData].managedObjectContext undoManager];
}





- (NSManagedObjectContext*) managedObjectContext {
    return [SDCoreData sharedCoreData].managedObjectContext;
}










#pragma mark - Notifications





- (void) playerStatusDidChange:(NSNotification*)note {
    [self updatePlayerViews];
}

- (void) currentSongDidChange:(NSNotification*)note {
    [self updatePlayerViews];
}

NSString* timeForSeconds(CGFloat seconds) {
    CGFloat mins = seconds / 60.0;
    CGFloat secs = fmod(seconds, 60.0);
    return [NSString stringWithFormat:@"%d:%02d", (int)mins, (int)secs];
}

- (void) currentSongTimeDidChange:(NSNotification*)note {
    [self updatePlayerViews];
}





























- (void) updatePlayerViews {
    [self.nowPlayingControlsView setHidden: [[SDMusicPlayer sharedPlayer] stopped]];
    
    [self.prevButton setEnabled: ![[SDMusicPlayer sharedPlayer] stopped]];
    [self.nextButton setEnabled: ![[SDMusicPlayer sharedPlayer] stopped]];
    
    [self.playButton setTitle: [[SDMusicPlayer sharedPlayer] isPlaying] ? @"Pause" : @"Play"];
    
    SDSong* currentSong = [[SDMusicPlayer sharedPlayer] currentSong];
    
    if (currentSong) {
        NSString* trackInfo = [NSString stringWithFormat:@"%@  -  %@  -  %@", currentSong.title, currentSong.artist, currentSong.album];
        [self.currentSongInfoField setStringValue:trackInfo];
        
        CGFloat current = [SDMusicPlayer sharedPlayer].currentTime;
        CGFloat max = currentSong.duration;
        CGFloat left = max - current;
        
        [self.timeElapsedField setStringValue: timeForSeconds(current)];
        [self.timeRemainingField setStringValue: timeForSeconds(left)];
        
        self.songPositionSlider.maxValue = currentSong.duration;
        self.songPositionSlider.currentValue = current;
    }
}




















- (IBAction) jumpToCurrentSong:(id)sender {
    if ([SDMusicPlayer sharedPlayer].stopped)
        return;
    
//    [self.playlistsViewController selectPlaylist: [SDMusicPlayer sharedPlayer].currentPlaylist];
//    [self.currentSongListViewController selectSongs: @[[SDMusicPlayer sharedPlayer].currentSong]];
}












- (void) trackPositionMovedTo:(CGFloat)newValue {
    [[SDMusicPlayer sharedPlayer] seekToTime:newValue];
}

@end
