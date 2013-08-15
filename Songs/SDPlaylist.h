//
//  SDPlaylist.h
//  Songs
//
//  Created by Steven Degutis on 8/15/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDSong.h"

@interface SDPlaylist : NSObject

- (NSString*) title;
- (void) setTitle:(NSString*)title;

- (NSArray*) songs;
- (BOOL) canAddSongs;
- (void) addSongs:(NSArray*)songs;

- (BOOL) shuffles;
- (void) setShuffles:(BOOL)shuffles;

- (BOOL) repeats;
- (void) setRepeats:(BOOL)repeats;

- (void) playSong:(SDSong*)song;
- (void) pause;
- (BOOL) isPlaying;

@end
