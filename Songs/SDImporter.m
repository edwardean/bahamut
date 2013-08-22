//
//  SDImporter.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDImporter.h"

#import <AVFoundation/AVFoundation.h>

#import "SDCoreData.h"
#import "SDUserData.h"
#import "SDSong.h"
#import "SDPlaylist.h"

@implementation SDImporter


+ (void) importSongsUnderURLs:(NSArray*)urls {
    [self filterOnlyPlayableURLs:urls completionHandler:^(NSArray *urls) {
//        NSArray* existingURLs = [self.allSongs valueForKeyPath:@"url"];
        
        for (NSURL* url in urls) {
//            if ([existingURLs containsObject: url])
//                continue;
            
            SDPlaylist* playlist = [[SDUserData sharedUserData].playlists firstObject];
            NSLog(@"%@", playlist.title);
            
            
//            continue;
            
            SDSong* song = [[SDSong alloc] initWithEntity:[NSEntityDescription entityForName:@"SDSong"
                                                                      inManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext]
                           insertIntoManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext];
            song.path = [url path];
            [song prefetchData];
            
            
            [playlist addSongsObject: song];
            
            
//            [self.allSongs addObject:song];
        }
        
//        [self saveUserData];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:SDAllSongsDidChangeNotification object:nil];
    }];
}

+ (void) filterOnlyPlayableURLs:(NSArray*)urls completionHandler:(void(^)(NSArray* urls))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* list = [NSMutableArray array];
        
        NSFileManager* fileManager = [[NSFileManager alloc] init];
        
        for (NSURL* url in urls) {
            BOOL isDir;
            BOOL exists = [fileManager fileExistsAtPath:[url path] isDirectory:&isDir];
            if (!exists)
                continue;
            
            if (isDir) {
                NSDirectoryEnumerator* dirEnum = [fileManager enumeratorAtURL:url
                                                   includingPropertiesForKeys:@[]
                                                                      options:NSDirectoryEnumerationSkipsPackageDescendants & NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                     NSLog(@"error for [%@]! %@", url, error);
                                                                     return YES;
                                                                 }];
                
                for (NSURL* file in dirEnum) {
                    AVURLAsset* asset = [AVURLAsset assetWithURL:file];
                    if ([asset isPlayable]) {
                        [list addObject:file];
                    }
                }
            }
            else {
                AVURLAsset* asset = [AVURLAsset assetWithURL:url];
                if ([asset isPlayable]) {
                    [list addObject:url];
                }
            }
        }
        
        NSArray* urls = [list valueForKeyPath:@"fileReferenceURL"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(urls);
        });
    });
}


@end
