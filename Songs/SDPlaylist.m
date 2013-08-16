//
//  SDPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 8/15/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylist.h"

#import "SDUserDataManager.h"

@implementation SDPlaylist

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id) init {
    if (self = [super init]) {
        self.songs = [NSMutableArray array];
        self.title = @"New Playlist";
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.title = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"title"];
        self.shuffles = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesShuffle"] boolValue];
        self.repeats = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesRepeat"] boolValue];
        
        NSArray* songUUIDs = [aDecoder decodeObjectOfClass:[NSArray self] forKey:@"songUUIDs"];
        [self.songs addObjectsFromArray:[SDUserDataManager songsForUUIDs:songUUIDs]];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self.songs valueForKey:@"uuid"] forKey:@"songUUIDs"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:@(self.shuffles) forKey:@"doesShuffle"];
    [aCoder encodeObject:@(self.repeats) forKey:@"doesRepeat"];
}

- (void) addSongs:(NSArray*)songs {
    NSMutableArray* songsToAdd = [songs mutableCopy];
    [songsToAdd removeObjectsInArray: self.songs];
    [self.songs addObjectsFromArray: songsToAdd];
}

@end
