//
//  SDUserData.h
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SDUserData : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *playlists;

+ (SDUserData*) sharedUserData;

@end

@interface SDUserData (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inPlaylistsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPlaylistsAtIndex:(NSUInteger)idx;
- (void)insertPlaylists:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePlaylistsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPlaylistsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replacePlaylistsAtIndexes:(NSIndexSet *)indexes withPlaylists:(NSArray *)values;
- (void)addPlaylistsObject:(NSManagedObject *)value;
- (void)removePlaylistsObject:(NSManagedObject *)value;
- (void)addPlaylists:(NSOrderedSet *)values;
- (void)removePlaylists:(NSOrderedSet *)values;


@end
