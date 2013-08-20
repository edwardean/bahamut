//
//  SOAppDelegate.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDAppDelegate.h"

#import "SDUserDataManager.h"
#import "SDPlayerWindowController.h"

@interface SDAppDelegate ()

@property NSMutableArray* playerWindowControllers;

@end

@implementation SDAppDelegate

- (void) applicationWillFinishLaunching:(NSNotification *)notification {
    [[SDUserDataManager sharedMusicManager] loadUserData];
    
    self.playerWindowControllers = [NSMutableArray array];
}

- (BOOL) applicationOpenUntitledFile:(NSApplication *)sender {
    [self newPlayerWindow:nil];
    return YES;
}

- (void) playerWindowKilled:(id)controller {
    [self.playerWindowControllers removeObject:controller];
}

- (IBAction) importFromiTunes:(id)sender {
    [SDSharedData() importFromiTunes];
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
            [[SDUserDataManager sharedMusicManager] importSongsUnderURLs:[openPanel URLs]];
        }
    }];
}

@end
