//
//  MUPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylist.h"

#import "SDMusicManager.h"

@interface SDPlaylist ()

@property NSString* realTitle;

@end

@implementation SDPlaylist

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
    [SDMusicManager userDataChanged];
}

- (NSString*) title {
    return self.realTitle;
}

@end
