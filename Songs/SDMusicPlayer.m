//
//  SDMusicPlayer.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDMusicPlayer.h"

@interface SDMusicPlayer ()

@property AVPlayer* player;
@property id playerCurrentTimeObserver;
@property CMTime currentTime;

@property NSArray* currentPlayerItems;

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
    NSLog(@"ok hes done");
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
    
    NSMutableArray* playerItems = [NSMutableArray array];
    
    for (SDSong* song in songs) {
        AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:[song asset]];
        [playerItems addObject:item];
    }
    
    self.currentPlayerItems = playerItems;
    
    [self.player removeTimeObserver:self.playerCurrentTimeObserver];
    self.playerCurrentTimeObserver = nil;
    
    self.player = [AVPlayer playerWithPlayerItem:[self.currentPlayerItems objectAtIndex:0]];
    
    SDMusicPlayer* __weak weakSelf = self;
    self.playerCurrentTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1,10)
                                                                               queue:NULL
                                                                          usingBlock:^(CMTime time) {
                                                                              weakSelf.currentTime = time;
                                                                          }];
    
    [self.player play];
}

- (void) shuffleArray:(NSMutableArray*)array {
    for (NSUInteger i = [array count]; i > 1; i--) {
        u_int32_t j = arc4random_uniform((u_int32_t)i);
        [array exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}

- (void) seekToTime:(float)time {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, 1)];
}

- (void) prevSong {
}

- (void) nextSong {
}

@end
