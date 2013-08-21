//
//  Song.h
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist;

@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * album;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic) double duration;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSSet *playlist;
@end

@interface Song (CoreDataGeneratedAccessors)

- (void)addPlaylistObject:(Playlist *)value;
- (void)removePlaylistObject:(Playlist *)value;
- (void)addPlaylist:(NSSet *)values;
- (void)removePlaylist:(NSSet *)values;

@end
