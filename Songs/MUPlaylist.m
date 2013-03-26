//
//  MUPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "MUPlaylist.h"

#import "MUMusicManager.h"

@interface MUPlaylist ()

@property NSString* realTitle;

@end

@implementation MUPlaylist

- (id) init {
    if (self = [super init]) {
        self.realTitle = @"New Playlist";
    }
    return self;
}

- (BOOL) isMaster {
    return NO;
}

- (BOOL) isLeaf {
    return YES;
}

- (NSArray*) songs {
    return @[];
}

- (void) setTitle:(NSString *)title {
    self.realTitle = title;
    [MUMusicManager userDataChanged];
}

- (NSString*) title {
    return self.realTitle;
}

@end
