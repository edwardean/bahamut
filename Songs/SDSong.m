//
//  SOSong.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSong.h"

@interface SDSong ()

@property NSString* uuid;

@property AVURLAsset* cachedAsset;

@end

@implementation SDSong

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.uuid = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"uuid"];
        self.url = [[aDecoder decodeObjectOfClass:[NSURL self] forKey:@"url"] fileReferenceURL];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:self.url forKey:@"url"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id) init {
    if (self = [super init]) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (AVURLAsset*) asset {
    if (self.cachedAsset == nil)
        self.cachedAsset = [AVURLAsset assetWithURL:self.url];
    
    return self.cachedAsset;
}

- (NSString*) metadataOfType:(NSString*)type {
    NSArray* metadataItems = [AVMetadataItem metadataItemsFromArray:[[self asset] commonMetadata]
                                                            withKey:type
                                                           keySpace:AVMetadataKeySpaceCommon];
    
    if ([metadataItems count] == 0) {
        if (type == AVMetadataCommonKeyTitle)
            return [[[self asset] URL] lastPathComponent];
        else
            return @"";
    }
    
    AVMetadataItem* firstMatchingMetadataItem = [metadataItems objectAtIndex:0];
    return (id)[firstMatchingMetadataItem value];
}

- (NSString*) title {
    return [self metadataOfType:AVMetadataCommonKeyTitle];
}

- (NSString*) album {
    return [self metadataOfType:AVMetadataCommonKeyAlbumName];
}

- (NSString*) artist {
    return [self metadataOfType:AVMetadataCommonKeyArtist];
}

@end
