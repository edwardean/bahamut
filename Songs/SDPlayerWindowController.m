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
#import "SDMusicPlayer.h"
#import "SDTrackPositionView.h"



#import "SDSongListViewController.h"
#import "SDSourceListViewController.h"





//#import "SDPlaylistChooserView.h"


//static NSString* SDSongDragType = @"SDSongDragType";
//static NSString* SDPlaylistDragType = @"SDPlaylistDragType";










@interface SDPlayerWindowController ()

@property (weak) IBOutlet NSView* playlistsViewHouser;
@property SDSourceListViewController* playlistsViewController;
@property SDPlaylist* selectedPlaylist;

@property (weak) IBOutlet NSView* playlistViewHouser;
@property NSMutableArray* playlistViewControllers;

@property (weak) IBOutlet SDTrackPositionView* songPositionSlider;
@property (weak) IBOutlet NSButton* playButton;
@property (weak) IBOutlet NSTextField* currentSongInfoField;

//@property (weak) IBOutlet NSView* songsTableContainerView;
//@property (weak) IBOutlet NSView* searchContainerView;
//@property (weak) IBOutlet NSView* songsScrollView;
//@property (weak) IBOutlet NSView* playlistOptionsContainerView;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistAddedNotification:) name:SDPlaylistAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistRemovedNotification:) name:SDPlaylistRemovedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSongTimeDidChange:) name:SDCurrentSongTimeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSongDidChange:) name:SDCurrentSongDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatusDidChange:) name:SDPlayerStatusDidChangeNotification object:nil];
    
//    [self.playlistsOutlineView registerForDraggedTypes:@[SDSongDragType]];
//    [self.playlistsOutlineView registerForDraggedTypes:@[SDPlaylistDragType]];
    
    [self updateCurrentSongViewStuff];
    
    
    
    
    self.playlistViewControllers = [NSMutableArray array];
    
    for (SDPlaylist* playlist in [SDSharedData() playlists]) {
        SDSongListViewController* vc = [[SDSongListViewController alloc] init];
        vc.playlist = playlist;
        [self.playlistViewControllers addObject:vc];
    }
    
    
    [[self window] setBackgroundColor:[NSColor whiteColor]];
    
    self.playlistsViewController = [[SDSourceListViewController alloc] init];
    self.playlistsViewController.playlistsViewDelegate = self;
    [[self.playlistsViewController view] setFrame:[self.playlistsViewHouser frame]];
    [self.playlistsViewHouser addSubview:[self.playlistsViewController view]];
    
    [self setNextResponder:self.playlistsViewController];
    
    self.selectedPlaylist = [[SDSharedData() playlists] objectAtIndex:0];
    [self.playlistsViewController selectPlaylist: self.selectedPlaylist];
    
//    self.window.styleMask = NSBorderlessWindowMask;
//    [self.window setMovableByWindowBackground:YES];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.killedDelegate playerWindowKilled:self];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [SDSharedData() undoManager];
}






#pragma Playlists



