//
//  SDCurrentSong.m
//  Songs
//
//  Created by Steven Degutis on 3/29/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDCurrentSong.h"

@interface SDCurrentSong ()

@property (weak) id<SDPlaylist> playlist;
@property (weak) SDSong* song;

@property AVPlayer* player;

@property CMTime time;
@property CMTime duration;
@property id timeObserver;

@end

@implementation SDCurrentSong

- (void) seekToTime:(float)time {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, 1)];
}

- (void) pause {
    [self.player pause];
}

- (void) playSong:(SDSong*)song inPlaylist:(id<SDPlaylist>)playlist {
    self.song = song;
    self.playlist = playlist;
    
    
    self.player = [AVPlayer playerWithPlayerItem:[self.song playerItem]];
    
    self.duration = self.player.currentItem.duration;
    
    SDCurrentSong* __weak weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1,10)
                                                                  queue:NULL
                                                             usingBlock:^(CMTime time) {
                                                                 weakSelf.time = time;
                                                             }];
    
    [self.player play];
}

- (void) dealloc {
    [self.player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
}

@end
