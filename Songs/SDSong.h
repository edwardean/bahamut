//
//  SOSong.h
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@interface SDSong : NSObject <NSSecureCoding>

@property NSString* uuid;
@property NSURL* url;

- (NSString*) title;
- (NSString*) album;
- (NSString*) artist;

- (CGFloat) duration;

- (AVPlayerItem*) playerItem;

@end
