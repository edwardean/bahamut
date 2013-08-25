//
//  SDPlayer.h
//  Songs
//
//  Created by Steven Degutis on 8/16/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#import "SDSong.h"
#import "SDPlaylist.h"

NSString* SDGetTimeForSeconds(CGFloat seconds);

@interface SDMusicPlayer : NSObject

+ (SDMusicPlayer*) sharedPlayer;

- (void) playSong:(SDSong*)song inPlaylist:(SDPlaylist*)playlist;
- (void) playPlaylist:(SDPlaylist*)playlist;

- (void) nextSong;
- (void) previousSong;

- (void) pause;
- (void) resume;
- (void) stop;

- (void) seekToTime:(CGFloat)percent;

@property (readonly) BOOL isPlaying;
@property (readonly) SDSong* currentSong;
@property (readonly) SDPlaylist* currentPlaylist;

@property (readonly) CGFloat currentTime;
@property (readonly) CGFloat remainingTime;
@property (readonly) BOOL stopped;

@property (readonly) AVPlayer* player;

@end
