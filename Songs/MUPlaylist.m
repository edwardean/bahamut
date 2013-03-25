//
//  MUPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "MUPlaylist.h"

@implementation MUPlaylist

- (id) init {
    if (self = [super init]) {
        self.title = @"New Playlist";
    }
    return self;
}

- (NSArray*) playlists {
    return nil;
}

- (NSArray*) songs {
    return @[];
}

@end
