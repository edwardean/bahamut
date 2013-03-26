//
//  MUPlaylistNode.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MUPlaylistNode.h"

@interface MUPlaylistCollection : NSObject <MUPlaylistNode>

@property NSMutableArray* playlists;

@end
