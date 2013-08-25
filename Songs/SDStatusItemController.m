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
@property (readonly) NSImage* altImage;

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
    [self.statusItem bind:@"alternateImage" toObject:self withKeyPath:@"altImage" options:nil];
}

- (void) hideItem {
    if (!self.isShown)
        return;
    
    self.isShown = NO;
    
    [self.statusItem unbind:@"image"];
    [self.statusItem unbind:@"alternateImage"];
    
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

+ (NSSet*) keyPathsForValuesAffectingAltImage {
    return [self keyPathsForValuesAffectingImage];
}

- (NSImage*) image {
    return [self imageWithHighlighted:NO];
}

- (NSImage*) altImage {
    return [self imageWithHighlighted:YES];
}

- (SDMusicPlayer*) player {
    return [SDMusicPlayer sharedPlayer];
}

- (NSImage*) imageWithHighlighted:(BOOL)isHighlighed {
	NSString *songInfoTitle = nil;
    
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
            songInfoTitle = [stringsToDisplay componentsJoinedByString:[NSString stringWithFormat:@"  %@  ", midSeparator ]];
            songInfoTitle = [NSString stringWithFormat:@"%@  %@  %@", leftSeparator, songInfoTitle, rightSeparator ];
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
    
    NSString* theTitle = @"♫";
    
    if (songInfoTitle) {
        theTitle = songInfoTitle;
    }
    
    return [SDTextImageHelper imageWithTitle:theTitle font:font foreColor:foreColor isHighlighted:isHighlighed];
}

- (void) menuNeedsUpdate:(NSMenu *)menu {
    NSMenuItem* item = [[menu itemArray] objectAtIndex:0];
    
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
