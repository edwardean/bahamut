//
//  SDDockIconController.m
//  Bahamut
//
//  Created by Steven Degutis on 8/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDDockIconController.h"

#import "SDPreferencesWindowController.h"

@interface SDDockIconController ()

@property BOOL isShown;

@end

@implementation SDDockIconController

- (id) init {
    if (self = [super init]) {
        self.isShown = YES;
    }
    return self;
}

- (void) showIcon {
    if (self.isShown)
        return;
    
    self.isShown = YES;
    
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    ShowHideProcess(&psn, 1);
    SetFrontProcess(&psn);
}

- (void) hideIcon {
    if (!self.isShown)
        return;
    
    self.isShown = NO;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SDPrefShowMenuItemKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPrefShowMenuItemChangedNotification object:nil];
    
    NSArray* wins = [[NSApp windows] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isVisible = YES"]];
    
    for (NSWindow* win in wins) {
        [win setCanHide: NO];
    }
    
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToUIElementApplication);
    ShowHideProcess(&psn, 1);
    SetFrontProcess(&psn);
    
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (NSWindow* win in wins) {
            [win setCanHide: YES];
        }
    });
}

- (void) toggleDockIcon {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SDPrefShowDockIconKey]) {
        [self showIcon];
    }
    else {
        [self hideIcon];
    }
}

@end