- (void) selectPlaylist:(SDPlaylist*)playlist {
    self.selectedPlaylist = playlist;
    
    NSUInteger idx = [[SDSharedData() playlists] indexOfObject: self.selectedPlaylist];
    
    SDSongListViewController* vc = [self.playlistViewControllers objectAtIndex: idx];
    
    [[self.playlistViewHouser subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[vc view] setFrame: [self.playlistViewHouser bounds]];
    [self.playlistViewHouser addSubview:[vc view]];
    [self.playlistsViewController setNextResponder: vc];
    
//    NSLog(@"%@", self.selectedPlaylist);
}

- (void) playPlaylist:(SDPlaylist*)playlist {
    [[SDMusicPlayer sharedPlayer] playPlaylist: playlist];
}



#pragma mark - Notifications

- (void) playlistAddedNotification:(NSNotification*)note {
    SDPlaylist* playlist = [note object];
    
    NSUInteger idx = [[SDSharedData() playlists] indexOfObject:playlist];
    
    SDSongListViewController* vc = [[SDSongListViewController alloc] init];
    vc.playlist = playlist;
    [self.playlistViewControllers insertObject:vc atIndex:idx];
    
//    NSLog(@"its %@", playlist);
}

- (void) playlistRemovedNotification:(NSNotification*)note {
    SDPlaylist* playlist = [note object];
    
    NSUInteger idx = [self.playlistViewControllers indexOfObjectPassingTest:^BOOL(SDSongListViewController* obj, NSUInteger idx, BOOL *stop) {
        return obj.playlist == playlist;
    }];
    
    [self.playlistViewControllers removeObjectAtIndex:idx];
    
//    NSLog(@"its %@", playlist);
}





- (void) playerStatusDidChange:(NSNotification*)note {
    [self.playButton setTitle: [[SDMusicPlayer sharedPlayer] isPlaying] ? @"Pause" : @"Play"];
}

- (void) currentSongDidChange:(NSNotification*)note {
    [self updateCurrentSongViewStuff];
//    [self.songsTable reloadData];
    
    // so we can put an icon next to the now-playing playlist
    
//    [self.playlistsOutlineView reloadItem:[[SDPlayer sharedPlayer] currentPlaylist]];
//    [self refreshPlaylistsKeepingCurrent];
}

- (void) currentSongTimeDidChange:(NSNotification*)note {
    self.songPositionSlider.currentValue = [SDMusicPlayer sharedPlayer].currentTime;
}









//#pragma mark - Playlists, Drag / Drop
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
//    if ([items count] == 1 && [[items lastObject] isKindOfClass: [SDPlaylist self]]) {
//        SDPlaylist* playlist = [items lastObject];
//        NSUInteger playlistIndex = [[SDSharedData() playlists] indexOfObject:playlist];
//        
//        [pboard setPropertyList:@(playlistIndex)
//                        forType:SDPlaylistDragType];
//        
//        return YES;
//    }
//    return NO;
//}
//
//- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
//    if ([[[info draggingPasteboard] types] containsObject: SDPlaylistDragType]) {
//        if (item == nil)
//            return NSDragOperationNone;
//        else
//            return NSDragOperationCopy;
//    }
//    else {
//        if ([item isKindOfClass: [SDPlaylist self]])
//            return NSDragOperationCopy;
//        else
//            return NSDragOperationNone;
//    }
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index {
//    if ([[[info draggingPasteboard] types] containsObject: SDPlaylistDragType]) {
//        NSNumber* playlistIndex = [[info draggingPasteboard] propertyListForType:SDPlaylistDragType];
//        SDPlaylist* movingPlaylist = [[SDSharedData() playlists] objectAtIndex:[playlistIndex integerValue]];
//        
//        [SDSharedData() movePlaylist:movingPlaylist
//                             toIndex:index];
//        
//        return YES;
//    }
//    else {
//        NSDictionary* data = [[info draggingPasteboard] propertyListForType:SDSongDragType];
//        NSArray* uuids = [data objectForKey:@"uuids"];
//        NSArray* songs = [SDUserDataManager songsForUUIDs:uuids];
//        SDPlaylist* playlist = item;
//        [playlist addSongs:songs];
//        return YES;
//    }
//}






//#pragma mark - Songs table data source
//
//
//
//- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
//    return [[self visibleSongs] count];
//}
//
//- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
//    NSArray* songs = [self visibleSongs];
//    SDSong* song = [songs objectAtIndex:rowIndex];
//    
//    if ([[aTableColumn identifier] isEqual:@"playing"]) {
//        if (self.selectedPlaylist == [[SDMusicPlayer sharedPlayer] currentPlaylist] && song == [[SDMusicPlayer sharedPlayer] currentSong])
//            return [NSImage imageNamed:NSImageNameRightFacingTriangleTemplate];
//        else
//            return nil;
//    }
//    if ([[aTableColumn identifier] isEqual:@"title"]) {
//        return [song title];
//    }
//    if ([[aTableColumn identifier] isEqual:@"artist"]) {
//        return [song artist];
//    }
//    if ([[aTableColumn identifier] isEqual:@"album"]) {
//        return [song album];
//    }
//    
//    return nil;
//}
















- (void) updateCurrentSongViewStuff {
    SDSong* currentSong = [[SDMusicPlayer sharedPlayer] currentSong];
    
    if (currentSong) {
        NSString* trackInfo = [NSString stringWithFormat:@"%@ - %@", currentSong.title, currentSong.artist];
        [self.currentSongInfoField setStringValue:trackInfo];
        self.songPositionSlider.maxValue = [[SDMusicPlayer sharedPlayer] currentSong].duration;
    }
    else {
        [self.currentSongInfoField setStringValue:@"n/a"];
        self.songPositionSlider.maxValue = 0.0;
        self.songPositionSlider.currentValue = 0.0;
    }
}









//#pragma mark - Playlists data source and delegate
//
//- (void) outlineViewSelectionDidChange:(NSNotification*)note {
//    NSInteger row = [self.playlistsOutlineView selectedRow];
//    
//    if (row == -1)
//        return;
//    
////    if (row == 0) {
////        self.selectedPlaylist = nil;
////    }
////    else {
//        NSMutableArray* playlists = [SDSharedData() playlists];
//        self.selectedPlaylist = [playlists objectAtIndex:row];
////    }
//    
//    [self.songsTable deselectAll:nil];
//    [self.songsTable reloadData];
//}
//
//- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
//    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
//    
//    SDPlaylist* playlist = item;
//    [[cellView textField] setStringValue:playlist.title];
//    
//    BOOL isPlaying = ([[SDMusicPlayer sharedPlayer] isPlaying] && playlist == [[SDMusicPlayer sharedPlayer] currentPlaylist]);
//    [[cellView imageView] setImage: [NSImage imageNamed: isPlaying ? NSImageNameRightFacingTriangleTemplate : @"playlist"]];
//    
//    return cellView;
//}
//
//- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
//    if (item == nil)
//        return [[SDSharedData() playlists] count];
//    else
//        return 0;
//}
//
//- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
//    if (item == nil)
//        return [[SDSharedData() playlists] objectAtIndex:index];
//    else
//        return nil;
//}
//
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
//    if (item == nil)
//        return YES;
//    else
//        return NO;
//}
























#pragma mark - Creating a new Playlist



- (IBAction) makeNewPlaylist:(id)sender {
    NSMutableArray* playlists = [SDSharedData() playlists];
    
    SDPlaylist* newPlaylist = [[SDPlaylist alloc] init];
    [SDSharedData() insertPlaylist:newPlaylist atIndex:[playlists count]];
    
    [self.playlistsViewController selectPlaylist:newPlaylist];
    
//    [[self.playlistTitleField window] makeFirstResponder: self.playlistTitleField];
}








#pragma mark - Playing music


- (IBAction) nextSong:(id)sender {
    [[SDMusicPlayer sharedPlayer] nextSong];
}

- (IBAction) prevSong:(id)sender {
    [[SDMusicPlayer sharedPlayer] previousSong];
}

//- (IBAction) startPlayingSong:(id)sender {
//    if ([[self.songsTable selectedRowIndexes] count] != 1)
//        return;
//    
//    if ([self showingAllSongs])
//        return;
//    
//    NSInteger row = [self.songsTable selectedRow];
//    if (row == -1)
//        return;
//    
//    SDSong* song = [[self visibleSongs] objectAtIndex:row];
//    
//    [[SDMusicPlayer sharedPlayer] playSong:song inPlaylist:self.selectedPlaylist];
//}

- (IBAction) playPause:(id)sender {
    if ([SDMusicPlayer sharedPlayer].stopped) {
//        if ([self showingAllSongs])
//            return;
//        
//        if ([[self.songsTable selectedRowIndexes] count] == 1) {
//            SDSong* song = [[self visibleSongs] objectAtIndex: [self.songsTable selectedRow]];
//            [[SDMusicPlayer sharedPlayer] playSong:song inPlaylist:self.selectedPlaylist];
//        }
//        else {
//            [[SDMusicPlayer sharedPlayer] playPlaylist:self.selectedPlaylist];
//        }
    }
    else {
        if ([[SDMusicPlayer sharedPlayer] isPlaying])
            [[SDMusicPlayer sharedPlayer] pause];
        else
            [[SDMusicPlayer sharedPlayer] resume];
    }
}

- (void) trackPositionMovedTo:(CGFloat)newValue {
    [[SDMusicPlayer sharedPlayer] seekToTime:newValue];
}

@end
