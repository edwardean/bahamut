//
//  SOSong.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSong.h"

@interface SDSong ()

@property NSString* title;
@property NSString* album;
@property NSString* artist;

@property CGFloat duration;

@end

@implementation SDSong

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"title"];
        self.album = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"album"];
        self.artist = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"artist"];
        self.duration = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"duration"] doubleValue];
        
        self.uuid = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"uuid"];
        NSData* urlData = [aDecoder decodeObjectOfClass:[NSURL self] forKey:@"urlData"];
        
        BOOL stale;
        NSError* __autoreleasing error;
        self.url = [NSURL URLByResolvingBookmarkData:urlData
                                             options:NSURLBookmarkResolutionWithoutUI
                                       relativeToURL:nil
                                 bookmarkDataIsStale:&stale
                                               error:&error];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    NSError* __autoreleasing error;
    NSData* urlData = [self.url bookmarkDataWithOptions:0 includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
    
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:urlData forKey:@"urlData"];
    
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.album forKey:@"album"];
    [aCoder encodeObject:self.artist forKey:@"artist"];
    
    [aCoder encodeObject:@(self.duration) forKey:@"duration"];
}

- (id) init {
    if (self = [super init]) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (BOOL) isEqual:(id)object {
    return [object isKindOfClass: [self class]] && [self.uuid isEqual: [object uuid]];
}

- (NSUInteger) hash {
    return [self.uuid hash];
}


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

- (void) prefetchData {
    AVURLAsset* asset = [AVURLAsset assetWithURL:self.url];
    
    self.duration = CMTimeGetSeconds([asset duration]);
    self.title = SDGetMetadata(asset, AVMetadataCommonKeyTitle);
    self.artist = SDGetMetadata(asset, AVMetadataCommonKeyArtist);
    self.album = SDGetMetadata(asset, AVMetadataCommonKeyAlbumName);
}

- (AVPlayerItem*) playerItem {
    return [AVPlayerItem playerItemWithAsset:[AVURLAsset assetWithURL:self.url]];
}

@end
