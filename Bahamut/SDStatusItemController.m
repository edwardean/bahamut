//
//  SDStatusIcon.m
//  Bahamut
//
//  Created by Steven Degutis on 8/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDStatusItemController.h"

#import "SDPreferencesWindowController.h"
#import "SDTextImageHelper.h"

#import "SDMusicPlayer.h"

@interface SDStatusItemController ()

@property IBOutlet NSMenu* statusItemMenu;
@property NSStatusItem *statusItem;

@property BOOL isShown;

@property (readonly) NSImage* image;

@end

@implementation SDStatusItemController

- (void) showItem {
    if (self.isShown)
        return;
    
    self.isShown = YES;
    
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[self.statusItem setHighlightMode:YES];
	[self.statusItem setMenu:self.statusItemMenu];
    
    [self.statusItem bind:@"image" toObject:self withKeyPath:@"image" options:nil];
}

- (void) hideItem {
    if (!self.isShown)
        return;
    
    self.isShown = NO;
    
    [self.statusItem unbind:@"image"];
    
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    self.statusItem = nil;
}

- (void) toggleItem {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SDPrefShowMenuItemKey]) {
        [self showItem];
    }
    else {
        [self hideItem];
    }
}

- (id) defaults {
    return [NSUserDefaults standardUserDefaults];
}

+ (NSSet*) keyPathsForValuesAffectingImage {
    return [NSSet setWithArray:@[
            @"player.currentSong",
            @"player.isPlaying",
            @"player.stopped",
            @"defaults." SDPrefStatusItemLeftSepKey,
            @"defaults." SDPrefStatusItemMiddleSepKey,
            @"defaults." SDPrefStatusItemRightSepKey,
            @"defaults." SDPrefStatusItemFontSizeKey,
            @"defaults." SDPrefStatusItemTitleOptionsKey,
            ]];
}

- (SDMusicPlayer*) player {
    return [SDMusicPlayer sharedPlayer];
}

- (NSImage*) image {
    NSString* theTitle;
    
    SDSong* song = [SDMusicPlayer sharedPlayer].currentSong;
	
	NSArray *titleDisplayOptions = [[NSUserDefaults standardUserDefaults] arrayForKey:SDPrefStatusItemTitleOptionsKey];
	
	NSString *leftSeparator = [[NSUserDefaults standardUserDefaults] stringForKey:SDPrefStatusItemLeftSepKey];
	NSString *midSeparator = [[NSUserDefaults standardUserDefaults] stringForKey:SDPrefStatusItemMiddleSepKey];
	NSString *rightSeparator = [[NSUserDefaults standardUserDefaults] stringForKey:SDPrefStatusItemRightSepKey];
	
	if (![SDMusicPlayer sharedPlayer].stopped) {
		NSMutableArray *stringsToDisplay = [NSMutableArray array];
		
		for (NSDictionary *titleOptions in titleDisplayOptions) {
			NSNumber *enabled = [titleOptions objectForKey:@"Enabled"];
			
			if ([enabled boolValue] == YES) {
				NSString *key = [titleOptions objectForKey:@"SongKey"];
                NSString* value;
                
                if ([key isEqualToString: @"duration"]) {
                    value = SDGetTimeForSeconds(song.duration);
                }
                else if ([key isEqualToString: @"title"]) {
                    value = song.title;
                }
                else if ([key isEqualToString: @"artist"]) {
                    value = song.artist;
                }
                else if ([key isEqualToString: @"album"]) {
                    value = song.album;
                }
                
				if (value)
					[stringsToDisplay addObject:value];
			}
		}
        
        if ([stringsToDisplay count] > 0) {
            theTitle = [stringsToDisplay componentsJoinedByString:[NSString stringWithFormat:@"  %@  ", midSeparator ]];
            theTitle = [NSString stringWithFormat:@"%@  %@  %@", leftSeparator, theTitle, rightSeparator ];
        }
	}
	else {
//		songInfoTitle = [NSString stringWithFormat:@"%@  Bahamut  %@", leftSeparator, rightSeparator ];
	}
	
	NSInteger fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:SDPrefStatusItemFontSizeKey];
	NSFont *font = [NSFont systemFontOfSize:fontSize];
	
	NSColor *foreColor = [NSColor blackColor];
	if ([SDMusicPlayer sharedPlayer].isPlaying == NO)
		foreColor = [foreColor colorWithAlphaComponent:0.65];
    
	NSDisableScreenUpdates();
    dispatch_async(dispatch_get_current_queue(), ^{
        NSEnableScreenUpdates();
    });
    
    if (theTitle == nil) {
        theTitle = @"♪";
        font = [NSFont boldSystemFontOfSize:15];
        foreColor = [NSColor blackColor];
    }
    
    return [SDTextImageHelper imageWithTitle:theTitle
                                        font:font
                                   foreColor:foreColor];
}

- (void) menuNeedsUpdate:(NSMenu *)menu {
    NSMenuItem* item = [[menu itemArray] objectAtIndex:2];
    
    if ([SDMusicPlayer sharedPlayer].isPlaying) {
        [item setImage:[NSImage imageNamed: @"SDPause"]];
        [item setTitle:@"Pause"];
    }
    else {
        [item setImage:[NSImage imageNamed: NSImageNameRightFacingTriangleTemplate]];
        [item setTitle:@"Play"];
    }
}

- (IBAction) playPause:(id)sender {
    [NSApp sendAction:@selector(playPause:) to:nil from:nil];
}

@end
