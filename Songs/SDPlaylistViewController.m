//
//  SDPlaylistViewController.m
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylistViewController.h"

#import "SDSongsViewController.h"

@interface SDPlaylistViewController ()

@property (weak) IBOutlet NSView* songsHousingView;
@property SDSongsViewController* songsViewController;

@end

@implementation SDPlaylistViewController

- (NSString*) nibName {
    return @"PlaylistView";
}

- (void) loadView {
    [super loadView];
    
    self.songsViewController = [[SDSongsViewController alloc] init];
    [self setNextResponder: self.songsViewController];
    self.songsViewController.playlist = self.playlist;
    
    [[self.songsViewController view] setFrame: [self.songsHousingView bounds]];
    [self.songsHousingView addSubview: [self.songsViewController view]];
}

@end
