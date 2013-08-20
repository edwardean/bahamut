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

#define SDCurrentSongDidChangeNotification @"SDCurrentSongDidChangeNotification"
#define SDCurrentSongTimeDidChangeNotification @"SDCurrentSongTimeDidChangeNotification"
#define SDPlayerStatusDidChangeNotification @"SDPlayerStatusDidChangeNotification"

@interface SDMusicPlayer : NSObject

+ (SDMusicPlayer*) sharedPlayer;

- (void) playSong:(SDSong*)song inPlaylist:(SDPlaylist*)playlist;
- (void) playPlaylist:(SDPlaylist*)playlist;

- (void) seekToTime:(CGFloat)percent;

- (void) pause;
- (void) resume;
- (BOOL) isPlaying;

- (void) stop;

- (void) nextSong;
- (void) previousSong;

- (SDSong*) currentSong;
- (SDPlaylist*) currentPlaylist;
@property (readonly) CGFloat currentTime;
@property (readonly) BOOL stopped;

@end
