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

@end

@implementation SOPlaylistsTableController

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return (item == nil ? [[[SOSongManager sharedSongManager] playlists] count] : 0);
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return (item == nil ? [[[SOSongManager sharedSongManager] playlists] objectAtIndex:index] : nil);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return (item == nil ? YES : NO);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return (item == nil ? YES : NO);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return YES;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if (item == nil) {
        NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        cellView.textField.stringValue = @"Playlists";
        return cellView;
    }
    else {
        NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        cellView.textField.stringValue = [item title];
        return cellView;
    }
}

@end
