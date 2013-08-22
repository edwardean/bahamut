//
//  SDCoreData.m
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDCoreData.h"

#import "SDUserData.h"

#import "NSManagedObjectModel+KCOrderedAccessorFix.h"

@implementation SDCoreData

+ (SDCoreData*) sharedCoreData {
    static SDCoreData* sharedCoreData;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoreData = [[SDCoreData alloc] init];
    });
    return sharedCoreData;
}

- (void) setup {
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"SongsDataModel" withExtension:@"momd"]];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSError *error;
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:[self dataFile] options:nil error:&error]) {
        [NSApp presentError:error];
        return;
    }
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    [self.managedObjectModel kc_generateOrderedSetAccessors];
    
//    [[self.managedObjectContext undoManager] disableUndoRegistration]; // this barely seems to help.
    [SDUserData sharedUserData]; // force it to load.
//    [[self.managedObjectContext undoManager] enableUndoRegistration];
    
    [[SDUserData sharedUserData] masterPlaylist];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSoon:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
}

- (void) saveSoon:(NSNotification*)note {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(save) object:nil];
    [self performSelector:@selector(save) withObject:nil afterDelay:3.0];
}

- (NSURL*) dataFile {
    NSError *error;
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                  inDomain:NSUserDomainMask
                                                         appropriateForURL:nil
                                                                    create:YES
                                                                     error:&error];
    
    NSURL* dataDirURL = [appSupportDir URLByAppendingPathComponent:@"Songs"];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:dataDirURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    
    return [dataDirURL URLByAppendingPathComponent:@"data"];
}

- (void) save {
//    NSLog(@"pretend saving");
//    return;
    
    NSLog(@"really saving");
    
    if (![[self managedObjectContext] commitEditing])
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error])
        [NSApp presentError:error];
}

@end
