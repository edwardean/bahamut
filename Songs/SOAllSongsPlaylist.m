//
//  SOAllSongsPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOAllSongsPlaylist.h"

#import "SOSongManager.h"

@interface SOAllSongsPlaylist ()

@property NSMutableArray* cachedSongs;

@end

@implementation SOAllSongsPlaylist

- (NSString*) title {
    return @"All Songs";
}

- (id) init {
    if (self = [super init]) {
        self.cachedSongs = [NSMutableArray array];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.cachedSongs = [aDecoder decodeObjectOfClass:[NSMutableArray self] forKey:@"cachedSongs"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cachedSongs forKey:@"cachedSongs"];
}

- (void) addSongsWithURLs:(NSArray*)urls {
    for (NSURL* url in urls) {
        if ([[self.cachedSongs valueForKeyPath:@"url"] containsObject: url])
            continue;
        
        SOSong* song = [[SOSong alloc] init];
        song.url = url;
        
        [self addSong:song];
    }
    
    [SOSongManager userDataDidChange];
}

- (void) addSong:(SOSong*)song {
    [self.cachedSongs addObject:song];
}

+ (NSSet*) keyPathsForValuesAffectingSongs {
    return [NSSet setWithArray:@[@"cachedSongs"]];
}

- (NSArray*) songs {
    return [self.cachedSongs copy];
}

@end
