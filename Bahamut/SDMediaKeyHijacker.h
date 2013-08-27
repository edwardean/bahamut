//
//  SDMediaKeyHijacker.h
//  Songs
//
//  Created by Steven on 8/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDMediaKeyPressedPlayPause @"SDMediaKeyPressedPlayPause"
#define SDMediaKeyPressedPrevious @"SDMediaKeyPressedPrevious"
#define SDMediaKeyPressedNext @"SDMediaKeyPressedNext"

@interface SDMediaKeyHijacker : NSObject

- (void) hijack;

@end
