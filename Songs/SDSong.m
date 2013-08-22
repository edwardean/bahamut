//
//  SDSong.m
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSong.h"
#import "SDPlaylist.h"

@implementation SDSong

@dynamic album;
@dynamic artist;
@dynamic duration;
@dynamic path;
@dynamic title;
@dynamic isCurrentSong;
@dynamic paused;
@dynamic playlists;

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

- (NSURL*) url {
    return [NSURL fileURLWithPath:self.path];
}

- (void) prefetchData {
    AVURLAsset* asset = [AVURLAsset assetWithURL:[self url]];
    
    self.duration = CMTimeGetSeconds([asset duration]);
    self.title = SDGetMetadata(asset, AVMetadataCommonKeyTitle);
    self.artist = SDGetMetadata(asset, AVMetadataCommonKeyArtist);
    self.album = SDGetMetadata(asset, AVMetadataCommonKeyAlbumName);
}

- (AVPlayerItem*) playerItem {
    return [AVPlayerItem playerItemWithAsset:[AVURLAsset assetWithURL:[self url]]];
}

@end
