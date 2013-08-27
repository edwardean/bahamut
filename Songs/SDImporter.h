//
//  SDImporter.h
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDImporter : NSObject

+ (void) importSongsUnderPaths:(NSArray*)paths;
+ (void) importSongsUnderURLs:(NSArray*)urls;
+ (void) importFromiTunes;

@end
