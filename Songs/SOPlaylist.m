//
//  SOPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOPlaylist.h"

#import "SOSongManager.h"

@interface SOPlaylist ()

@property NSMutableArray* cachedSongs;
@property NSString* realTitle;

@end

@implementation SOPlaylist

@dynamic songs;

- (id) init {
    if (self = [super init]) {
        self.cachedSongs = [NSMutableArray array];
        self.realTitle = @"New Playlist";
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.realTitle = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"title"];
        
        NSArray* songUUIDs = [aDecoder decodeObjectOfClass:[NSArray self] forKey:@"songUUIDs"];
        
        NSArray* allSongs = [SOSongManager sharedSongManager].allSongsPlaylist.songs;
        
        for (NSString* uuid in songUUIDs) {
            NSUInteger songIndex = [allSongs indexOfObjectPassingTest:^BOOL(SOSong* otherSong, NSUInteger idx, BOOL *stop) {
                return [[otherSong valueForKey:@"uuid"] isEqualToString:uuid];
            }];
            
            if (songIndex != NSNotFound) {
                SOSong* song = [allSongs objectAtIndex:songIndex];
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

- (void) addSong:(SOSong*)song {
    [self.cachedSongs addObject:song];
    [SOSongManager userDataDidChange];
}

- (NSString*) title {
    return self.realTitle;
}

- (void) setTitle:(NSString *)title {
    self.realTitle = title;
    [SOSongManager userDataDidChange];
}

+ (NSSet*) keyPathsForValuesAffectingSongs {
    return [NSSet setWithArray:@[@"cachedSongs"]];
}

- (NSArray*) songs {
    return [self.cachedSongs copy];
}

@end
