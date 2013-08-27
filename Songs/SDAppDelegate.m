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

#import "SDVideoWindowController.h"

#import "MASShortcut+UserDefaults.h"

@interface SDAppDelegate ()

@property NSMutableArray* playerWindowControllers;
@property SDMediaKeyHijacker* mediaKeyHijacker;
@property IBOutlet SUUpdater* updater;

@property SDPreferencesWindowController* preferencesWindowController;

@property IBOutlet SDStatusItemController* statusItemController;
@property SDDockIconController* dockIconController;

@property SDVideoWindowController* videoWindowController;

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
    
    [self bindGlobalHotkey];
    
    [self newPlayerWindow:nil];
}

- (void) bindGlobalHotkey {
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:SDPrefBringToFrontHotkeyKey handler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSApp activateIgnoringOtherApps:YES];
            [self newOrExistingPlayerWindow:nil];
        });
    }];
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

- (IBAction) showVideoWindow:(id)sender {
    if (self.videoWindowController == nil) {
        self.videoWindowController = [[SDVideoWindowController alloc] init];
        __weak SDAppDelegate* _self = self;
        self.videoWindowController.died = ^{
            _self.videoWindowController = nil;
        };
    }
    
    [self.videoWindowController showWindow:sender];
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
        [self newOrExistingPlayerWindow:nil];
    }
    else {
        if ([[SDMusicPlayer sharedPlayer] isPlaying])
            [[SDMusicPlayer sharedPlayer] pause];
        else
            [[SDMusicPlayer sharedPlayer] resume];
    }
}

- (IBAction) rewindFiveSec:(id)sender {
    [[SDMusicPlayer sharedPlayer] fastRewind];
}

- (IBAction) forwardFiveSec:(id)sender {
    [[SDMusicPlayer sharedPlayer] fastForward];
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

- (IBAction) newOrExistingPlayerWindow:(id)sender {
    if ([self.playerWindowControllers count] == 0)
        [self newPlayerWindow:sender];
    else
        [[self.playerWindowControllers lastObject] showWindow:self];
}

- (IBAction) newPlayerWindow:(id)sender {
    SDPlayerWindowController* player = [[SDPlayerWindowController alloc] init];
    player.killedDelegate = self;
    [self.playerWindowControllers addObject:player];
    [player showWindow:self];
}

- (void) application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    NSMutableArray *urls = [NSMutableArray array];
    for (NSString* filename in filenames) {
        [urls addObject: [NSURL fileURLWithPath:filename]];
    }
    [SDImporter importSongsUnderURLs:urls];
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
