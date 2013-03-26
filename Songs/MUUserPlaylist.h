//
//  MUUserPlaylist.h
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MUUserPlaylist <NSObject>

- (NSString*) title;
- (BOOL) isMaster;
- (NSArray*) songs;

@end
