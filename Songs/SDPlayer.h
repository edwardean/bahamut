//
//  SDPlayer.h
//  Songs
//
//  Created by Steven Degutis on 8/16/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDSong.h"
#import "SDPlaylist.h"

#define SDNowPlayingDidChange @"SDNowPlayingDidChange"
#define SDNowPlayingCurrentTimeDidChange @"SDNowPlayingCurrentTimeDidChange"

@interface SDPlayer : NSObject

+ (SDPlayer*) sharedPlayer;

- (void) playSong:(SDSong*)song inPlaylist:(SDPlaylist*)playlist;
- (void) playPlaylist:(SDPlaylist*)playlist;

- (void) seekToTime:(CGFloat)percent;

- (void) pause;
- (void) resume;

- (void) nextSong;
- (void) previousSong;

@property (weak) SDSong* nowPlaying;
@property CGFloat currentTime;

@end
