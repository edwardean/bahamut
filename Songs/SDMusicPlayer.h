//
//  SDMusicPlayer.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDSong.h"
#import "SDPlaylist.h"

@interface SDMusicPlayer : NSObject

+ (SDMusicPlayer*) sharedMusicPlayer;

- (void) playSong:(SDSong*)song inPlaylist:(id<SDPlaylist>)playlist;

@end
