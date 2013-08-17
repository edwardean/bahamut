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

@property BOOL _isPlaying;

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
        self.shuffles = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesShuffle"] boolValue];
        self.repeats = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesRepeat"] boolValue];
        
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

- (void) removeSongs:(NSArray*)songs {
    [self.songs removeObjectsInArray:songs];
}

- (void) addSongs:(NSArray*)songs {
    NSMutableArray* songsToAdd = [songs mutableCopy];
    [songsToAdd removeObjectsInArray: self.songs];
    [self.songs addObjectsFromArray: songsToAdd];
}

- (void) addSongs:(NSArray*)songs atIndex:(NSInteger)atIndex {
    NSMutableArray* songsToAdd = [songs mutableCopy];
    [songsToAdd removeObjectsInArray: self.songs];
    
    for (SDSong* song in [songsToAdd reverseObjectEnumerator]) {
        [self.songs insertObject:song atIndex:atIndex];
    }
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



@end
