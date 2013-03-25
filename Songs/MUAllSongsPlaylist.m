//
//  MUAllSongsPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "MUAllSongsPlaylist.h"

#import "SOSong.h"

@interface MUAllSongsPlaylist ()

@property NSMutableArray* cachedSongs;

@end

@implementation MUAllSongsPlaylist

- (id) init {
    if (self = [super init]) {
        self.cachedSongs = [NSMutableArray array];
    }
    return self;
}

- (BOOL) isMaster {
    return YES;
}

- (NSString*) title {
    return @"All Songs";
}

- (void) addSongsWithURLs:(NSArray*)urls {
    for (NSURL* url in urls) {
        if ([[self.cachedSongs valueForKeyPath:@"url"] containsObject: url])
            continue;
        
        SOSong* song = [[SOSong alloc] init];
        song.url = url;
        
        [self addSong:song];
    }
}

- (void) addSong:(SOSong*)song {
    [self willChangeValueForKey:@"cachedSongs"];
    [self.cachedSongs addObject:song];
    [self didChangeValueForKey:@"cachedSongs"];
}

+ (NSSet*) keyPathsForValuesAffectingSongs {
    return [NSSet setWithArray:@[@"cachedSongs"]];
}

- (NSArray*) songs {
    return [self.cachedSongs copy];
}

@end
