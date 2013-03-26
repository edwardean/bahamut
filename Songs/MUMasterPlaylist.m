//
//  MUAllSongsPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "MUMasterPlaylist.h"

#import "SOSong.h"

//#import "MAKVONotificationCenter.h"

@interface MUMasterPlaylist ()

@property NSMutableArray* cachedSongs;

@end

@implementation MUMasterPlaylist

- (id) init {
    if (self = [super init]) {
        self.cachedSongs = [NSMutableArray array];
        
//        [[MAKVONotificationCenter defaultCenter] observeTarget:self
//                                                       keyPath:@"allSongsPlaylist.songs"
//                                                       options:0
//                                                         block:^(MAKVONotification *notification) {
//                                                             NSLog(@"songs changed");
//                                                         }];
        
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
