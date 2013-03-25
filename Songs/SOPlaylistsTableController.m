//
//  SOPlaylistsTableController.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOPlaylistsTableController.h"

#import "SOSongManager.h"

@interface SOPlaylistsTableController ()

@property (weak) IBOutlet NSOutlineView* playlistsView;
@property NSString* tempNewPlaylistName;

@end

@implementation SOPlaylistsTableController

- (void) awakeFromNib {
    [self.playlistsView expandItem:@"Playlists"];
    [self.playlistsView selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.playlistsView rowForItem:@"All Songs"]] byExtendingSelection:NO];
    
    [self redrawPlaylistIcons];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil)
        return 2;
    else if ([item isEqual: @"Playlists"])
        return [[[SOSongManager sharedSongManager] playlists] count];
    else
        return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil)
        return [@[@"All Songs", @"Playlists"] objectAtIndex:index];
    else if ([item isEqual: @"Playlists"])
        return [[[SOSongManager sharedSongManager] playlists] objectAtIndex:index];
    else
        return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [item isEqual: @"Playlists"];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [item isEqual: @"Playlists"];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![item isEqual: @"Playlists"];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    return NO;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([item isEqual: @"Playlists"]) {
        NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        cellView.textField.stringValue = item;
        return cellView;
    }
    else if ([item isEqual: @"All Songs"]) {
        NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        cellView.textField.stringValue = item;
        return cellView;
    }
    else {
        NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        cellView.textField.stringValue = [item title];
        return cellView;
    }
}

- (void) redrawPlaylistIcons {
    id selectedItem = [self.playlistsView itemAtRow:[self.playlistsView selectedRow]];
    
    for (NSInteger i = 0; i < [self.playlistsView numberOfRows]; i++) {
        id itemAtRow = [self.playlistsView itemAtRow:i];
        
        NSTableCellView* cellView = [self.playlistsView viewAtColumn:0 row:i makeIfNecessary:NO];
        
        if (selectedItem == itemAtRow)
            cellView.imageView.image = [NSImage imageNamed:@"playrecent-playlist"];
        else
            cellView.imageView.image = [NSImage imageNamed:@"playrecent-playlist-dark"];
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)note {
    [self redrawPlaylistIcons];
    
    id selectedItem = [self.playlistsView itemAtRow:[self.playlistsView selectedRow]];
    NSLog(@"selected playlist changed: %@", selectedItem);
}

- (void) outlineViewSelectionIsChanging:(NSNotification*)note {
    [self redrawPlaylistIcons];
}


// editing

- (IBAction) editPlaylistTitle:(NSTextField*)sender {
    NSString* newName = [sender stringValue];
    id selectedItem = [self.playlistsView itemAtRow:[self.playlistsView selectedRow]];
    
    NSLog(@"did edit! %@ for %@", newName, selectedItem);
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    self.tempNewPlaylistName = [control stringValue];
    return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    return [[[control stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
//    NSLog(@"sel = %@", NSStringFromSelector(command));
    
    if (command == @selector(cancelOperation:)) {
        [control setStringValue:self.tempNewPlaylistName];
    }
    
    return NO;
}

@end
