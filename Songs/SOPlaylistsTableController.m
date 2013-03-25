//
//  SOPlaylistsTableController.m
//  Songs
//
//  Created by Steven Degutis on 3/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SOPlaylistsTableController.h"

#import "SOSongManager.h"
#import "SOPlaylist.h"

@interface SOPlaylistsTableController ()

@property (weak) IBOutlet NSOutlineView* playlistsView;
@property NSString* tempNewPlaylistName;

@end

@implementation SOPlaylistsTableController

- (void) awakeFromNib {
    [self.playlistsView expandItem:@"Playlists"];
    [self.playlistsView selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.playlistsView rowForItem:[SOSongManager sharedSongManager].allSongsPlaylist]] byExtendingSelection:NO];
    
    [self redrawPlaylistIcons];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil)
        return 2;
    else if ([item isEqual: @"Playlists"])
        return [[SOSongManager sharedSongManager].userPlaylists count];
    else
        return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil)
        return [@[[SOSongManager sharedSongManager].allSongsPlaylist, @"Playlists"] objectAtIndex:index];
    else if ([item isEqual: @"Playlists"])
        return [[SOSongManager sharedSongManager].userPlaylists objectAtIndex:index];
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
    else {
        NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        cellView.textField.stringValue = [item title];
        
        BOOL editable = ![item isEqual: [SOSongManager sharedSongManager].allSongsPlaylist];
        
        [cellView.textField setEditable: editable];
        [cellView.textField setSelectable: editable];
        
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
    
    SOPlaylist* selectedItem = [self.playlistsView itemAtRow:[self.playlistsView selectedRow]];
    [SOSongManager sharedSongManager].selectedPlaylist = selectedItem;
    
    NSLog(@"selected playlist changed to: %@", selectedItem);
}

- (void) outlineViewSelectionIsChanging:(NSNotification*)note {
    [self redrawPlaylistIcons];
}


// editing

- (IBAction) editPlaylistTitle:(NSTextField*)sender {
    NSString* newName = [sender stringValue];
    SOPlaylist* selectedPlaylist = [self.playlistsView itemAtRow:[self.playlistsView selectedRow]];
    
    selectedPlaylist.title = newName;
    sender.stringValue = selectedPlaylist.title;
    
    NSLog(@"did edit! %@ for %@", newName, [selectedPlaylist title]);
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




- (void) makeNewPlaylist {
    SOPlaylist* playlist = [[SOSongManager sharedSongManager] makeNewPlaylist];
    
    NSLog(@"%@", self.playlistsView);
    
    [self.playlistsView reloadItem:nil];
    
    NSInteger row = [self.playlistsView rowForItem:playlist];
    [self.playlistsView scrollRowToVisible:row];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playlistsView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [self.playlistsView editColumn:0 row:row withEvent:nil select:YES];
    });
}

@end
