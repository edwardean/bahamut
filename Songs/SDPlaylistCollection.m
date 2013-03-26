//
//  MUPlaylistNode.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylistCollection.h"

@implementation SDPlaylistCollection

- (id) init {
    if (self = [super init]) {
        self.playlists = [NSMutableArray array];
    }
    return self;
}

- (BOOL) isMaster {
    return NO;
}

- (BOOL) isLeaf {
    return NO;
}

- (NSString*) title {
    return @"not used...";
}

@end
