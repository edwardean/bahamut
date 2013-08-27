//
//  SDUserData.m
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDUserData.h"

#import "SDCoreData.h"
#import "SDPlaylist.h"

@implementation SDUserData

@dynamic playlists;

+ (SDUserData*) sharedUserData {
    NSManagedObjectContext* ctx = [SDCoreData sharedCoreData].managedObjectContext;
    
    NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:@"SDUserData"];
    
    NSError* __autoreleasing error;
    NSArray* results = [ctx executeFetchRequest:req error:&error];
    
    if ([results count] < 1) {
        SDWithoutUndos(^{
            SDUserData* userData = [[SDUserData alloc] initWithEntity:[NSEntityDescription entityForName:@"SDUserData" inManagedObjectContext:ctx]
                                       insertIntoManagedObjectContext:ctx];
            
            SDPlaylist* masterPlaylist = [[SDPlaylist alloc] initWithEntity:[NSEntityDescription entityForName:@"SDPlaylist"
                                                                                        inManagedObjectContext:ctx]
                                             insertIntoManagedObjectContext:ctx];
            masterPlaylist.title = @"All Songs";
            masterPlaylist.isMaster = YES;
            [userData addPlaylistsObject: masterPlaylist];
        });
        
        return [self sharedUserData];
    }
    
    return [results lastObject];
}

- (SDPlaylist*) masterPlaylist {
    NSArray* thereCanOnlyBeOne = [[self.playlists array] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.isMaster = YES"]];
    return [thereCanOnlyBeOne lastObject];
}

@end
