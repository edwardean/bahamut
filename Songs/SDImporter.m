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



//- (SDOldSong*) songForURL:(NSURL*)songURL {
//    NSArray* allSongs = [[SDUserDataManager sharedMusicManager] allSongs];
//    allSongs = [allSongs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"url = %@", songURL]];
//    return [allSongs lastObject];
//}
//
//+ (NSArray*) songsForUUIDs:(NSArray*)songUUIDs {
//    NSArray* allSongs = [[SDUserDataManager sharedMusicManager] allSongs];
//    return [allSongs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uuid in %@", songUUIDs]];
//}



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










//
//- (void) importFromiTunes {
//    @autoreleasepool {
//        iTunesApplication* iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
//        iTunesSource* library;
//
//        for (iTunesSource* source in [iTunesApp.sources get]) {
//            if (source.kind == iTunesESrcLibrary) {
//                library = source;
//                break;
//            }
//        }
//
//        NSArray* playlists = [library.playlists get];
//
//        // we can assume iTunes doesn't have duplicates
//        NSArray* currentSongFileURLs = [[SDSharedData() allSongs] valueForKey:@"url"];
//
//        for (iTunesPlaylist* playlist in playlists) {
//            @autoreleasepool {
//                if ([[playlist className] isEqualToString: @"ITunesUserPlaylist"]) {
//                    SDOldPlaylist* newPlaylist = [[SDOldPlaylist alloc] init];
//                    newPlaylist.title = playlist.name;
//                    newPlaylist.repeats = (playlist.songRepeat == iTunesERptAll);
//                    newPlaylist.shuffles = playlist.shuffle;
//
//                    NSMutableArray* songsToAdd = [NSMutableArray array];
//
//                    for (iTunesFileTrack* track in [playlist.tracks get]) {
//                        @autoreleasepool {
//                            if ([NSStringFromClass([track class]) isEqualToString: @"ITunesFileTrack"]) {
//                                NSURL* trackFileURL = [[track location] fileReferenceURL];
//                                BOOL real = [[NSFileManager defaultManager] fileExistsAtPath:[trackFileURL path]];
//
//                                if (real) {
//                                    SDOldSong* song;
//
//                                    if (![currentSongFileURLs containsObject: trackFileURL]) {
//                                        song = [[SDOldSong alloc] init];
//                                        song.url = trackFileURL;
//                                        [song prefetchData];
//
//                                        [self.allSongs addObject:song];
//                                    }
//                                    else {
//                                        song = [self songForURL:trackFileURL];
//                                    }
//
//                                    [songsToAdd addObject: song];
//                                }
//                            }
//                        }
//                    }
//
//                    [newPlaylist addSongs: songsToAdd];
//                    [self insertPlaylist:newPlaylist
//                                 atIndex:[[self playlists] count]];
//                }
//            }
//        }
//    }
//}
//


@end
