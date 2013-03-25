//
//  SOPlaylistsTableController.h
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOPlaylistsTableController : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

- (void) makeNewPlaylist;

@end
