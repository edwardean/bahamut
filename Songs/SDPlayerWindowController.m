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
#import "SDPlayer.h"
#import "SDTrackPositionView.h"


#define SDPlaylistSongsDidChangeNotification @"SDPlaylistSongsDidChangeNotification"
#define SDPlaylistAddedNotification @"SDPlaylistAddedNotification"
#define SDPlaylistRenamedNotification @"SDPlaylistRenamedNotification"
#define SDPlaylistRemovedNotification @"SDPlaylistRemovedNotification"


static NSString* SDMasterPlaylistItem = @"master";
static NSString* SDUserPlaylistsItem = @"playlists";


static NSString* SDSongDragType = @"SDSongDragType";










@interface SDPlayerWindowController ()

@property (weak) IBOutlet NSTextField* currentSongScrollingField;
@property (weak) IBOutlet NSButton* playButton;

@property (weak) IBOutlet NSSearchField* searchField;

@property (weak) IBOutlet NSView* songsTableContainerView;
@property (weak) IBOutlet NSView* searchContainerView;
@property (weak) IBOutlet NSView* songsScrollView;
@property (weak) IBOutlet NSView* playlistOptionsContainerView;

@property (weak) IBOutlet NSTextField* playlistTitleField;
@property (weak) IBOutlet NSButton* repeatButton;
@property (weak) IBOutlet NSButton* shuffleButton;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allSongsDidChange:) name:SDAllSongsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistSongsDidChange:) name:SDPlaylistSongsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistAddedNotification:) name:SDPlaylistAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistRenamedNotification:) name:SDPlaylistRenamedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistRemovedNotification:) name:SDPlaylistRemovedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSongTimeDidChange:) name:SDCurrentSongTimeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSongDidChange:) name:SDCurrentSongDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatusDidChange:) name:SDPlayerStatusDidChangeNotification object:nil];
    
    [self.songsTable setTarget:self];
    [self.songsTable setDoubleAction:@selector(startPlayingSong:)];
    
    [self.playlistsOutlineView setTarget:self];
    [self.playlistsOutlineView setDoubleAction:@selector(startPlayingPlaylist:)];
    
    [self toggleSearchBar:NO];
    
    [self.songsTable registerForDraggedTypes:@[SDSongDragType]];
    [self.playlistsOutlineView registerForDraggedTypes:@[SDSongDragType]];
    
    [self.playlistsOutlineView expandItem:nil expandChildren:YES];
    [self.playlistsOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    [self updatePlaylistOptionsViewStuff];
    [self updateCurrentSongViewStuff];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.killedDelegate playerWindowKilled:self];
}






#pragma mark - Notifications

- (void) playlistAddedNotification:(NSNotification*)note {
    [self refreshPlaylistsKeepingCurrent];
}

- (void) playlistRenamedNotification:(NSNotification*)note {
    [self refreshPlaylistsKeepingCurrent];
}

- (void) playlistRemovedNotification:(NSNotification*)note {
    [self refreshPlaylistsIgnoringCurrent];
}

- (void) allSongsDidChange:(NSNotification*)note {
    if (self.selectedPlaylist == nil)
        [self.songsTable reloadData];
}

- (void) playlistSongsDidChange:(NSNotification*)note {
    if ([note object] == self.selectedPlaylist) {
        [self.songsTable reloadData];
        [self.songsTable deselectAll:nil];
    }
}

- (void) playerStatusDidChange:(NSNotification*)note {
    [self.playButton setTitle: [[SDPlayer sharedPlayer] isPlaying] ? @"Pause" : @"Play"];
}

- (void) currentSongDidChange:(NSNotification*)note {
    [self updateCurrentSongViewStuff];
    [self.songsTable reloadData];
    
    // so we can put an icon next to the now-playing playlist
    
//    [self.playlistsOutlineView reloadItem:[[SDPlayer sharedPlayer] currentPlaylist]];
    [self refreshPlaylistsKeepingCurrent];
}

