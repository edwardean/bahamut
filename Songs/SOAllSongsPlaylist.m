//
//  SOAllSongsPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOAllSongsPlaylist.h"

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
        self.cachedSongs = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"cachedSongs"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cachedSongs forKey:@"cachedSongs"];
}

- (void) addSong:(SOSong*)song {
    if ([[self.cachedSongs valueForKeyPath:@"url"] containsObject: song.url])
        return;
    
    [self.cachedSongs addObject:song];
}

@end
