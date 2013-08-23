//
//  SDPreferencesWindowController.m
//  Bahamut
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPreferencesWindowController.h"

@interface SDPreferencesWindowController ()

@end

@implementation SDPreferencesWindowController

- (NSString*) windowNibName {
    return @"PreferencesWindow";
}

- (void) windowDidLoad {
    [[self window] center];
}

@end
