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

@end

@implementation SDMasterPlaylist

@synthesize isShuffle;
@synthesize isRepeat;

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

- (void) loadSongs:(NSArray*)songs {
    [self.cachedSongs addObjectsFromArray:songs];
}

@end
