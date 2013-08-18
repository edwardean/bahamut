//
//  SDAllSongsWindowController.m
//  Songs
//
//  Created by Steven on 8/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDAllSongsWindowController.h"

#import "SDSongsViewController.h"

@interface SDAllSongsWindowController ()

@property SDSongsViewController* vc;

@end

@implementation SDAllSongsWindowController

- (NSString*) windowNibName {
    return @"AllSongsWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.vc = [[SDSongsViewController alloc] init];
    
    NSView* sv = [[self window] contentView];
    [[self.vc view] setFrame: [sv bounds]];
    [sv addSubview:[self.vc view]];
    
    [self setNextResponder: self.vc];
}


@end
