//
//  SDPlaylist.h
//  Songs
//
//  Created by Steven Degutis on 8/15/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDSong.h"

@interface SDPlaylist : NSObject <NSSecureCoding>

@property NSMutableArray* songs;

- (void) addSongs:(NSArray*)songs;
- (void) addSongs:(NSArray*)songs atIndex:(NSInteger)atIndex;
- (void) removeSongs:(NSArray*)songs;

@property NSString* title;
@property BOOL shuffles;
@property BOOL repeats;

@property BOOL isPlaying;

@end
