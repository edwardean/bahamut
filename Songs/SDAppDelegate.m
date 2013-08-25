//
//  SOAppDelegate.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDAppDelegate.h"

#import "SDPlayerWindowController.h"

#import "SDMediaKeyHijacker.h"
#import "SDMusicPlayer.h"
#import "SDImporter.h"
#import "SDCoreData.h"
#import "SDCachedDrawing.h"
#import "SDPreferencesWindowController.h"
#import <Sparkle/Sparkle.h>

#import "SDStatusItemController.h"
#import "SDDockIconController.h"

@interface SDAppDelegate ()

@property NSMutableArray* playerWindowControllers;
@property SDMediaKeyHijacker* mediaKeyHijacker;
@property IBOutlet SUUpdater* updater;

@property SDPreferencesWindowController* preferencesWindowController;

@property IBOutlet SDStatusItemController* statusItemController;
@property SDDockIconController* dockIconController;

@end

@implementation SDAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)notification {
    [self registerDefaults];
    
    [[SDCoreData sharedCoreData] setup];
    [SDCachedDrawing drawThings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefShowMenuItemChanged:) name:SDPrefShowMenuItemChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefShowDockIconChanged:) name:SDPrefShowDockIconChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaKeyPressedPlayPause:) name:SDMediaKeyPressedPlayPause object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaKeyPressedNext:) name:SDMediaKeyPressedNext object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaKeyPressedPrevious:) name:SDMediaKeyPressedPrevious object:nil];
    
    self.mediaKeyHijacker = [[SDMediaKeyHijacker alloc] init];
    [self.mediaKeyHijacker hijack];
    
    self.playerWindowControllers = [NSMutableArray array];
    
    self.dockIconController = [[SDDockIconController alloc] init];
    [self.dockIconController toggleDockIcon];
    
    [self.statusItemController toggleItem];
    
    [self newPlayerWindow:nil];
}

- (void) registerDefaults {
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DefaultValues" ofType:@"plist"];
	NSDictionary *initialValues = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	[[NSUserDefaults standardUserDefaults] registerDefaults:initialValues];
}

- (void) prefShowDockIconChanged:(NSNotification*)note {
    [self.dockIconController toggleDockIcon];
}

- (void) prefShowMenuItemChanged:(NSNotification*)note {
    [self.statusItemController toggleItem];
}

- (void) applicationWillTerminate:(NSNotification *)notification {
    [[SDCoreData sharedCoreData] save];
}

- (void) mediaKeyPressedPlayPause:(NSNotification*)note {
    [NSApp sendAction:@selector(playPause:) to:nil from:nil];
}

- (IBAction) showAboutWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}

- (IBAction) showPreferencesWindow:(id)sender {
    if (self.preferencesWindowController == nil)
        self.preferencesWindowController = [[SDPreferencesWindowController alloc] init];
    
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesWindowController showWindow:self];
}

- (void) mediaKeyPressedNext:(NSNotification*)note {
    [[SDMusicPlayer sharedPlayer] nextSong];
}

- (void) mediaKeyPressedPrevious:(NSNotification*)note {
    [[SDMusicPlayer sharedPlayer] previousSong];
}

- (IBAction) playPause:(id)sender {
    if ([SDMusicPlayer sharedPlayer].stopped) {
        [NSApp activateIgnoringOtherApps:YES];
        [self newPlayerWindow:nil];
    }
    else {
        if ([[SDMusicPlayer sharedPlayer] isPlaying])
            [[SDMusicPlayer sharedPlayer] pause];
        else
            [[SDMusicPlayer sharedPlayer] resume];
    }
}

- (IBAction) stopSong:(id)sender {
    [[SDMusicPlayer sharedPlayer] stop];
}

- (IBAction) nextSong:(id)sender {
    [[SDMusicPlayer sharedPlayer] nextSong];
}

- (IBAction) prevSong:(id)sender {
    [[SDMusicPlayer sharedPlayer] previousSong];
}

- (BOOL) applicationOpenUntitledFile:(NSApplication *)sender {
    if (self.playerWindowControllers == nil)
        return NO;
    
    [self newPlayerWindow:nil];
    return YES;
}

- (void) playerWindowKilled:(id)controller {
    [self.playerWindowControllers removeObject:controller];
}

- (IBAction) importFromiTunes:(id)sender {
    [SDImporter importFromiTunes];
}

- (IBAction) newPlayerWindow:(id)sender {
    SDPlayerWindowController* player = [[SDPlayerWindowController alloc] init];
    player.killedDelegate = self;
    [self.playerWindowControllers addObject:player];
    [player showWindow:self];
}

- (IBAction) importSongs:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:YES];
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [SDImporter importSongsUnderURLs:[openPanel URLs]];
        }
    }];
}

@end
