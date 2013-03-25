//
//  SOSongsTableController.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOSongsTableController.h"

#import "SOSong.h"
#import "SOSongManager.h"

@implementation SOSongsTableController

- (SOSongManager*) songManager {
    return [SOSongManager sharedSongManager];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [[SOSongManager sharedSongManager].selectedPlaylist.songs count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    SOSong* song = [[SOSongManager sharedSongManager].selectedPlaylist.songs objectAtIndex:rowIndex];
    
    if ([[aTableColumn identifier] isEqualToString:@"title"]) {
        return [song title];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"album"]) {
        return [song album];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"artist"]) {
        return [song artist];
    }
    
    return @"<unknown column>";
}

@end
