//
//  MUUserPlaylist.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDSong.h"

@protocol SDPlaylist <NSObject>

- (NSString*) title;

- (NSArray*) songs;
- (void) addSongs:(NSArray*)songs;

- (BOOL) shuffles;
- (void) setShuffles:(BOOL)shuffles;

- (BOOL) repeats;
- (void) setRepeats:(BOOL)repeats;

- (void) playSong:(SDSong*)song;
- (void) pause;

@end
