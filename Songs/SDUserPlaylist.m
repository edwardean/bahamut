//
//  MUPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDUserPlaylist.h"

#import "SDUserDataManager.h"

@interface SDUserPlaylist ()

@property NSMutableArray* cachedSongs;
@property NSString* realTitle;
@property BOOL realDoesShuffle;
@property BOOL realDoesRepeat;

@end

@implementation SDUserPlaylist

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.realTitle = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"title"];
        self.realDoesShuffle = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesShuffle"] boolValue];
        self.realDoesRepeat = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesRepeat"] boolValue];
        
        NSArray* songUUIDs = [aDecoder decodeObjectOfClass:[NSArray self] forKey:@"songUUIDs"];
        
        NSArray* allSongs = [[SDUserDataManager sharedMusicManager] allSongs];
        
        for (NSString* uuid in songUUIDs) {
            NSUInteger songIndex = [allSongs indexOfObjectPassingTest:^BOOL(SDSong* otherSong, NSUInteger idx, BOOL *stop) {
                return [[otherSong valueForKey:@"uuid"] isEqualToString:uuid];
            }];
            
            if (songIndex != NSNotFound) {
                SDSong* song = [allSongs objectAtIndex:songIndex];
                [self.cachedSongs addObject:song];
            }
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self.cachedSongs valueForKey:@"uuid"] forKey:@"songUUIDs"];
    [aCoder encodeObject:self.realTitle forKey:@"title"];
    [aCoder encodeObject:@(self.realDoesShuffle) forKey:@"doesShuffle"];
    [aCoder encodeObject:@(self.realDoesRepeat) forKey:@"doesRepeat"];
}

- (id) init {
    if (self = [super init]) {
        self.cachedSongs = [NSMutableArray array];
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
    [SDUserDataManager userDataChanged];
}

- (NSString*) title {
    return self.realTitle;
}

- (void) addSongs:(NSArray*)songs {
    // ...
    
    [SDUserDataManager userDataChanged];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL) doesRepeat {
    return self.realDoesRepeat;
}

- (BOOL) doesShuffle {
    return self.realDoesShuffle;
}

- (void) setDoesRepeat:(BOOL)doesRepeat {
    self.realDoesRepeat = doesRepeat;
    [SDUserDataManager userDataChanged];
}

- (void) setDoesShuffle:(BOOL)doesShuffle {
    self.realDoesShuffle = doesShuffle;
    [SDUserDataManager userDataChanged];
}

@end
