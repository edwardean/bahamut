//
//  SDPlaylistsViewController.m
//  Songs
//
//  Created by Steven on 8/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSourceListViewController.h"

#import "SDUserDataManager.h"
#import "SDMusicPlayer.h"



#import "SDCoreData.h"
#import "SDPlaylist.h"

static NSString* SDSongDragType = @"SDSongDragType";
static NSString* SDPlaylistDragType = @"SDPlaylistDragType";






@interface SDSourceListViewController ()

@property (weak) IBOutlet NSTableView* playlistsTableView;
@property (weak) IBOutlet NSArrayController* playlistsArrayController;

@end

@implementation SDSourceListViewController

- (NSString*) nibName {
    return @"SourceListView";
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) loadView {
    [super loadView];
    
    [self.playlistsTableView setTarget:self];
    [self.playlistsTableView setDoubleAction:@selector(doubleClickedThing:)];
    
    [self.playlistsTableView registerForDraggedTypes:@[SDPlaylistDragType]];
    [self.playlistsTableView registerForDraggedTypes:@[SDSongDragType]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistAddedNotification:) name:SDPlaylistAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistRenamedNotification:) name:SDPlaylistRenamedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistRemovedNotification:) name:SDPlaylistRemovedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSongDidChange:) name:SDCurrentSongDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatusDidChange:) name:SDPlayerStatusDidChangeNotification object:nil];
}




- (void) refreshKeepingCurrentSelection {
    NSInteger row = [self.playlistsTableView selectedRow];
    [self.playlistsTableView reloadData];
    [self.playlistsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}



- (void) playlistAddedNotification:(NSNotification*)note {
    [self refreshKeepingCurrentSelection];
}

- (void) playlistRenamedNotification:(NSNotification*)note {
    [self refreshKeepingCurrentSelection];
}

- (void) playlistRemovedNotification:(NSNotification*)note {
    [self.playlistsTableView reloadData];
}


//- (SDOldPlaylist*) selectedPlaylist {
//    NSInteger row = [self.playlistsTableView selectedRow];
//    
//    if (row == -1)
//        return nil;
//    else
//        return [[SDSharedData() playlists] objectAtIndex:row];
//}
//
//
//- (BOOL) respondsToSelector:(SEL)aSelector {
//    if (aSelector == @selector(severelyDeleteSomething:)) {
//        if ([[self.playlistsTableView window] firstResponder] != self.playlistsTableView)
//            return NO;
//        
//        if ([self selectedPlaylist] == nil)
//            return NO;
//        
//        if ([[self selectedPlaylist] isMasterPlaylist])
//            return NO;
//        
//        return YES;
//    }
//    else {
//        return [super respondsToSelector:aSelector];
//    }
//}

//- (void) selectPlaylist:(SDOldPlaylist*)playlist {
//    NSUInteger idx = [[SDSharedData() playlists] indexOfObject:playlist];
//    [self.playlistsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx]
//                         byExtendingSelection:NO];
//    
//    [self.playlistsViewDelegate selectPlaylist:playlist];
//}
//
//- (void) doubleClickedThing:(id)sender {
//    NSInteger row = [self.playlistsTableView clickedRow];
//    
//    if (row < 0)
//        return;
//    
//    SDOldPlaylist* playlist = [[SDSharedData() playlists] objectAtIndex:row];
//    [self.playlistsViewDelegate playPlaylist:playlist];
//}
//
//
//
//


- (NSManagedObjectContext*) managedObjectContext {
    return [SDCoreData sharedCoreData].managedObjectContext;
}




//
//
//#pragma mark - Playlists, Drag / Drop
//
//- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
//    SDOldPlaylist* playlist = [[SDSharedData() playlists] objectAtIndex: [rowIndexes firstIndex]];
//    NSUInteger playlistIndex = [[SDSharedData() playlists] indexOfObject:playlist];
//    
//    [pboard setPropertyList:@(playlistIndex)
//                    forType:SDPlaylistDragType];
//    
//    return YES;
//}
//
//- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
//    if ([[[info draggingPasteboard] types] containsObject: SDPlaylistDragType]) {
//        if (operation == NSTableViewDropAbove)
//            return NSDragOperationMove;
//        else
//            return NSDragOperationNone;
//    }
//    else {
//        if (operation == NSTableViewDropOn && ![[[SDSharedData() playlists] objectAtIndex: row] isMasterPlaylist]) {
//            return NSDragOperationCopy;
//        }
//        else
//            return NSDragOperationNone;
//    }
//}
//
//- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
//    if ([[[info draggingPasteboard] types] containsObject: SDPlaylistDragType]) {
//        NSNumber* playlistIndex = [[info draggingPasteboard] propertyListForType:SDPlaylistDragType];
//        SDOldPlaylist* movingPlaylist = [[SDSharedData() playlists] objectAtIndex:[playlistIndex integerValue]];
//
//        [SDSharedData() movePlaylist:movingPlaylist
//                             toIndex:row];
//        
//        return YES;
//    }
//    else {
//        NSDictionary* data = [[info draggingPasteboard] propertyListForType:SDSongDragType];
//        NSArray* uuids = [data objectForKey:@"uuids"];
//        NSArray* songs = [SDUserDataManager songsForUUIDs:uuids];
//        
//        SDOldPlaylist* toPlaylist = [[SDSharedData() playlists] objectAtIndex: row];
//        [toPlaylist addSongs:songs];
//        
//        return YES;
//    }
//}





- (IBAction) makeNewPlaylist:(id)sender {
    SDPlaylist* playlist = [[SDPlaylist alloc] initWithEntity:[NSEntityDescription entityForName:@"SDPlaylist" inManagedObjectContext:[SDCoreData sharedCoreData].managedObjectContext] insertIntoManagedObjectContext:nil];
    
    
    [self.playlistsArrayController addObject: playlist];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.playlistsArrayController setSelectionIndex:2];
//        [self.playlistsArrayController setSelectedObjects: @[playlist]];
    });
}


- (IBAction) renamePlaylist:(id)sender {
//    [self selectedPlaylist].title = [sender stringValue];
}

- (void) editPlaylistTitle {
//    [self.playlistsTableView editColumn:0
//                                    row:[[SDSharedData() playlists] count] - 1
//                              withEvent:nil
//                                 select:YES];
}










- (void) playerStatusDidChange:(NSNotification*)note {
    [self refreshKeepingCurrentSelection];
}

- (void) currentSongDidChange:(NSNotification*)note {
    [self refreshKeepingCurrentSelection];
}



@end
