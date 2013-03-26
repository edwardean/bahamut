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
#import "MUPlaylistCollection.h"

@interface MUPlayerWindowController ()

@property (weak) IBOutlet NSTreeController* treeGuy;
@property (weak) IBOutlet NSOutlineView* sourceList;

@end

@implementation MUPlayerWindowController

- (NSString*) windowNibName {
    return @"PlayerWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.sourceList expandItem:nil expandChildren:YES];
    [self.sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.killedDelegate playerWindowKilled:self];
}

- (MUMusicManager*) musicManager {
    return [MUMusicManager sharedMusicManager];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [[item representedObject] isKindOfClass:[MUPlaylistCollection self]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![[item representedObject] isKindOfClass:[MUPlaylistCollection self]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    return NO;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item NS_AVAILABLE_MAC(10_7) {
    BOOL isPlaylist = ![[item representedObject] isKindOfClass:[MUPlaylistCollection self]];
    NSTableCellView* view = [outlineView makeViewWithIdentifier: (isPlaylist? @"DataCell" : @"HeaderCell") owner:self];
    return view;
}

- (IBAction) makeNewPlaylist:(id)sender {
    MUPlaylist* newlist = [[MUPlaylist alloc] init];
    
    NSUInteger idxs[2];
    idxs[0] = 1;
    idxs[1] = [[MUMusicManager sharedMusicManager].userPlaylistsNode.playlists count];
    [self.treeGuy insertObject:newlist atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:idxs length:2]];
    [self.sourceList editColumn:0 row:[self.sourceList selectedRow] withEvent:nil select:YES];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(cancelOperation:)) {
        [control setStringValue:[[[self.treeGuy selectedObjects] lastObject] title]];
    }
    
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
    return MAX(proposedMin, 150.0);
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
    return MIN(proposedMax, [splitView frame].size.width - 150.0);
}

- (void)splitView:(NSSplitView*)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    CGFloat w = [[[sender subviews] objectAtIndex:0] frame].size.width;
    [sender adjustSubviews];
    [sender setPosition:w ofDividerAtIndex:0];
}

@end