- (void) currentSongTimeDidChange:(NSNotification*)note {
    self.songPositionSlider.currentValue = [SDPlayer sharedPlayer].currentTime;
}



- (void) refreshPlaylistsIgnoringCurrent {
    [self.playlistsOutlineView reloadItem:SDUserPlaylistsItem reloadChildren:YES];
    [self.playlistsOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void) refreshPlaylistsKeepingCurrent {
    NSIndexSet* sel = [self.playlistsOutlineView selectedRowIndexes];
    [self.playlistsOutlineView reloadItem:SDUserPlaylistsItem reloadChildren:YES];
    [self.playlistsOutlineView selectRowIndexes:sel byExtendingSelection:NO];
}





#pragma mark - Deleting stuff

- (BOOL) respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(severelyDeleteSomething:)) {
        id firstResponder = [[self window] firstResponder];
        
        if (firstResponder == self.songsTable) {
            if ([self showingAllSongs])
                return NO;
            
            if ([[self.songsTable selectedRowIndexes] count] < 1)
                return NO;
            
            return YES;
        }
        else if (firstResponder == self.playlistsOutlineView) {
            if (self.selectedPlaylist)
                return YES;
            
            return NO;
        }
    }
    
    return [super respondsToSelector:aSelector];
}

- (IBAction) severelyDeleteSomething:(id)sender {
    id firstResponder = [[self window] firstResponder];
    
    if (firstResponder == self.songsTable) {
        NSIndexSet* set = [self.songsTable selectedRowIndexes];
        NSArray* songs = [[self.selectedPlaylist songs] objectsAtIndexes:set];
        
        [self.selectedPlaylist removeSongs: songs];
        
        [SDUserDataManager saveUserData];
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPlaylistSongsDidChangeNotification object:self.selectedPlaylist];
    }
    else if (firstResponder == self.playlistsOutlineView) {
        NSMutableArray* playlists = [[SDUserDataManager sharedMusicManager] playlists];
        [playlists removeObject:self.selectedPlaylist];
        
        [SDUserDataManager saveUserData];
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPlaylistRemovedNotification object:nil];
    }
}




#pragma mark - Songs table, Drag / Drop

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSArray* songs = [[self visibleSongs] objectsAtIndexes:rowIndexes];
    NSArray* uuids = [songs valueForKey:@"uuid"];
    NSUInteger playlistIndex = [[[SDUserDataManager sharedMusicManager] playlists] indexOfObject:self.selectedPlaylist];
    
    [pboard setPropertyList:@{@"uuids": uuids, @"playlist": @(playlistIndex)}
                    forType:SDSongDragType];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    if (operation == NSTableViewDropAbove && self.selectedPlaylist != nil)
        return NSDragOperationCopy;
    else
        return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    NSDictionary* data = [[info draggingPasteboard] propertyListForType:SDSongDragType];
    
    NSArray* uuids = [data objectForKey:@"uuids"];
    NSArray* draggingSongs = [SDUserDataManager songsForUUIDs:uuids];
    
    NSUInteger playlistIndex = [[data objectForKey:@"playlist"] unsignedIntegerValue];
    SDPlaylist* fromPlaylist = nil;
    
    if (playlistIndex != NSNotFound)
        fromPlaylist = [[[SDUserDataManager sharedMusicManager] playlists] objectAtIndex:playlistIndex];
    
    if (fromPlaylist == self.selectedPlaylist) {
        // re-arranging
        
    }
    else {
        // adding
        [self.selectedPlaylist addSongs: draggingSongs atIndex:row];
        
        [SDUserDataManager saveUserData];
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPlaylistSongsDidChangeNotification object:self.selectedPlaylist];
    }
    
    return YES;
}

#pragma mark - Playlists, Drag / Drop

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    if ([item isKindOfClass: [SDPlaylist self]])
        return NSDragOperationCopy;
    else
        return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(SDPlaylist*)playlist childIndex:(NSInteger)index {
    NSDictionary* data = [[info draggingPasteboard] propertyListForType:SDSongDragType];
    NSArray* uuids = [data objectForKey:@"uuids"];
    NSArray* songs = [SDUserDataManager songsForUUIDs:uuids];
    [playlist addSongs:songs];
    
    [SDUserDataManager saveUserData];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPlaylistSongsDidChangeNotification object:playlist];
    
    return YES;
}






