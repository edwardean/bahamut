//
//  SDSongsViewController.m
//  Songs
//
//  Created by Steven on 8/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSongsViewController.h"

#import "SDUserDataManager.h"
#import "SDSong.h"


#define SDSongDragType @"SDSongDragType"

@interface SDSongsViewController ()

@property IBOutlet NSTableView* allSongsTable;
@property IBOutlet NSView* searchContainerView;
@property IBOutlet NSSearchField* searchField;
@property IBOutlet NSScrollView* songsScrollView;

@property NSString* filterString;

@end

@implementation SDSongsViewController

- (NSString*) nibName {
    return @"SongsView";
}

- (void) loadView {
    [super loadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allSongsDidChange:) name:SDAllSongsDidChangeNotification object:nil];
    
//    [self.allSongsTable setTarget:self];
//    [self.allSongsTable setDoubleAction:@selector(startPlayingSong:)];
    
    [self toggleSearchBar:NO];
}



- (void) allSongsDidChange:(NSNotification*)note {
    [self.allSongsTable reloadData];
}



- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSArray* songs = [[self visibleSongs] objectsAtIndexes:rowIndexes];
    NSArray* uuids = [songs valueForKey:@"uuid"];
    
    [pboard setPropertyList:@{@"uuids": uuids}
                    forType:SDSongDragType];
    
    return YES;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [[self visibleSongs] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSArray* songs = [self visibleSongs];
    SDSong* song = [songs objectAtIndex:rowIndex];
    
    if ([[aTableColumn identifier] isEqual:@"playing"]) {
        return nil;
    }
    if ([[aTableColumn identifier] isEqual:@"title"]) {
        return [song title];
    }
    if ([[aTableColumn identifier] isEqual:@"artist"]) {
        return [song artist];
    }
    if ([[aTableColumn identifier] isEqual:@"album"]) {
        return [song album];
    }
    
    return nil;
}










- (BOOL) showingAllSongs {
    return (self.playlist == nil);
}

- (NSArray*) visibleSongs {
    NSArray* theSongs = (self.playlist ? [self.playlist songs] : [SDSharedData() allSongs]);
    
    if (self.filterString) {
        theSongs = [theSongs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SDSong* song, NSDictionary *bindings) {
            return ([song.title rangeOfString:self.filterString options:NSCaseInsensitiveSearch].location != NSNotFound)
            || ([song.artist rangeOfString:self.filterString options:NSCaseInsensitiveSearch].location != NSNotFound)
            || ([song.album rangeOfString:self.filterString options:NSCaseInsensitiveSearch].location != NSNotFound);
        }]];
    }
    
    theSongs = [theSongs sortedArrayUsingDescriptors:[self.allSongsTable sortDescriptors]];
    
    return theSongs;
}











- (IBAction) performFindPanelAction:(id)sender {
    [self toggleSearchBar:YES];
}

- (void) toggleSearchBar:(BOOL)shouldShow {
    BOOL isShowing = ![self.searchContainerView isHidden];
    
    if (shouldShow != isShowing) {
        NSRect songsTableFrame = [self.view bounds];
        
        if (shouldShow) {
            NSRect searchSectionFrame = [self.searchContainerView frame];
            NSDivideRect(songsTableFrame, &searchSectionFrame, &songsTableFrame, searchSectionFrame.size.height, NSMaxYEdge);
        }
        
        [self.searchContainerView setHidden: !shouldShow];
        [self.songsScrollView setFrame:songsTableFrame];
    }
    
    if (shouldShow)
        [[self.searchField window] makeFirstResponder: self.searchField];
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if ([aNotification object] == self.searchField) {
        NSString* searchString = [self.searchField stringValue];
        
        if ([[searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
            searchString = nil;
        
        self.filterString = searchString;
        [self.allSongsTable reloadData];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    if (control == self.searchField && command == @selector(cancelOperation:)) {
        [self toggleSearchBar:NO];
        [self.searchField setStringValue:@""];
        
        self.filterString = nil;
        [self.allSongsTable reloadData];
        
        return YES;
    }
    
    return NO;
}


@end
