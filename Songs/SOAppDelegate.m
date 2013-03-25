//
//  SOAppDelegate.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOAppDelegate.h"

#import "SOPlayerWindowController.h"
#import "SOSongManager.h"

@interface SOAppDelegate ()

@property SOPlayerWindowController* playerWindowController;

@end

@implementation SOAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[SOSongManager sharedSongManager] loadData];
    
    self.playerWindowController = [[SOPlayerWindowController alloc] init];
    [self.playerWindowController showWindow:self];
}

- (IBAction) makeNewPlaylist:(id)sender {
    [self.playerWindowController makeNewPlaylist];
}

- (IBAction) importSongs:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:YES];
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [[SOSongManager sharedSongManager] importSongsUnderURLs:[openPanel URLs]];
        }
    }];
}

@end
