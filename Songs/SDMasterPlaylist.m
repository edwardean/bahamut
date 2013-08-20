//
//  SDMasterPlaylist.m
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDMasterPlaylist.h"

#import "SDUserDataManager.h"

@interface SDMasterPlaylist ()

@property BOOL _shuffles;
@property BOOL _repeats;

@end


@implementation SDMasterPlaylist

- (BOOL) isMasterPlaylist {
    return YES;
}


+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self._shuffles = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesShuffle"] boolValue];
        self._repeats = [[aDecoder decodeObjectOfClass:[NSNumber self] forKey:@"doesRepeat"] boolValue];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.shuffles) forKey:@"doesShuffle"];
    [aCoder encodeObject:@(self.repeats) forKey:@"doesRepeat"];
}


- (NSString*) title {
    return @"All Songs";
}

- (void) setTitle:(NSString *)title {
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



- (NSArray*) songs {
    return [SDSharedData() allSongs];
}

@end
