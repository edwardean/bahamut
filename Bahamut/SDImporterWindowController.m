//
//  SDImporterWindowController.m
//  Bahamut
//
//  Created by Steven on 8/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDImporterWindowController.h"

@interface SDImporterWindowController ()

@end

@implementation SDImporterWindowController

- (NSString*) windowNibName {
    return @"ImporterWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[self window] center];
}

@end
