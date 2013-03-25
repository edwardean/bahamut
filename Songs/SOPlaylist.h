//
//  SOPlaylist.h
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SOSong.h"

@interface SOPlaylist : NSObject

@property NSString* title;

@property (readonly) NSArray* songs;

- (void) addSong:(SOSong*)song;

@end
