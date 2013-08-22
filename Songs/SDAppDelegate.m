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
#import <Sparkle/Sparkle.h>

@interface SDAppDelegate ()

@property NSMutableArray* playerWindowControllers;
@property SDMediaKeyHijacker* mediaKeyHijacker;
@property IBOutlet SUUpdater* updater;

@end

@implementation SDAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)notification {
    [[SDCoreData sharedCoreData] setup];
    [SDCachedDrawing drawThings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaKeyPressedPlayPause:) name:SDMediaKeyPressedPlayPause object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaKeyPressedNext:) name:SDMediaKeyPressedNext object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaKeyPressedPrevious:) name:SDMediaKeyPressedPrevious object:nil];
    
    self.mediaKeyHijacker = [[SDMediaKeyHijacker alloc] init];
    [self.mediaKeyHijacker hijack];
    
    self.playerWindowControllers = [NSMutableArray array];
    
    [self newPlayerWindow:nil];
}

- (void) applicationWillTerminate:(NSNotification *)notification {
    [[SDCoreData sharedCoreData] save];
}

- (void) mediaKeyPressedPlayPause:(NSNotification*)note {
    
    
//    static BOOL wut;
//    
//    if (wut) {
//        ProcessSerialNumber psn = { 0, kCurrentProcess };
//        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
//        ShowHideProcess(&psn, 1);
//        SetFrontProcess(&psn);
//    }
//    else {
//        NSArray* wins = [[NSApp windows] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isVisible = YES"]];
//        
//        for (NSWindow* win in wins) {
//            [win setCanHide: NO];
//        }
//        
//        ProcessSerialNumber psn = { 0, kCurrentProcess };
//        TransformProcessType(&psn, kProcessTransformToUIElementApplication);
//        ShowHideProcess(&psn, 1);
//        SetFrontProcess(&psn);
//        
//        double delayInSeconds = 0.25;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            for (NSWindow* win in wins) {
//                [win setCanHide: YES];
//            }
//        });
//    }
//    
//    wut = !wut;
    
    
    
    
    [NSApp sendAction:@selector(playPause:) to:nil from:nil];
}

- (IBAction) showPreferencesWindow:(id)sender {
    // TODO
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
