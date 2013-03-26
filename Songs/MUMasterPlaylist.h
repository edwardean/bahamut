//
//  MUAllSongsPlaylist.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MUUserPlaylist.h"
#import "MUPlaylistNode.h"

@interface MUMasterPlaylist : NSObject <MUUserPlaylist, MUPlaylistNode>

- (void) addSongsWithURLs:(NSArray*)urls;

@end
