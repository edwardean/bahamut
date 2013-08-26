//
//  SDSong.m
//  Bahamut
//
//  Created by Steven on 8/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSong.h"
#import "SDPlaylist.h"


@implementation SDSong

@dynamic album;
@dynamic artist;
@dynamic duration;
@dynamic isCurrentSong;
@dynamic paused;
@dynamic hasVideo;
@dynamic title;
@dynamic url;
@dynamic genre;
@dynamic artwork;
@dynamic playlists;


- (AVPlayerItem*) playerItem {
    return [AVPlayerItem playerItemWithAsset:[AVURLAsset assetWithURL:[self url]]];
}


+ (NSSet*) keyPathsForValuesAffectingPlayerStatus {
    return [NSSet setWithArray:@[@"isCurrentSong", @"paused"]];
}

- (int) playerStatus {
    if (!self.isCurrentSong)
        return 0;
    else if (self.paused)
        return 1;
    else
        return 2;
}

@end





@interface SDURLTransformer : NSValueTransformer
@end

@implementation SDURLTransformer

+ (Class)transformedValueClass { return [NSURL class]; }
+ (BOOL)allowsReverseTransformation { return YES; }

- (id)transformedValue:(NSURL*)url {
    NSError* error;
    
    NSData* urlData = [url bookmarkDataWithOptions:0
                    includingResourceValuesForKeys:@[]
                                     relativeToURL:nil
                                             error:&error];
    
    return urlData;
}

- (id)reverseTransformedValue:(NSData*)urlData {
    NSError* __autoreleasing error;
    BOOL stale;
    
    return [NSURL URLByResolvingBookmarkData:urlData
                                     options:0
                               relativeToURL:nil
                         bookmarkDataIsStale:&stale
                                       error:&error];
}

@end