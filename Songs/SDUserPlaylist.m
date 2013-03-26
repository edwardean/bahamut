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

@end

@implementation SDUserPlaylist

@synthesize isShuffle;
@synthesize isRepeat;

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.realTitle = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"title"];
        
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

@end
