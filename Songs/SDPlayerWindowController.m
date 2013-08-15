//
//  MUPlayerWindowController.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlayerWindowController.h"

#import "SDUserDataManager.h"

#import "SDPlaylist.h"

#import "SDTrackPositionView.h"

static NSString* SDMasterPlaylistItem = @"master";
static NSString* SDUserPlaylistsItem = @"playlists";

@interface SDPlayerWindowController ()

@property (weak) IBOutlet NSView* playerSection;
@property (weak) IBOutlet NSView* listingSection;

@property (weak) IBOutlet NSTableView* songsTable;
@property (weak) IBOutlet NSOutlineView* playlistsOutlineView;
@property (weak) IBOutlet SDTrackPositionView* songPositionSlider;

@property SDPlaylist* selectedPlaylist;

@end

@implementation SDPlayerWindowController

- (NSString*) windowNibName {
    return @"PlayerWindow";
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allSongsDidChange:) name:SDAllSongsDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistsDidVisiblyChange:) name:SDPlaylistsDidVisiblyChange object:nil];
    
    [self.songsTable setTarget:self];
    [self.songsTable setDoubleAction:@selector(startPlayingSong:)];
    
    [self.playlistsOutlineView expandItem:nil expandChildren:YES];
    [self.playlistsOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    [self showOrHidePlayer];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.killedDelegate playerWindowKilled:self];
}


- (void) playlistsDidVisiblyChange:(NSNotification*)note {
    [self.playlistsOutlineView reloadItem:SDUserPlaylistsItem reloadChildren:YES];
}

- (void) allSongsDidChange:(NSNotification*)note {
    // TODO: only reload if master playlist is shown!
    [self.songsTable reloadData];
}





- (void) showOrHidePlayer {
    NSRect contentFrame = [[[self window] contentView] frame];
    
    if (self.selectedPlaylist) {
        [self.playerSection setHidden:NO];
        
        CGFloat playerHeight = [self.playerSection frame].size.height;
        
        NSRect bla;
        NSDivideRect(contentFrame, &bla, &contentFrame, playerHeight, NSMaxYEdge);
        
        [self.listingSection setFrame:contentFrame];
    }
    else {
        [self.playerSection setHidden:YES];
        [self.listingSection setFrame:contentFrame];
    }
}






- (NSArray*) visibleSongs {
    if (self.selectedPlaylist) {
        return [self.selectedPlaylist songs];
    }
    else {
        return [[SDUserDataManager sharedMusicManager] allSongs];
    }
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [[self visibleSongs] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSArray* songs = [self visibleSongs];
    SDSong* song = [songs objectAtIndex:rowIndex];
    
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









- (void) outlineViewSelectionDidChange:(NSNotification*)note {
    NSInteger row = [self.playlistsOutlineView selectedRow];
    
    if (row == 0) {
        self.selectedPlaylist = nil;
    }
    else {
        NSMutableArray* playlists = [[SDUserDataManager sharedMusicManager] playlists];
        self.selectedPlaylist = [playlists objectAtIndex:row - 2];
    }
    
    [self.songsTable reloadData];
    
    [self showOrHidePlayer];
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
        return [[[SDUserDataManager sharedMusicManager] playlists] count];
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
        return [[[SDUserDataManager sharedMusicManager] playlists] objectAtIndex:index];
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
    NSMutableArray* playlists = [[SDUserDataManager sharedMusicManager] playlists];
    
    SDPlaylist* newlist = [[SDPlaylist alloc] init];
    [playlists addObject:newlist];
    
    [SDUserDataManager saveUserData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPlaylistsDidVisiblyChange object:nil];
    
//    NSIndexSet* indices = [NSIndexSet indexSetWithIndex:[playlists count] - 1 + 2];
//    [self.sourceList selectRowIndexes:indices byExtendingSelection:NO];
//    [self.sourceList editColumn:0 row:[self.sourceList selectedRow] withEvent:nil select:YES];
    
}

- (IBAction) nextSong:(id)sender {
//    [[SDMusicPlayer sharedMusicPlayer] nextSong];
}

- (IBAction) prevSong:(id)sender {
//    [[SDMusicPlayer sharedMusicPlayer] prevSong];
}

- (IBAction) startPlayingSong:(id)sender {
    NSInteger row = [self.songsTable selectedRow];
    if (row == -1)
        return;
    
    SDSong* song = [[self visibleSongs] objectAtIndex:row];
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
