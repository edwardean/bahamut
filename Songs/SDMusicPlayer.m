//
//  SDMusicPlayer.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDMusicPlayer.h"

#import "SDCurrentSong.h"

@interface SDMusicPlayer ()

@property id<SDPlaylist> currentPlaylist;
@property SDCurrentSong* currentSong;

@property NSMutableArray* currentSongs;
@property NSUInteger currentSongIndex;

@end

@implementation SDMusicPlayer

+ (SDMusicPlayer*) sharedMusicPlayer {
    static SDMusicPlayer* sharedMusicPlayer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMusicPlayer = [[SDMusicPlayer alloc] init];
    });
    return sharedMusicPlayer;
}

- (id) init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidPlayToEndTime:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
    }
    return self;
}

- (void) playerItemDidPlayToEndTime:(NSNotification*)note {
    [self nextSong];
}

- (void) playSongAt:(NSUInteger)idx {
    self.currentSongIndex = idx;
    
    SDSong* song = [self.currentSongs objectAtIndex:self.currentSongIndex];
    
    SDCurrentSong* currentSong = [[SDCurrentSong alloc] init];
    [currentSong playSong:song inPlaylist:self.currentPlaylist];
    self.currentSong = currentSong;
}

- (void) stop {
    self.currentSong = nil;
    
    self.currentSongs = nil;
    self.currentPlaylist = nil;
}

- (void) playSong:(SDSong*)song inPlaylist:(id<SDPlaylist>)playlist {
    NSMutableArray* songs = [[playlist songs] mutableCopy];
    
    if (song == nil) {
        if (playlist.doesShuffle) {
            [self shuffleArray:songs];
        }
    }
    else {
        if (playlist.doesShuffle) {
            [songs removeObject:song];
            [self shuffleArray:songs];
            [songs insertObject:song atIndex:0];
        }
        else {
            NSUInteger idx = [songs indexOfObject:song];
            [songs removeObjectsInRange:NSMakeRange(0, idx)];
        }
    }
    
    self.currentPlaylist = playlist;
    self.currentSongs = songs;
    
    [self playSongAt:0];
}

- (void) shuffleArray:(NSMutableArray*)array {
    for (NSUInteger i = [array count]; i > 1; i--) {
        u_int32_t j = arc4random_uniform((u_int32_t)i);
        [array exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}

- (void) seekToTime:(float)time {
    [self.currentSong seekToTime:time];
}

- (void) prevSong {
    NSUInteger idx = self.currentSongIndex - 1;
    
    if (idx == -1) {
        idx = [self.currentSongs count] - 1;
    }
    
    [self playSongAt:idx];
}

- (void) nextSong {
    NSUInteger idx = self.currentSongIndex + 1;
    
    if (idx == [self.currentSongs count]) {
        if (![self.currentPlaylist doesRepeat]) {
            [self stop];
            return;
        }
        
        idx = 0;
    }
    
    [self playSongAt:idx];
}

@end
