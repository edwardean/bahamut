//
//  MUPlayerWindowController.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlayerWindowController.h"

#import "SDPersistenceManager.h"

#import "SDPlaylist.h"

#import "SDTrackPositionView.h"

static NSString* SDMasterPlaylistItem = @"master";
static NSString* SDUserPlaylistsItem = @"playlists";

@interface SDPlayerWindowController ()

@property (weak) IBOutlet NSOutlineView* sourceList;
@property (weak) IBOutlet SDTrackPositionView* songPositionSlider;

@end

@implementation SDPlayerWindowController

- (NSString*) windowNibName {
    return @"PlayerWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.sourceList expandItem:nil expandChildren:YES];
    [self.sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.songPositionSlider unbind:@"currentValue"];
    [self.songPositionSlider unbind:@"maxValue"];
    
    [self.killedDelegate playerWindowKilled:self];
}










- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return nil;
}











- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *result;
    if (item == SDUserPlaylistsItem) {
        result = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        [[result textField] setStringValue:@"Playlists"];
    }
    else {
        result = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        
        if (item == SDMasterPlaylistItem) {
            [[result textField] setStringValue:@"All Songs"];
        }
        else {
            SDPlaylist* playlist = item;
            [[result textField] setStringValue:playlist.title];
        }
    }
    return result;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil)
        return 2;
    else if (item == SDMasterPlaylistItem)
        return 0;
    else if (item == SDUserPlaylistsItem)
        return [[[SDPersistenceManager sharedMusicManager] playlists] count];
    else
        return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (item == SDUserPlaylistsItem)
        return YES;
    else
        return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        if (index == 0)
            return SDMasterPlaylistItem;
        else if (index == 1)
            return SDUserPlaylistsItem;
    }
    else if (item == SDUserPlaylistsItem) {
        return [[[SDPersistenceManager sharedMusicManager] playlists] objectAtIndex:index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return (item == SDUserPlaylistsItem);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return (item != SDUserPlaylistsItem);
}














////- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
////    if (commandSelector == @selector(cancelOperation:)) {
////        [control setStringValue:[[self selectedPlaylist] title]];
////    }
////    
////    return NO;
////}






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










- (IBAction) makeNewPlaylist:(id)sender {
//    SDPlaylist* newlist = [[SDPlaylist alloc] init];
//    
//    NSUInteger idxs[2] = {1, [[[SDPersistenceManager sharedMusicManager] playlists] count]};
//    [self.treeGuy insertObject:newlist atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:idxs length:2]];
//    [self.sourceList editColumn:0 row:[self.sourceList selectedRow] withEvent:nil select:YES];
}

- (IBAction) nextSong:(id)sender {
//    [[SDMusicPlayer sharedMusicPlayer] nextSong];
}

- (IBAction) prevSong:(id)sender {
//    [[SDMusicPlayer sharedMusicPlayer] prevSong];
}

- (IBAction) playPause:(id)sender {
//    if ([SDMusicPlayer sharedMusicPlayer].status == SDMusicPlayerStatusPlaying) {
//        [[SDMusicPlayer sharedMusicPlayer] pause];
//    }
//    else {
//        [[SDMusicPlayer sharedMusicPlayer] playSong:[self selectedSong]
//                                         inPlaylist:[self selectedPlaylist]];
//    }
}

- (void) trackPositionMovedTo:(CGFloat)newValue {
//    [[SDMusicPlayer sharedMusicPlayer] seekToTime:newValue];
}

@end
