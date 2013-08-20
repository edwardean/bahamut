//
//  SDPlaylist.m
//  Songs
//
//  Created by Steven Degutis on 8/15/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylist.h"

#import "SDUserDataManager.h"

@interface SDPlaylist ()

@property NSString* _title;
@property BOOL _shuffles;
@property BOOL _repeats;

@end

@implementation SDPlaylist

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id) init {
    if (self = [super init]) {
        self.songs = [NSMutableArray array];
        self._title = @"New Playlist";
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self._title = [aDecoder decodeObjectOfClass:[NSString self] forKey:@"title"];
        self._shuffles = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesShuffle"] boolValue];
        self._repeats = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesRepeat"] boolValue];
        
        NSArray* songUUIDs = [aDecoder decodeObjectOfClass:[NSArray self] forKey:@"songUUIDs"];
        [self.songs addObjectsFromArray:[SDUserDataManager songsForUUIDs:songUUIDs]];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self.songs valueForKey:@"uuid"] forKey:@"songUUIDs"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:@(self.shuffles) forKey:@"doesShuffle"];
    [aCoder encodeObject:@(self.repeats) forKey:@"doesRepeat"];
}






- (void) addSongs:(NSArray *)songs atIndexes:(NSIndexSet*)indexes {
    [SDAddUndo(self) removeSongs:songs];
    
    [self.songs insertObjects:songs atIndexes:indexes];
    
    SDSaveData();
    SDPostNote(SDPlaylistSongsDidChangeNotification, self);
}

- (void) removeSongs:(NSArray*)songs {
    NSIndexSet* songIndexes = [self.songs indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [songs containsObject: obj];
    }];
    [SDAddUndo(self) addSongs:songs atIndexes:songIndexes];
    
    [self.songs removeObjectsInArray:songs];
    
    SDSaveData();
    SDPostNote(SDPlaylistSongsDidChangeNotification, self);
}

- (void) addSongs:(NSArray*)songs {
    [self addSongs:songs
           atIndex:[self.songs count]];
}

- (void) addSongs:(NSArray*)songs atIndex:(NSInteger)atIndex {
    NSMutableArray* songsToAdd = [songs mutableCopy];
    [songsToAdd removeObjectsInArray: self.songs];
    songs = songsToAdd;
    
    NSRange indexRange = NSMakeRange(atIndex, [songs count]);
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:indexRange];
    [self addSongs:songs atIndexes:indexes];
}

- (void) moveSongs:(NSArray*)songs toIndex:(NSInteger)atIndex {
    SDGroupUndoOps(^{
        NSIndexSet* indices = [self.songs indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [songs containsObject:obj];
        }];
        
        NSUInteger knockDownBy = [indices countOfIndexesInRange:NSMakeRange(0, atIndex)];
        NSInteger moveToIndex = atIndex - knockDownBy;
        
        [self removeSongs:songs];
        [self addSongs:songs
               atIndex:moveToIndex];
    });
}











- (void) setTitle:(NSString *)title {
    [SDAddUndo(self) setTitle: self._title];
    self._title = title;
    SDSaveData();
    SDPostNote(SDPlaylistRenamedNotification, self);
}

- (NSString*)title {
    return self._title;
}







- (void) setRepeats:(BOOL)repeats {
    [SDAddUndo(self) setRepeats: self._repeats];
    self._repeats = repeats;
    SDSaveData();
    SDPostNote(SDPlaylistOptionsChangedNotification, self);
}

- (BOOL) repeats {
    return self._repeats;
}






- (void) setShuffles:(BOOL)shuffles {
    [SDAddUndo(self) setShuffles:self._shuffles];
    self._shuffles = shuffles;
    SDSaveData();
    SDPostNote(SDPlaylistOptionsChangedNotification, self);
}

- (BOOL) shuffles {
    return self._shuffles;
}



- (BOOL) isMasterPlaylist {
    return NO;
}

@end
