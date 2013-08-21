//
//  UserData.h
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist;

@interface UserData : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *playlists;
@end

@interface UserData (CoreDataGeneratedAccessors)

- (void)insertObject:(Playlist *)value inPlaylistsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPlaylistsAtIndex:(NSUInteger)idx;
- (void)insertPlaylists:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePlaylistsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPlaylistsAtIndex:(NSUInteger)idx withObject:(Playlist *)value;
- (void)replacePlaylistsAtIndexes:(NSIndexSet *)indexes withPlaylists:(NSArray *)values;
- (void)addPlaylistsObject:(Playlist *)value;
- (void)removePlaylistsObject:(Playlist *)value;
- (void)addPlaylists:(NSOrderedSet *)values;
- (void)removePlaylists:(NSOrderedSet *)values;
@end
