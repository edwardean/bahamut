//
//  SDPlaylistViewController.m
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylistViewController.h"





#import "SDUserDataManager.h"
#import "SDSong.h"


#define SDSongDragType @"SDSongDragType"









@interface SDSongsTableHeaderCell : NSTableHeaderCell
@end
@implementation SDSongsTableHeaderCell

- (NSRect)drawingRectForBounds:(NSRect)theRect {
    theRect.origin.y += 7;
    return theRect;
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)view {
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [NSBezierPath fillRect:cellFrame];
    
    [self drawInteriorWithFrame:cellFrame inView:view];
}

@end









@interface SDPlaylistViewController ()

@property (weak) IBOutlet NSView* songsHousingView;

@property (weak) IBOutlet NSTableView* songsTable;
@property (weak) IBOutlet NSView* searchContainerView;
@property (weak) IBOutlet NSSearchField* searchField;
@property (weak) IBOutlet NSScrollView* songsScrollView;

@property NSString* filterString;

@end

@implementation SDPlaylistViewController

- (NSString*) nibName {
    return @"PlaylistView";
}

- (void) loadView {
    [super loadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allSongsDidChange:) name:SDAllSongsDidChangeNotification object:nil];
    
    for (NSTableColumn* column in [self.songsTable tableColumns]) {
        [column setHeaderCell:[[SDSongsTableHeaderCell alloc] initTextCell:[[column headerCell] stringValue]]];
    }
    
    NSRect frame = self.songsTable.headerView.frame;
    frame.size.height = 27;
    self.songsTable.headerView.frame = frame;
    
    [self.songsTable setSortDescriptors:@[]];
    
    [self.songsTable setTarget:self];
    [self.songsTable setDoubleAction:@selector(startPlayingSong:)];
    
    [self toggleSearchBar:NO];
}





- (void) startPlayingSong:(id)sender {
    NSLog(@"ok, playing a song");
}



- (void) allSongsDidChange:(NSNotification*)note {
    [self.songsTable reloadData];
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
    
    theSongs = [theSongs sortedArrayUsingDescriptors:[self.songsTable sortDescriptors]];
    
    return theSongs;
}











- (IBAction) performFindPanelAction:(id)sender {
    [self toggleSearchBar:YES];
}

- (void) toggleSearchBar:(BOOL)shouldShow {
    BOOL isShowing = ![self.searchContainerView isHidden];
    
    if (shouldShow != isShowing) {
        NSRect songsTableFrame = [self.songsHousingView bounds];
        
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
        [self.songsTable reloadData];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    if (control == self.searchField && command == @selector(cancelOperation:)) {
        [self toggleSearchBar:NO];
        [self.searchField setStringValue:@""];
        
        self.filterString = nil;
        [self.songsTable reloadData];
        
        return YES;
    }
    
    return NO;
}


@end
