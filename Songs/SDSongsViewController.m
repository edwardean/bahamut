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








@interface NSTableView (SDHA)
- (NSColor *) _highlightColorForCell: (NSCell *) aCell;
@end



@interface SDSongsTableView : NSTableView
@end

@implementation SDSongsTableView


#pragma mark PRIVATE CLASS METHODS -- NSTableView OVERRIDES

//  Override to let the delegate choose the background color.
//  (This method is private AppKit API, but Googling suggests it’s
//  used regularly and with good results. If Apple stops using this
//  method, we'll just lose the ability to intercept this. We'll
//  assume they won't change the arg or return type for it.)
- (NSColor *) _highlightColorForCell: (NSCell *) aCell; {
    NSColor* result = [super _highlightColorForCell: aCell];
    return result;
    return [NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:1.0];
}


@end





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
    
    for (NSTableColumn* column in [self.allSongsTable tableColumns]) {
        [column setHeaderCell:[[SDSongsTableHeaderCell alloc] initTextCell:[[column headerCell] stringValue]]];
    }
    
    NSRect frame = self.allSongsTable.headerView.frame;
    frame.size.height = 27;
    self.allSongsTable.headerView.frame = frame;
    
//    [self.allSongsTable setr]
    
    
//    [self.allSongsTable setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    
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
