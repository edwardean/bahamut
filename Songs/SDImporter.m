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

#import "iTunes.h"

@implementation SDImporter


+ (void) importSongsUnderURLs:(NSArray*)urls {
    [self filterOnlyPlayableURLs:urls completionHandler:^(NSArray *urls) {
        NSSet* existingURLs = [self existingSongURLs];
        
        for (NSURL* url in urls) {
            if ([existingURLs containsObject: url])
                continue;
            
            SDPlaylist* allSongsPlaylist = [[SDUserData sharedUserData] masterPlaylist];
            
            SDSong* song = [[SDSong alloc] initWithEntity:[NSEntityDescription entityForName:@"SDSong"
                                                                      inManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext]
                           insertIntoManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext];
            song.path = [url path];
            [song prefetchData];
            
            [allSongsPlaylist addSongsObject: song];
        }
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
        
        NSArray* urls = list;
//        urls = [urls valueForKeyPath:@"fileReferenceURL"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(urls);
        });
    });
}




+ (NSSet*) existingSongURLs {
    NSManagedObjectContext* ctx = [SDCoreData sharedCoreData].managedObjectContext;
    
    NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:@"SDSong"];
    
    NSError* __autoreleasing error;
    NSArray* allSongs = [ctx executeFetchRequest:req error:&error];
    
    NSMutableSet* set = [NSMutableSet set];
    
    for (SDSong* song in allSongs) {
        [set addObject: [NSURL fileURLWithPath:[song path]]];
    }
    
    return set;
}




+ (SDSong*) songForPath:(NSString*)path {
    NSManagedObjectContext* ctx = [SDCoreData sharedCoreData].managedObjectContext;
    
    NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:@"SDSong"];
    [req setPredicate:[NSPredicate predicateWithFormat:@"path = %@", path]];
    
    NSError* __autoreleasing error;
    NSArray* matchingSongs = [ctx executeFetchRequest:req error:&error];
    
    assert([matchingSongs count] <= 1);
    return [matchingSongs lastObject];
}




+ (void) importFromiTunes {
    @autoreleasepool {
        iTunesApplication* iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        iTunesSource* library;
        
        for (iTunesSource* source in [iTunesApp.sources get]) {
            if (source.kind == iTunesESrcLibrary) {
                library = source;
                break;
            }
        }
        
        NSArray* playlists = [library.playlists get];
        
        // we can assume iTunes doesn't have duplicates
        NSSet* currentSongFileURLs = [self existingSongURLs];
        
        for (iTunesPlaylist* playlist in playlists) {
            @autoreleasepool {
                if ([[playlist className] isEqualToString: @"ITunesUserPlaylist"]) {
                    SDPlaylist* newPlaylist = [[SDPlaylist alloc] initWithEntity:[NSEntityDescription entityForName:@"SDPlaylist"
                                                                                             inManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext]
                                                  insertIntoManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext];
                    newPlaylist.title = playlist.name;
                    newPlaylist.repeats = (playlist.songRepeat == iTunesERptAll);
                    newPlaylist.shuffles = playlist.shuffle;
                    
                    NSMutableArray* songsToAdd = [NSMutableArray array];
                    
                    for (iTunesFileTrack* track in [playlist.tracks get]) {
                        @autoreleasepool {
                            if ([NSStringFromClass([track class]) isEqualToString: @"ITunesFileTrack"]) {
                                NSString* trackFilePath = [[track location] path];
                                BOOL real = [[NSFileManager defaultManager] fileExistsAtPath:trackFilePath];
                                
                                if (real) {
                                    SDSong* song;
                                    
                                    if (![currentSongFileURLs containsObject: trackFilePath]) {
                                        song = [[SDSong alloc] initWithEntity:[NSEntityDescription entityForName:@"SDSong"
                                                                                          inManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext]
                                               insertIntoManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext];
                                        song.path = trackFilePath;
                                        [song prefetchData];
                                        
                                        [[[SDUserData sharedUserData] masterPlaylist] addSongsObject: song];
                                    }
                                    else {
                                        song = [self songForPath: trackFilePath];
                                    }
                                    
                                    [songsToAdd addObject: song];
                                }
                            }
                        }
                    }
                    
                    [newPlaylist addSongs: [NSOrderedSet orderedSetWithArray: songsToAdd]];
                    [[SDUserData sharedUserData] addPlaylistsObject: newPlaylist];
                }
            }
        }
    }
}



@end
