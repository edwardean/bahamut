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
        SDUserData* userData = [[SDUserData alloc] initWithEntity:[NSEntityDescription entityForName:@"SDUserData" inManagedObjectContext:ctx]
                                   insertIntoManagedObjectContext:ctx];
        
        SDPlaylist* masterPlaylist = [[SDPlaylist alloc] initWithEntity:[NSEntityDescription entityForName:@"SDPlaylist" inManagedObjectContext:ctx]
                                         insertIntoManagedObjectContext:ctx];
        
        [userData addPlaylistsObject: masterPlaylist];
        
        return userData;
    }
    
    return [results lastObject];
}

@end
