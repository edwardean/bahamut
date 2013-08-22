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
    
    NSLog(@"%@", self);
    
//    NSIndexSet* indices = [self.songs indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        return [songs containsObject:obj];
//    }];
//    
//    NSUInteger knockDownBy = [indices countOfIndexesInRange:NSMakeRange(0, atIndex)];
//    NSInteger moveToIndex = atIndex - knockDownBy;
//    
//    [self removeSongs:songs];
//    [self addSongs:songs
//           atIndex:moveToIndex];
}

@end
