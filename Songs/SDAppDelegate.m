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

#import "SDMediaKeyHijacker.h"
#import "SDMusicPlayer.h"



#import "SDImporter.h"




#import "SDCoreData.h"
#import "SDUserData.h"
#import "SDPlaylist.h"
#import "SDSong.h"


@interface SDAppDelegate ()

@property NSMutableArray* playerWindowControllers;
@property SDMediaKeyHijacker* mediaKeyHijacker;

@end

@implementation SDAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)notification {
    [[SDCoreData sharedCoreData] setup];
    
//    SDPlaylist* playlist = [[[SDUserData sharedUserData] playlists] firstObject];
//    playlist.title = @"haha";
    
//    NSLog(@"%@", playlist);
    
//    {
//        NSUInteger count = [[SDCoreData sharedCoreData].managedObjectContext countForFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"SDUserData"] error:NULL];
//        NSLog(@"%lu", count);
//    }
//    
//    SDPlaylist* playlist = [[SDPlaylist alloc] initWithEntity:[NSEntityDescription entityForName:@"SDPlaylist" inManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext] insertIntoManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext];
//    
//    NSLog(@"%@", playlist);
//    
//    [[SDUserData sharedUserData] addPlaylistsObject: playlist];
//    
//    NSLog(@"%@", [SDUserData sharedUserData]);
//    
//    {
//        NSUInteger count = [[SDCoreData sharedCoreData].managedObjectContext countForFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"SDUserData"] error:NULL];
//        NSLog(@"%lu", count);
//    }
//    
//    NSLog(@"%@", [SDUserData sharedUserData]);
//    
//    {
//        NSUInteger count = [[SDCoreData sharedCoreData].managedObjectContext countForFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"SDUserData"] error:NULL];
//        NSLog(@"%lu", count);
//    }
    
    
    
    
    
    
//    NSManagedObjectContext* ctx = [[SDCoreData sharedCoreData] managedObjectContext];
//    
//    
//    
//    NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
//    [req setRelationshipKeyPathsForPrefetching:@[@"title"]];
//    
//    NSError* __autoreleasing error;
//    NSArray* results = [ctx executeFetchRequest:req error:&error];
//    
//    NSLog(@"%@", results);
//    NSLog(@"%@", [[results lastObject] title]);
//    NSLog(@"%@", error);
    
    
    
    
    
//    Song* s = [[Song alloc] initWithEntity:[NSEntityDescription entityForName:@"Song" inManagedObjectContext:ctx]
//            insertIntoManagedObjectContext:ctx];
//    
//    s.title = @"foobar";
    
//    [[SDCoreData sharedCoreData] save];
    
    
//    return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaKeyPressedPlayPause:) name:SDMediaKeyPressedPlayPause object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaKeyPressedNext:) name:SDMediaKeyPressedNext object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaKeyPressedPrevious:) name:SDMediaKeyPressedPrevious object:nil];
    
    self.mediaKeyHijacker = [[SDMediaKeyHijacker alloc] init];
    [self.mediaKeyHijacker hijack];
    
//    [[SDUserDataManager sharedMusicManager] loadUserData];
    
    self.playerWindowControllers = [NSMutableArray array];
    
    [self newPlayerWindow:nil];
}

- (void) mediaKeyPressedPlayPause:(NSNotification*)note {
    [NSApp sendAction:@selector(playPause:) to:nil from:nil];
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
//    [self.playerWindowControllers removeObject:controller];
}

- (IBAction) importFromiTunes:(id)sender {
//    [SDImporter importFromiTunes];
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
