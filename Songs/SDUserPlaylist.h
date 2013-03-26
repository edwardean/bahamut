//
//  MUPlaylist.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDPlaylistNode.h"
#import "SDPlaylist.h"

#import "SDSong.h"

@interface SDUserPlaylist : NSObject <SDPlaylistNode, SDPlaylist, NSSecureCoding>

- (void) setTitle:(NSString*)title;

- (void) addSongs:(NSArray*)songs;

@end
