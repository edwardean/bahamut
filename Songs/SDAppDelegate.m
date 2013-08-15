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


#import "SDSong.h"


@interface SDAppDelegate ()

@property NSMutableArray* playerWindowControllers;

@end

@implementation SDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSImage imageNamed:@"playlist"] setTemplate:YES];
    
//    SDSong* song = [[SDSong alloc] init];
//    song.url = [NSURL fileURLWithPath:@"/Users/sdegutis/Music/iTunes/iTunes Media/Music/Tool/Lateralus/05 Schism.m4a"];
//    
//    NSLog(@"%f", [song duration]);
    
    
//    [[SDUserDataManager sharedMusicManager] loadUserData];
    
    
    self.playerWindowControllers = [NSMutableArray array];
    [self newPlayerWindow:nil];
}

- (void) playerWindowKilled:(id)controller {
    [self.playerWindowControllers removeObject:controller];
}

- (IBAction) newPlayerWindow:(id)sender {
    SDPlayerWindowController* player = [[SDPlayerWindowController alloc] init];
    player.killedDelegate = self;
    [self.playerWindowControllers addObject:player];
    [player showWindow:self];
}

- (IBAction) importSongs:(id)sender {
//    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
//    
//    [openPanel setCanChooseDirectories:YES];
//    [openPanel setCanChooseFiles:YES];
//    [openPanel setAllowsMultipleSelection:YES];
//    
//    [openPanel beginWithCompletionHandler:^(NSInteger result) {
//        if (result == NSFileHandlingPanelOKButton) {
//            [[SDUserDataManager sharedMusicManager] importSongsUnderURLs:[openPanel URLs]];
//        }
//    }];
}

@end
