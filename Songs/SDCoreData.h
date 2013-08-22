//
//  SDCoreData.h
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDAllSongsDidChangeNotification @"SDAllSongsDidChangeNotification"
#define SDPlaylistSongsDidChangeNotification @"SDPlaylistSongsDidChangeNotification"
#define SDPlaylistAddedNotification @"SDPlaylistAddedNotification"
#define SDPlaylistRenamedNotification @"SDPlaylistRenamedNotification"
#define SDPlaylistRemovedNotification @"SDPlaylistRemovedNotification"
#define SDPlaylistOptionsChangedNotification @"SDPlaylistOptionsChangedNotification"

@interface SDCoreData : NSObject

+ (SDCoreData*) sharedCoreData;

@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

- (void) setup;
- (void) save;

@end
