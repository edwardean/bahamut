//
//  SDSong.h
//  Bahamut
//
//  Created by Steven on 8/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import <AVFoundation/AVFoundation.h>

@class SDPlaylist;

@interface SDSong : NSManagedObject

@property (nonatomic, retain) NSString * album;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic) double duration;
@property (nonatomic) BOOL isCurrentSong;
@property (nonatomic) BOOL paused;
@property (nonatomic) BOOL hasVideo;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) id url;
@property (nonatomic, retain) NSSet *playlists;

- (AVPlayerItem*) playerItem;

@end

@interface SDSong (CoreDataGeneratedAccessors)

- (void)addPlaylistsObject:(SDPlaylist *)value;
- (void)removePlaylistsObject:(SDPlaylist *)value;
- (void)addPlaylists:(NSSet *)values;
- (void)removePlaylists:(NSSet *)values;

@end
