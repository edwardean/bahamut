//
//  SDPlayer.m
//  Songs
//
//  Created by Steven Degutis on 8/16/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlayer.h"

@interface SDPlayer ()



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
    
}

- (void) playPlaylist:(SDPlaylist*)playlist {
    
}

- (void) seekToTime:(CGFloat)percent {
    
}

- (void) pause {
    
}

- (void) resume {
    
}

- (void) nextSong {
    
}

- (void) previousSong {
    
}

@end
