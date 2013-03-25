//
//  SOPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOPlaylist.h"

@implementation SOPlaylist

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
//        self.uuid = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"uuid"];
//        self.url = [aDecoder decodeObjectOfClass:[NSURL self] forKey:@"url"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
//    [aCoder encodeObject:self.uuid forKey:@"uuid"];
//    [aCoder encodeObject:self.url forKey:@"url"];
}

- (void) addSong:(SOSong*)song {
    
}

@end
