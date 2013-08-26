//
//  SDSongCacher.m
//  Bahamut
//
//  Created by Steven on 8/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSongCacher.h"

#import <AVFoundation/AVFoundation.h>

@implementation SDSongCacher

static NSString* SDGetMetadata(AVURLAsset* asset, NSString* type) {
    NSArray* metadataItems = [AVMetadataItem metadataItemsFromArray:[asset commonMetadata]
                                                            withKey:type
                                                           keySpace:AVMetadataKeySpaceCommon];
    
    if ([metadataItems count] == 0) {
        if (type == AVMetadataCommonKeyTitle)
            return [[asset URL] lastPathComponent];
        else
            return @"";
    }
    
    AVMetadataItem* firstMatchingMetadataItem = [metadataItems objectAtIndex:0];
    return (id)[firstMatchingMetadataItem value];
}

+ (void) prefetchDataFor:(SDSong*)song {
    AVURLAsset* asset = [AVURLAsset assetWithURL:[song url]];
    
    song.title = SDGetMetadata(asset, AVMetadataCommonKeyTitle);
    song.artist = SDGetMetadata(asset, AVMetadataCommonKeyArtist);
    song.album = SDGetMetadata(asset, AVMetadataCommonKeyAlbumName);
    song.hasVideo = [[asset tracksWithMediaCharacteristic:AVMediaCharacteristicVisual] count] > 0;    song.duration = CMTimeGetSeconds([asset duration]);
}

@end
