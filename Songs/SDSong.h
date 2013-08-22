//
//  SDSong.h
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SDPlaylist;

@interface SDSong : NSManagedObject

@property (nonatomic, retain) NSString * album;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic) double duration;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) BOOL currentSong;
@property (nonatomic) BOOL paused;
@property (nonatomic, retain) NSSet *playlists;

- (void) prefetchData;

@end

@interface SDSong (CoreDataGeneratedAccessors)

- (void)addPlaylistsObject:(SDPlaylist *)value;
- (void)removePlaylistsObject:(SDPlaylist *)value;
- (void)addPlaylists:(NSSet *)values;
- (void)removePlaylists:(NSSet *)values;

@end