#pragma mark - Songs table data source



- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [[self visibleSongs] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSArray* songs = [self visibleSongs];
    SDSong* song = [songs objectAtIndex:rowIndex];
    
    if ([[aTableColumn identifier] isEqual:@"playing"]) {
        if (self.selectedPlaylist == [[SDPlayer sharedPlayer] currentPlaylist] && song == [[SDPlayer sharedPlayer] currentSong])
            return [NSImage imageNamed:NSImageNameStatusAvailable];
        else
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






#pragma mark - Search bar


- (IBAction) performFindPanelAction:(id)sender {
    [self toggleSearchBar:YES];
}

- (void) toggleSearchBar:(BOOL)shouldShow {
    BOOL isShowing = ![self.searchContainerView isHidden];
    
    if (shouldShow != isShowing) {
        NSRect songsTableContainerFrame = [self.songsTableContainerView bounds];
        NSRect playlistOptionsFrame = [self.playlistOptionsContainerView frame];
        
        NSRect songsTableFrame;
        NSDivideRect(songsTableContainerFrame, &playlistOptionsFrame, &songsTableFrame, playlistOptionsFrame.size.height, NSMinYEdge);
        
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
        NSLog(@"[%@]", searchString);
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    if (control == self.searchField && command == @selector(cancelOperation:)) {
        [self toggleSearchBar:NO];
        [self.searchField setStringValue:@""];
        return YES;
    }
    
    return NO;
}











#pragma mark - Helpers



- (BOOL) showingAllSongs {
    return (self.selectedPlaylist == nil);
}

- (NSArray*) visibleSongs {
    if (self.selectedPlaylist) {
        return [self.selectedPlaylist songs];
    }
    else {
        return [[SDUserDataManager sharedMusicManager] allSongs];
    }
}




#pragma mark - Updating View Stuff



- (void) updatePlaylistOptionsViewStuff {
    [self.repeatButton setEnabled: ![self showingAllSongs]];
    [self.shuffleButton setEnabled: ![self showingAllSongs]];
    [self.playlistTitleField setEnabled: ![self showingAllSongs]];
    
    [self.repeatButton setAllowsMixedState: [self showingAllSongs]];
    [self.shuffleButton setAllowsMixedState: [self showingAllSongs]];
    
    if ([self showingAllSongs]) {
        [self.repeatButton setState: NSMixedState];
        [self.shuffleButton setState: NSMixedState];
        [self.playlistTitleField setStringValue: @""];
    }
    else {
        [self.repeatButton setState: self.selectedPlaylist.repeats ? NSOnState : NSOffState];
        [self.shuffleButton setState: self.selectedPlaylist.shuffles ? NSOnState : NSOffState];
        [self.playlistTitleField setStringValue: self.selectedPlaylist.title];
    }
}

- (void) updateCurrentSongViewStuff {
    SDSong* currentSong = [[SDPlayer sharedPlayer] currentSong];
    
    if (currentSong) {
        NSString* trackInfo = [NSString stringWithFormat:@"%@ - %@", currentSong.title, currentSong.artist];
        [self.currentSongScrollingField setStringValue:trackInfo];
        self.songPositionSlider.maxValue = [[SDPlayer sharedPlayer] currentSong].duration;
    }
    else {
        [self.currentSongScrollingField setStringValue:@"n/a"];
        self.songPositionSlider.maxValue = 0.0;
        self.songPositionSlider.currentValue = 0.0;
    }
}









#pragma mark - Playlists data source and delegate

- (void) outlineViewSelectionDidChange:(NSNotification*)note {
    NSInteger row = [self.playlistsOutlineView selectedRow];
    
    if (row == -1)
        return;
    
    if (row == 0) {
        self.selectedPlaylist = nil;
    }
    else {
        NSMutableArray* playlists = [[SDUserDataManager sharedMusicManager] playlists];
        self.selectedPlaylist = [playlists objectAtIndex:row - 2];
    }
    
    [self updatePlaylistOptionsViewStuff];
    
    [self.songsTable deselectAll:nil];
    [self.songsTable reloadData];
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
            
            BOOL isPlaying = ([[SDPlayer sharedPlayer] isPlaying] && playlist == [[SDPlayer sharedPlayer] currentPlaylist]);
            [[result imageView] setImage: [NSImage imageNamed: isPlaying ? NSImageNameRightFacingTriangleTemplate : @"playlist"]];
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














#pragma mark - Split view crap





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











#pragma mark - Editing the current Playlist


- (IBAction) renamePlaylist:(NSTextField*)sender {
    self.selectedPlaylist.title = [sender stringValue];
    
    [SDUserDataManager saveUserData];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPlaylistRenamedNotification object:nil];
}

- (IBAction) setPlaylistShuffles:(NSButton*)sender {
    self.selectedPlaylist.shuffles = [sender state] == NSOnState;
    [SDUserDataManager saveUserData];
}

- (IBAction) setPlaylistRepeats:(NSButton*)sender {
    self.selectedPlaylist.repeats = [sender state] == NSOnState;
    [SDUserDataManager saveUserData];
}




#pragma mark - Creating a new Playlist



- (IBAction) makeNewPlaylist:(id)sender {
    NSMutableArray* playlists = [[SDUserDataManager sharedMusicManager] playlists];
    
    SDPlaylist* newlist = [[SDPlaylist alloc] init];
    [playlists addObject:newlist];
    
    [SDUserDataManager saveUserData];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPlaylistAddedNotification object:nil];
    
    NSIndexSet* indices = [NSIndexSet indexSetWithIndex:[playlists count] - 1 + 2];
    [self.playlistsOutlineView selectRowIndexes:indices byExtendingSelection:NO];
    
    [[self.playlistTitleField window] makeFirstResponder: self.playlistTitleField];
}








#pragma mark - Direct IB actions


- (IBAction) nextSong:(id)sender {
    [[SDPlayer sharedPlayer] nextSong];
}

- (IBAction) prevSong:(id)sender {
    [[SDPlayer sharedPlayer] previousSong];
}

- (void) startPlayingPlaylist:(id)sender {
    if ([self.playlistsOutlineView clickedRow] < 2)
        return;
    
    [[SDPlayer sharedPlayer] playPlaylist:self.selectedPlaylist];
}

- (IBAction) startPlayingSong:(id)sender {
    if ([[self.songsTable selectedRowIndexes] count] != 1)
        return;
    
    if ([self showingAllSongs])
        return;
    
    NSInteger row = [self.songsTable selectedRow];
    if (row == -1)
        return;
    
    SDSong* song = [[self.selectedPlaylist songs] objectAtIndex:row];
    
    [[SDPlayer sharedPlayer] playSong:song inPlaylist:self.selectedPlaylist];
}

- (IBAction) playPause:(id)sender {
    if ([SDPlayer sharedPlayer].stopped) {
        if ([self showingAllSongs])
            return;
        
        if ([[self.songsTable selectedRowIndexes] count] == 1) {
            SDSong* song = [[self visibleSongs] objectAtIndex: [self.songsTable selectedRow]];
            [[SDPlayer sharedPlayer] playSong:song inPlaylist:self.selectedPlaylist];
        }
        else {
            [[SDPlayer sharedPlayer] playPlaylist:self.selectedPlaylist];
        }
    }
    else {
        if ([[SDPlayer sharedPlayer] isPlaying])
            [[SDPlayer sharedPlayer] pause];
        else
            [[SDPlayer sharedPlayer] resume];
    }
}

- (void) trackPositionMovedTo:(CGFloat)newValue {
    [[SDPlayer sharedPlayer] seekToTime:newValue];
}

@end
