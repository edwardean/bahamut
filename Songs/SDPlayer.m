//
//  SDPlayer.m
//  Songs
//
//  Created by Steven Degutis on 8/16/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlayer.h"

#import <AVFoundation/AVFoundation.h>

@interface SDPlayer ()

@property NSArray* songsPlaying;

@property AVPlayer* player;
@property id timeObserver;

@end

@implementation SDPlayer

+ (SDPlayer*) sharedPlayer {
    static SDPlayer* sharedPlayer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[SDPlayer alloc] init];
    });
    return sharedPlayer;
}

- (void) playSong:(SDSong*)song inPlaylist:(SDPlaylist*)playlist {
    self.songsPlaying = [playlist songs];
    self.nowPlaying = song;
    
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
    
    self.player = [AVPlayer playerWithPlayerItem:[self.nowPlaying playerItem]];
    
    SDPlayer* __weak weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1,10)
                                                                  queue:NULL
                                                             usingBlock:^(CMTime time) {
                                                                 weakSelf.currentTime = CMTimeGetSeconds(time);
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:SDNowPlayingCurrentTimeDidChange object:nil];
                                                             }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foo:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    [self.player play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SDNowPlayingDidChange object:nil];
}

- (void) foo:(NSNotification*)note {
    NSLog(@"ok done");
}

- (void) playPlaylist:(SDPlaylist*)playlist {
}

- (void) seekToTime:(CGFloat)percent {
    [self.player seekToTime:CMTimeMakeWithSeconds(percent, 1)];
}

- (void) pause {
    [self.player pause];
}

- (void) resume {
    [self.player play];
}

- (void) nextSong {
    
}

- (void) previousSong {
    
}

@end
