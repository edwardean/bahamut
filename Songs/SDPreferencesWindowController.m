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

- (IBAction) showDockIconChanged:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPrefShowDockIconChangedNotification object:nil];
}

- (IBAction) showMenuItemChanged:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPrefShowMenuItemChangedNotification object:nil];
}

- (IBAction) restoreSeparatorDefaults:(id)sender {
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DefaultValues" ofType:@"plist"];
	NSDictionary *initialValues = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
	NSString *leftSeparator = [initialValues objectForKey:SDPrefStatusItemLeftSepKey];
	NSString *midSeparator = [initialValues objectForKey:SDPrefStatusItemMiddleSepKey];
	NSString *rightSeparator = [initialValues objectForKey:SDPrefStatusItemRightSepKey];
	
	[[NSUserDefaults standardUserDefaults] setObject:leftSeparator forKey:SDPrefStatusItemLeftSepKey];
	[[NSUserDefaults standardUserDefaults] setObject:midSeparator forKey:SDPrefStatusItemMiddleSepKey];
	[[NSUserDefaults standardUserDefaults] setObject:rightSeparator forKey:SDPrefStatusItemRightSepKey];
}

@end
