//
//  MUAllSongsPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDMasterPlaylist.h"

#import "SDSong.h"

#import "SDUserDataManager.h"

@interface SDMasterPlaylist ()

@property NSMutableArray* cachedSongs;

@property BOOL realDoesShuffle;
@property BOOL realDoesRepeat;

@end

@implementation SDMasterPlaylist

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.cachedSongs = [aDecoder decodeObjectOfClass:[NSMutableArray self] forKey:@"cachedSongs"];
        self.realDoesShuffle = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesShuffle"] boolValue];
        self.realDoesRepeat = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesRepeat"] boolValue];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cachedSongs forKey:@"cachedSongs"];
    [aCoder encodeObject:@(self.realDoesShuffle) forKey:@"doesShuffle"];
    [aCoder encodeObject:@(self.realDoesRepeat) forKey:@"doesRepeat"];
}

- (id) init {
    if (self = [super init]) {
        self.cachedSongs = [NSMutableArray array];
    }
    return self;
}

- (BOOL) isMaster {
    return YES;
}

- (BOOL) isLeaf {
    return YES;
}

- (NSString*) title {
    return @"All Songs";
}

- (void) addSongsWithURLs:(NSArray*)urls {
    [self willChangeValueForKey:@"cachedSongs"];
    
    for (NSURL* url in urls) {
        if ([[self.cachedSongs valueForKeyPath:@"url"] containsObject: url])
            continue;
        
        SDSong* song = [[SDSong alloc] init];
        song.url = [url fileReferenceURL];
        
        [self.cachedSongs addObject:song];
    }
    
    [self didChangeValueForKey:@"cachedSongs"];
    
    [SDUserDataManager userDataChanged];
}

+ (NSSet*) keyPathsForValuesAffectingSongs {
    return [NSSet setWithArray:@[@"cachedSongs"]];
}

- (NSArray*) songs {
    return [self.cachedSongs copy];
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
