//
//  SDPlaylist.m
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylist.h"
#import "SDSong.h"
#import "SDUserData.h"


@implementation SDPlaylist

@dynamic title;
@dynamic shuffles;
@dynamic repeats;
@dynamic isMaster;
@dynamic userData;
@dynamic songs;
@dynamic isCurrentPlaylist;
@dynamic paused;


- (void) addSongs:(NSArray*)songs atIndex:(NSInteger)atIndex {
    NSRange indexRange = NSMakeRange(atIndex, [songs count]);
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:indexRange];
    [self insertSongs:songs atIndexes:indexes];
}

- (void) moveSongs:(NSArray*)songs toIndex:(NSInteger)atIndex {
    NSIndexSet* indices = [self.songs indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [songs containsObject: obj];
    }];
    
    NSUInteger knockDownBy = [indices countOfIndexesInRange:NSMakeRange(0, atIndex)];
    NSInteger moveToIndex = atIndex - knockDownBy;
    
    NSMutableOrderedSet* set = [self mutableOrderedSetValueForKeyPath:@"songs"];
    [set moveObjectsAtIndexes:indices toIndex:moveToIndex];
}



+ (NSSet*) keyPathsForValuesAffectingPlayerStatus {
    return [NSSet setWithArray:@[@"isCurrentPlaylist", @"paused"]];
}

- (int) playerStatus {
    if (!self.isCurrentPlaylist)
        return 0;
    else if (self.paused)
        return 1;
    else
        return 2;
}

@end
