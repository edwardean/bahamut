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

#import "SDSongCacher.h"

#import "iTunes.h"

#import "SDImporterWindowController.h"

@implementation SDImporter

+ (void) importSongsUnderPaths:(NSArray*)paths {
    NSMutableArray *urls = [NSMutableArray array];
    for (NSString* path in paths) {
        [urls addObject: [NSURL fileURLWithPath:path]];
    }
    [SDImporter importSongsUnderURLs:urls];
}

+ (void) importSongsUnderURLs:(NSArray*)urls {
    SDImporterWindowController* windowController = [[SDImporterWindowController alloc] init];
    
    [windowController showWindow:self];
    [windowController.progressBar setIndeterminate:NO];
    
    [self filterOnlyPlayableURLs:urls completionHandler:^(NSArray *urls) {
        SDPlaylist* allSongsPlaylist = [[SDUserData sharedUserData] masterPlaylist];
        
        @autoreleasepool {
            NSMutableArray* importingURLs = [urls mutableCopy];
            NSSet* existingURLs = [self existingSongURLs];
            [importingURLs removeObjectsInArray: [existingURLs allObjects]];
            
            NSUInteger count = [importingURLs count];
            [windowController.progressBar setMaxValue:count];
            
            int i = 0;
            for (NSURL* url in importingURLs) {
                @autoreleasepool {
                    AVURLAsset* asset = [AVURLAsset assetWithURL:url];
                    if (![asset isPlayable])
                        continue;
                    
                    SDSong* song = [[SDSong alloc] initWithEntity:[NSEntityDescription entityForName:@"SDSong"
                                                                              inManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext]
                                   insertIntoManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext];
                    song.url = url;
                    [SDSongCacher prefetchDataFor: song];
                    
                    [allSongsPlaylist addSongsObject: song];
                }
                
                i++;
                [windowController.progressBar setDoubleValue: i];
            }
        }
        
        [windowController close];
    }];
}

+ (void) filterOnlyPlayableURLs:(NSArray*)lookInURLs completionHandler:(void(^)(NSArray* urls))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSMutableArray* foundURLs = [NSMutableArray array];
            
            NSFileManager* fileManager = [[NSFileManager alloc] init];
            
            for (NSURL* url in lookInURLs) {
                NSURL* theUrl = url;
                
                @autoreleasepool {
                    BOOL isDir;
                    BOOL exists = [fileManager fileExistsAtPath:[theUrl path] isDirectory:&isDir];
                    
                    if (!exists)
                        continue;
                    
                    if (isDir) {
                        NSDirectoryEnumerator* dirEnum = [fileManager enumeratorAtURL:theUrl
                                                           includingPropertiesForKeys:@[]
                                                                              options:NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles
                                                                         errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                             NSLog(@"error for [%@]! %@", url, error);
                                                                             return YES;
                                                                         }];
                        
                        for (NSURL* fileURL in dirEnum) {
                            [foundURLs addObject:[[fileURL URLByResolvingSymlinksInPath] fileReferenceURL]];
                        }
                    }
                    else {
                        [foundURLs addObject:[theUrl fileReferenceURL]];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(foundURLs);
            });
        }
    });
}




+ (NSSet*) existingSongURLs {
    NSManagedObjectContext* ctx = [SDCoreData sharedCoreData].managedObjectContext;
    
    NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:@"SDSong"];
    
    NSError* __autoreleasing error;
    NSArray* allSongs = [ctx executeFetchRequest:req error:&error];
    
    NSMutableSet* set = [NSMutableSet set];
    
    for (SDSong* song in allSongs) {
        [set addObject: song.url];
    }
    
    return set;
}




+ (SDSong*) songForURL:(NSURL*)url {
    NSManagedObjectContext* ctx = [SDCoreData sharedCoreData].managedObjectContext;
    
    NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:@"SDSong"];
    [req setPredicate:[NSPredicate predicateWithFormat:@"URL = %@", url]];
    
    NSError* __autoreleasing error;
    NSArray* matchingSongs = [ctx executeFetchRequest:req error:&error];
    
    assert([matchingSongs count] <= 1);
    return [matchingSongs lastObject];
}




