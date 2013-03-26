//
//  SDMusicPlayer.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDMusicPlayer.h"

@implementation SDMusicPlayer

+ (SDMusicPlayer*) sharedMusicPlayer {
    static SDMusicPlayer* sharedMusicPlayer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMusicPlayer = [[SDMusicPlayer alloc] init];
    });
    return sharedMusicPlayer;
}

- (void) playSong:(SDSong*)song inPlaylist:(id<SDPlaylist>)playlist {
    
}

@end
