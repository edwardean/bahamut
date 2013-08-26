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

static id SDGetMetadata(AVAsset* asset, NSString* type) {
    NSArray* metadataItems = [AVMetadataItem metadataItemsFromArray:[asset commonMetadata]
                                                            withKey:type
                                                           keySpace:AVMetadataKeySpaceCommon];
    
    if ([metadataItems count] == 0)
        return nil;
    
    AVMetadataItem* firstMatchingMetadataItem = [metadataItems objectAtIndex:0];
    return [firstMatchingMetadataItem value];
}

+ (void) prefetchDataFor:(SDSong*)song {
    AVURLAsset* asset = [AVURLAsset assetWithURL:[song url]];
    
    song.duration = CMTimeGetSeconds([asset duration]);
    song.title = SDGetMetadata(asset, AVMetadataCommonKeyTitle) ?: [[asset URL] lastPathComponent];
    song.artist = SDGetMetadata(asset, AVMetadataCommonKeyArtist) ?: @"";
    song.album = SDGetMetadata(asset, AVMetadataCommonKeyAlbumName) ?: @"";
    song.hasVideo = [[asset tracksWithMediaCharacteristic:AVMediaCharacteristicVisual] count] > 0;
//    song.artwork = [[NSImage alloc] initWithData:SDGetMetadata(asset, AVMetadataCommonKeyArtwork)];
}

@end
