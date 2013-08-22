//
//  SDPlaylist.h
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SDSong, SDUserData;

@interface SDPlaylist : NSManagedObject

@property (nonatomic) BOOL isMaster;
@property (nonatomic, retain) NSOrderedSet *songs;

@property (nonatomic, retain) NSString * title;
@property (nonatomic) BOOL shuffles;
@property (nonatomic) BOOL repeats;

@property (nonatomic) BOOL isCurrentPlaylist;
@property (nonatomic) BOOL paused;

@property (nonatomic, retain) SDUserData *userData;

- (void) addSongs:(NSArray*)songs atIndex:(NSInteger)atIndex;
- (void) moveSongs:(NSArray*)songs toIndex:(NSInteger)atIndex;






@property (nonatomic, readonly) int playerStatus;

@end

@interface SDPlaylist (CoreDataGeneratedAccessors)

- (void)insertObject:(SDSong *)value inSongsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSongsAtIndex:(NSUInteger)idx;
- (void)insertSongs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSongsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSongsAtIndex:(NSUInteger)idx withObject:(SDSong *)value;
- (void)replaceSongsAtIndexes:(NSIndexSet *)indexes withSongs:(NSArray *)values;
- (void)addSongsObject:(SDSong *)value;
- (void)removeSongsObject:(SDSong *)value;
- (void)addSongs:(NSOrderedSet *)values;
- (void)removeSongs:(NSOrderedSet *)values;
@end
