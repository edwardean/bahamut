//
//  SDSongCacher.h
//  Bahamut
//
//  Created by Steven on 8/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDSong.h"

@interface SDSongCacher : NSObject

+ (void) prefetchDataFor:(SDSong*)song;

@end
