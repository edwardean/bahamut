//
//  MUAllSongsPlaylist.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDPlaylist.h"
#import "SDPlaylistNode.h"

@interface SDMasterPlaylist : NSObject <SDPlaylist, SDPlaylistNode>

- (void) loadSongs:(NSArray*)songs; // only used for launching the app

- (void) addSongsWithURLs:(NSArray*)urls;

@end
