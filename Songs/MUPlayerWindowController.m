//
//  MUPlayerWindowController.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "MUPlayerWindowController.h"

#import "MUMusicManager.h"
#import "MUPlaylist.h"
#import "MUPlaylistNode.h"

@interface MUPlayerWindowController ()

@property (weak) IBOutlet NSTreeController* treeGuy;
@property (weak) IBOutlet NSOutlineView* sourceList;

@end

@implementation MUPlayerWindowController

- (NSString*) windowNibName {
    return @"PlayerWindow";
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.killedDelegate playerWindowKilled:self];
}

- (MUMusicManager*) musicManager {
    return [MUMusicManager sharedMusicManager];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.sourceList expandItem:nil expandChildren:YES];
    [self.sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return ![[item representedObject] isKindOfClass:[MUPlaylist self]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return [[item representedObject] isKindOfClass:[MUPlaylist self]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    return NO;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item NS_AVAILABLE_MAC(10_7) {
    if ([[item representedObject] isKindOfClass:[MUPlaylist self]]) {
        NSTableCellView* view = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        return view;
    }
    else {
        NSTableCellView* view = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        return view;
    }
}

- (IBAction) makeNewPlaylist:(id)sender {
    [self.treeGuy add:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sourceList editColumn:0 row:[self.sourceList selectedRow] withEvent:nil select:YES];
    });
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(cancelOperation:)) {
        [control setStringValue:[[[self.treeGuy selectedObjects] lastObject] title]];
    }
    
    return NO;
}

@end
