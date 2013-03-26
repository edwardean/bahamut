//
//  MUPlaylistNode.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDPlaylistNode.h"

@interface SDPlaylistCollection : NSObject <SDPlaylistNode>

@property NSMutableArray* playlists;

@end
