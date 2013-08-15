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
        NSArray* allSongs = [[SDUserDataManager sharedMusicManager] allSongs];
        
        for (NSString* uuid in songUUIDs) {
            NSUInteger songIndex = [allSongs indexOfObjectPassingTest:^BOOL(SDSong* otherSong, NSUInteger idx, BOOL *stop) {
                return [[otherSong valueForKey:@"uuid"] isEqualToString:uuid];
            }];
            
            if (songIndex != NSNotFound) {
                SDSong* song = [allSongs objectAtIndex:songIndex];
                [self.songs addObject:song];
            }
        }
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
    for (SDSong* song in songs) {
        if (![self.songs containsObject:song])
            [self.songs addObject:song];
    }
}

- (void) playSong:(SDSong*)song {
    self.isPlaying = YES;
}

- (void) pause {
    self.isPlaying = NO;
}

@end
