//
//  SOAllSongsPlaylist.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOPlaylist.h"

@interface SOAllSongsPlaylist : SOPlaylist

@property (readonly) NSArray* songs;

- (void) addSongsWithURLs:(NSArray*)urls;

@end
