//
//  Playlist.m
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "Playlist.h"
#import "Song.h"


@implementation Playlist

@dynamic repeats;
@dynamic shuffles;
@dynamic title;
@dynamic songs;

- (BOOL) isMasterPlaylist {
    return NO;
}

@end