+ (void) importFromiTunes {
    SDImporterWindowController* windowController = [[SDImporterWindowController alloc] init];
    [windowController showWindow:self];
    [windowController.progressBar setIndeterminate:NO];
    
    [self getItunesStuffWithCompletionHandler:^(NSArray *playlistInfos) {
        // we can safely assume both iTunes and our library doesn't have duplicates
        NSSet* currentSongFileURLs = [self existingSongURLs];
        
        NSUInteger totalNumSongs = [[playlistInfos valueForKeyPath:@"songs.@unionOfArrays.self"] count];
        [windowController.progressBar setMaxValue:totalNumSongs];
        
        int i = 0;
        for (NSDictionary* playlistInfo in playlistInfos) {
            SDPlaylist* newPlaylist = [[SDPlaylist alloc] initWithEntity:[NSEntityDescription entityForName:@"SDPlaylist"
                                                                                     inManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext]
                                          insertIntoManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext];
            
            newPlaylist.title = [playlistInfo objectForKey:@"title"];
            newPlaylist.repeats = [[playlistInfo objectForKey:@"repeats"] boolValue];
            newPlaylist.shuffles = [[playlistInfo objectForKey:@"shuffles"] boolValue];
            
            for (NSURL* trackFileURL in [playlistInfo objectForKey:@"songs"]) {
                SDSong* song;
                
                if (![currentSongFileURLs containsObject: trackFileURL]) {
                    song = [[SDSong alloc] initWithEntity:[NSEntityDescription entityForName:@"SDSong"
                                                                      inManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext]
                           insertIntoManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext];
                    song.url = trackFileURL;
                    [SDSongCacher prefetchDataFor: song];
                    
                    [[[SDUserData sharedUserData] masterPlaylist] addSongsObject: song];
                }
                else {
                    song = [self songForURL: trackFileURL];
                }
                
                [newPlaylist addSongsObject: song];
                [[SDUserData sharedUserData] addPlaylistsObject: newPlaylist];
                
                [windowController.progressBar setDoubleValue:++i];
            }
            
        }
        
        [windowController close];
    }];
}

+ (void) getItunesStuffWithCompletionHandler:(void(^)(NSArray* playlistInfos))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            iTunesApplication* iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
            iTunesSource* library;
            
            for (iTunesSource* source in [iTunesApp.sources get]) {
                if (source.kind == iTunesESrcLibrary) {
                    library = source;
                    break;
                }
            }
            
            NSMutableArray* playlistInfos = [NSMutableArray array];
            
            for (iTunesPlaylist* playlist in [library.playlists get]) {
                @autoreleasepool {
                    if ([[playlist className] isEqualToString: @"ITunesUserPlaylist"]) {
                        NSMutableDictionary* playlistInfo = [@{@"title": playlist.name,
                                                             @"repeats": @(playlist.songRepeat == iTunesERptAll),
                                                             @"shuffles": @(playlist.shuffle),
                                                             } mutableCopy];
                        
                        NSMutableArray* songsToAdd = [NSMutableArray array];
                        
                        for (iTunesFileTrack* track in [playlist.tracks get]) {
                            @autoreleasepool {
                                if ([NSStringFromClass([track class]) isEqualToString: @"ITunesFileTrack"]) {
                                    NSString* trackFilePath = [[track location] path];
                                    BOOL real = [[NSFileManager defaultManager] fileExistsAtPath:trackFilePath];
                                    
                                    if (real) {
                                        [songsToAdd addObject: [[NSURL fileURLWithPath:trackFilePath] fileReferenceURL]];
                                    }
                                }
                            }
                        }
                        
                        [playlistInfo setObject:songsToAdd forKey:@"songs"];
                        [playlistInfos addObject: playlistInfo];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(playlistInfos);
            });
        }
    });
}




@end
