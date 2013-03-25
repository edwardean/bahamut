//
//  MUPlaylistNode.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "MUPlaylistNode.h"

@implementation MUPlaylistNode

- (id) init {
    if (self = [super init]) {
        self.playlists = [NSMutableArray array];
    }
    return self;
}

@end
