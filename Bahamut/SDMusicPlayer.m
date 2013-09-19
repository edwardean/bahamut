//
//  SDPlayer.m
//  Songs
//
//  Created by Steven Degutis on 8/16/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDMusicPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import "SDCoreData.h"


NSString* SDGetTimeForSeconds(CGFloat seconds) {
    CGFloat mins = seconds / 60.0;
    CGFloat secs = fmod(seconds, 60.0);
    return [NSString stringWithFormat:@"%d:%02d", (int)mins, (int)secs];
}


@interface SDMusicPlayer ()

@property SDPlaylist* currentPlaylist;
@property SDSong* currentSong;

@property CGFloat currentTime;
@property BOOL stopped;





@property NSMutableOrderedSet* songsPlaying;
@property NSUInteger currentSongIndex;

@property AVPlayer* player;
@property id timeObserver;

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
        self.player = [[AVPlayer alloc] init];
        self.player.volume = 1.0;
        
        [self useFastHeartBeat:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidResignActive:) name:NSApplicationDidResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void) songDidFinish:(NSNotification*)note {
    [self nextSong];
}

- (void) appDidBecomeActive:(NSNotification*)note {
    [self useFastHeartBeat:YES];
}

- (void) appDidResignActive:(NSNotification*)note {
    [self useFastHeartBeat:NO];
}

- (void) useFastHeartBeat:(BOOL)shouldBeFast {
    if (self.timeObserver)
        [self.player removeTimeObserver: self.timeObserver];
    
    SDMusicPlayer* __weak weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:shouldBeFast ? CMTimeMake(1,2) : CMTimeMake(1,1)
                                                                  queue:NULL
                                                             usingBlock:^(CMTime time) {
                                                                 weakSelf.currentTime = CMTimeGetSeconds(time);
                                                             }];
}









- (void) playSong:(SDSong*)song inPlaylist:(SDPlaylist*)playlist {
    SDWithoutUndos(^{
        self.currentPlaylist.isCurrentPlaylist = NO;
        self.currentSong.isCurrentSong = NO;
        
        self.currentPlaylist = playlist;
        self.currentPlaylist.isCurrentPlaylist = YES;
        self.currentPlaylist.paused = NO;
        
        self.currentSong = song;
        self.currentSong.isCurrentSong = YES;
        self.currentSong.paused = NO;
        
        self.songsPlaying = [[self.currentPlaylist songs] mutableCopy];
        
        if (self.currentPlaylist.shuffles) {
            SDShuffleOrderedSet(self.songsPlaying);
            NSUInteger idx = [self.songsPlaying indexOfObject: self.currentSong];
            [self.songsPlaying moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:idx] toIndex:0];
        }
        
        [self startPlayingCurrentSong];
    });
}

- (void) playPlaylist:(SDPlaylist*)playlist {
    SDWithoutUndos(^{
        if ([[playlist songs] count] == 0)
            return;
        
        NSUInteger idx = 0;
        if (playlist.shuffles)
            idx = arc4random_uniform((int32_t)[[playlist songs] count]);
        
        [self playSong:[[playlist songs] objectAtIndex:idx]
            inPlaylist:playlist];
    });
}


- (void) startPlayingCurrentSong {
    SDWithoutUndos(^{
        self.stopped = NO;
        self.currentTime = 0.0;
        [self.player replaceCurrentItemWithPlayerItem: [self.currentSong playerItem]];
        [self.player play];
    });
}








- (void) moveToSongInDirection:(int)dir {
    if (self.stopped)
        return;
    
    SDWithoutUndos(^{
        self.currentSong.isCurrentSong = NO;
        
        BOOL forward = (dir == 1);
        NSUInteger idx = dir + [self.songsPlaying indexOfObject: self.currentSong];
        NSUInteger endMarker = (forward ? [self.songsPlaying count] : -1);
        
        if (idx == endMarker) {
            if (self.currentPlaylist.repeats == NO) {
                [self stop];
                return;
            }
            
            idx = (forward ? 0 : [self.songsPlaying count] - 1);
            
            if (self.currentPlaylist.shuffles) {
                SDShuffleOrderedSet(self.songsPlaying);
            }
        }
        
        SDSong* nextSong = [self.songsPlaying objectAtIndex:idx];
        
        self.currentSong = nextSong;
        self.currentSong.isCurrentSong = YES;
        self.currentSong.paused = NO;
        
        [self startPlayingCurrentSong];
    });
}

- (void) nextSong {
    [self moveToSongInDirection: +1];
}

- (void) previousSong {
    [self moveToSongInDirection: -1];
}














- (void) fastRewind {
    CMTime now = [self.player currentTime];
    CMTime earlier = CMTimeSubtract(now, CMTimeMake(5, 1));
    [self.player seekToTime:earlier];
}

- (void) fastForward {
    CMTime now = [self.player currentTime];
    CMTime later = CMTimeAdd(now, CMTimeMake(5, 1));
    [self.player seekToTime:later];
}







- (void) pause {
    SDWithoutUndos(^{
        [self.player pause];
        
        self.currentPlaylist.paused = YES;
        self.currentSong.paused = YES;
    });
}

- (void) resume {
    SDWithoutUndos(^{
        [self.player play];
        
        self.currentPlaylist.paused = NO;
        self.currentSong.paused = NO;
    });
}

- (void) stop {
    SDWithoutUndos(^{
        self.currentSong.isCurrentSong = NO;
        self.currentPlaylist.isCurrentPlaylist = NO;
        
        self.stopped = YES;
        self.currentTime = 0.0;
        
        self.currentSong = nil;
        self.currentPlaylist = nil;
        
        [self.player pause];
    });
}










- (void) seekToTime:(CGFloat)percent {
    [self.player seekToTime:CMTimeMakeWithSeconds(percent, 1)];
}













+ (NSSet*) keyPathsForValuesAffectingIsPlaying {
    return [NSSet setWithArray:@[@"player.rate"]];
}

- (BOOL) isPlaying {
    return (self.player.rate > 0.0001);
}









+ (NSSet*) keyPathsForValuesAffectingRemainingTime {
    return [NSSet setWithArray:@[@"currentSong.duration", @"currentTime"]];
}

- (CGFloat) remainingTime {
    return self.currentSong.duration - self.currentTime;
}





















void SDShuffleOrderedSet(NSMutableOrderedSet* orderedSet) {
    for (NSUInteger i = [orderedSet count]; i > 1; i--) {
        u_int32_t j = arc4random_uniform((u_int32_t)i);
        [orderedSet exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}

@end
