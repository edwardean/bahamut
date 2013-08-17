//
//  SDPlayer.m
//  Songs
//
//  Created by Steven Degutis on 8/16/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDMusicPlayer.h"

#import <AVFoundation/AVFoundation.h>

@interface SDMusicPlayer ()

@property SDPlaylist* currentPlaylist;
@property NSMutableArray* songsPlaying;

@property NSUInteger currentSongIndex;
@property CGFloat currentTime;

@property AVPlayer* player;
@property id timeObserver;

@property BOOL stopped;

@end

@implementation SDMusicPlayer

+ (SDMusicPlayer*) sharedPlayer {
    static SDMusicPlayer* sharedPlayer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[SDMusicPlayer alloc] init];
    });
    return sharedPlayer;
}

- (id) init {
    if (self = [super init]) {
        self.stopped = YES;
        self.songsPlaying = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void) playPlaylist:(SDPlaylist*)playlist {
    if ([[playlist songs] count] == 0)
        return;
    
    [self playSong:[[playlist songs] objectAtIndex:0]
        inPlaylist:playlist];
}

- (void) playSong:(SDSong*)song inPlaylist:(SDPlaylist*)playlist {
    self.stopped = NO;
    
    self.currentPlaylist.isPlaying = NO;
    self.currentPlaylist = playlist;
    self.currentPlaylist.isPlaying = YES;
    
    [self.songsPlaying removeAllObjects];
    [self.songsPlaying addObjectsFromArray: [playlist songs]];
    if (self.currentPlaylist.shuffles) {
        [self shuffleSongs];
        [self.songsPlaying removeObject:song];
        [self.songsPlaying insertObject:song atIndex:0];
    }
    
    self.currentSongIndex = [self.songsPlaying indexOfObject: song];
    [self actuallyPlaySong];
}

- (void) stop {
    self.stopped = YES;
    
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
    
    self.player = nil;
    self.currentTime = 0.0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SDCurrentSongDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDCurrentSongTimeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPlayerStatusDidChangeNotification object:nil];
}

- (void) actuallyPlaySong {
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
    
    self.player = [AVPlayer playerWithPlayerItem: [[self currentSong] playerItem]];
    
    self.currentTime = 0.0;
    
    SDMusicPlayer* __weak weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1,10)
                                                                  queue:NULL
                                                             usingBlock:^(CMTime time) {
                                                                 weakSelf.currentTime = CMTimeGetSeconds(time);
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:SDCurrentSongTimeDidChangeNotification object:nil];
                                                             }];
    
    [self.player play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SDCurrentSongDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDCurrentSongTimeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPlayerStatusDidChangeNotification object:nil];
}

- (SDSong*) currentSong {
    if (self.stopped)
        return nil;
    else
        return [self.songsPlaying objectAtIndex: self.currentSongIndex];
}

- (void) shuffleSongs {
    for (NSUInteger i = [self.songsPlaying count]; i > 1; i--) {
        u_int32_t j = arc4random_uniform((u_int32_t)i);
        [self.songsPlaying exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}

- (void) songDidFinish:(NSNotification*)note {
    [self nextSong];
}

- (void) seekToTime:(CGFloat)percent {
    [self.player seekToTime:CMTimeMakeWithSeconds(percent, 1)];
}

- (void) pause {
    [self.player pause];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPlayerStatusDidChangeNotification object:nil];
}

- (void) resume {
    [self.player play];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPlayerStatusDidChangeNotification object:nil];
}

- (BOOL) isPlaying {
    return (self.player.rate > 0.5);
}

- (void) nextSong {
    self.currentSongIndex++;
    
    if (self.currentSongIndex == [self.songsPlaying count]) {
        if (self.currentPlaylist.repeats) {
            self.currentSongIndex = 0;
            
            if (self.currentPlaylist.shuffles)
                [self shuffleSongs];
        }
        else {
            [self stop];
            return;
        }
    }
    
    [self actuallyPlaySong];
}

- (void) previousSong {
    self.currentSongIndex--;
    
    if (self.currentSongIndex == -1) {
        if (self.currentPlaylist.repeats) {
            self.currentSongIndex = [self.songsPlaying count] - 1;
            
            if (self.currentPlaylist.shuffles)
                [self shuffleSongs];
        }
        else {
            [self stop];
            return;
        }
    }
    
    [self actuallyPlaySong];
}

@end
