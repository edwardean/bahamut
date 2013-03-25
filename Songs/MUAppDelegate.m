//
//  SOAppDelegate.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "MUAppDelegate.h"

#import "MUMusicManager.h"
#import "MUPlayerWindowController.h"

@interface MUAppDelegate ()

@property NSMutableArray* playerWindowControllers;

@end

@implementation MUAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[MUMusicManager sharedMusicManager] loadUserData];
    
    [[NSImage imageNamed:@"playlist"] setTemplate:YES];
    
    self.playerWindowControllers = [NSMutableArray array];
    
    [self newPlayerWindow:nil];
}

- (void) playerWindowKilled:(id)controller {
    [self.playerWindowControllers removeObject:controller];
}

- (IBAction) newPlayerWindow:(id)sender {
    MUPlayerWindowController* player = [[MUPlayerWindowController alloc] init];
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
            [[MUMusicManager sharedMusicManager] importSongsUnderURLs:[openPanel URLs]];
        }
    }];
}

@end
