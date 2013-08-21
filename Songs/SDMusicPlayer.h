//
//  SDPlayer.h
//  Songs
//
//  Created by Steven Degutis on 8/16/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "SDOldSong.h"
//#import "SDOldPlaylist.h"

#define SDCurrentSongDidChangeNotification @"SDCurrentSongDidChangeNotification"
#define SDCurrentSongTimeDidChangeNotification @"SDCurrentSongTimeDidChangeNotification"
#define SDPlayerStatusDidChangeNotification @"SDPlayerStatusDidChangeNotification"

@interface SDMusicPlayer : NSObject

+ (SDMusicPlayer*) sharedPlayer;

//- (void) playSong:(SDOldSong*)song inPlaylist:(SDOldPlaylist*)playlist;
//- (void) playPlaylist:(SDOldPlaylist*)playlist;

- (void) seekToTime:(CGFloat)percent;

- (void) pause;
- (void) resume;
- (BOOL) isPlaying;

- (void) stop;

- (void) nextSong;
- (void) previousSong;

//- (SDOldSong*) currentSong;
//- (SDOldPlaylist*) currentPlaylist;
@property (readonly) CGFloat currentTime;
@property (readonly) BOOL stopped;

@end
