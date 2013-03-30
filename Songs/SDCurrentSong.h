//
//  SDCurrentSong.h
//  Songs
//
//  Created by Steven Degutis on 3/29/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#import "SDPlaylist.h"
#import "SDSong.h"

@interface SDCurrentSong : NSObject

@property (readonly) AVPlayer* player;

@property (readonly) CMTime time;
@property (readonly) CMTime duration;

- (void) seekToTime:(float)time;

- (void) playSong:(SDSong*)song inPlaylist:(id<SDPlaylist>)playlist;

@end
