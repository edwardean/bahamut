//
//  SDSongTableDelegate.m
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSongTableDelegate.h"



#import "SDPlaylist.h"
#import "SDCoreData.h"

#import "SDMusicPlayer.h"










#import "SDSongsTableHeaderCell.h"
#import "SDSongsTableView.h"






@interface SDSongTableDelegate ()

@property (weak) IBOutlet SDSongsTableView* songsTable;
@property (weak) IBOutlet NSArrayController* playlistsArrayController;
@property (weak) IBOutlet NSArrayController* songsArrayController;



@property (readonly) NSPredicate* filterPredicate;
@property NSString* filterString;

@property (weak) IBOutlet NSView* songsHousingView;
@property (weak) IBOutlet NSView* searchContainerView;
@property (weak) IBOutlet NSSearchField* searchField;
@property (weak) IBOutlet NSScrollView* songsScrollView;

@end


@implementation SDSongTableDelegate

- (void) awakeFromNib {
    [super awakeFromNib];
    
    for (NSTableColumn* column in [self.songsTable tableColumns]) {
        [column setHeaderCell:[[SDSongsTableHeaderCell alloc] initTextCell:[[column headerCell] stringValue]]];
    }
    
    NSBox* grayBox = [[NSBox alloc] init];
    grayBox.fillColor = [NSColor colorWithDeviceWhite:0.97 alpha:1.0];
    grayBox.borderColor = [NSColor clearColor];
    grayBox.boxType = NSBoxCustom;
    self.songsTable.cornerView = grayBox;
    
    NSRect headerViewFrame = self.songsTable.headerView.frame;
    headerViewFrame.size.height = 27;
    self.songsTable.headerView.frame = headerViewFrame;
    
    NSRect cornerViewFrame = self.songsTable.cornerView.frame;
    cornerViewFrame.size.height = 27;
    self.songsTable.cornerView.frame = cornerViewFrame;
    
    [self.songsTable setSortDescriptors:@[]];
    
    [self.songsTable setTarget:self];
    [self.songsTable setDoubleAction:@selector(startPlayingSong:)];
    
    [self toggleSearchBar:NO];
    
    [self.songsTable registerForDraggedTypes:@[@"Song"]];
}










- (IBAction) startPlayingSong:(id)sender {
    NSArray* songs = [self selectedSongs];
    
    if ([songs count] != 1)
        return;
    
    [[SDMusicPlayer sharedPlayer] playSong:[songs lastObject]
                                inPlaylist:[self selectedPlaylist]];
}









- (SDPlaylist*) selectedPlaylist {
    return [[self.playlistsArrayController selectedObjects] lastObject];
}

- (NSArray*) selectedSongs {
    return [self.songsArrayController selectedObjects];
}







#pragma mark - Deleting stuff

- (BOOL) respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(copy:)) {
        return ([[self.songsTable window] firstResponder] == self.songsTable) && [[self selectedSongs] count] > 0;
    }
    if (aSelector == @selector(cut:)) {
        return ![[self selectedPlaylist] isMaster] && ([[self.songsTable window] firstResponder] == self.songsTable) && [[self selectedSongs] count] > 0;
    }
    else if (aSelector == @selector(paste:)) {
        return ([[self.songsTable window] firstResponder] == self.songsTable) && ([[NSPasteboard generalPasteboard] availableTypeFromArray:@[@"Song"]] != nil);
    }
    else if (aSelector == @selector(jumpToCurrentSong:)) {
        return ![SDMusicPlayer sharedPlayer].stopped;
    }
    else if (aSelector == @selector(severelyDeleteSomething:)) {
        if ([[self.songsTable window] firstResponder] != self.songsTable)
            return NO;
        
//        if ([[self selectedPlaylist] isMaster])
//            return NO;
        
        if ([[self.songsTable selectedRowIndexes] count] < 1)
            return NO;
        
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

- (IBAction) severelyDeleteSomething:(id)sender {
    if ([[self selectedPlaylist] isMaster]) {
        NSInteger result = NSRunAlertPanel(@"Really remove these songs?",
                                           @"Don't worry, the song files will still be on your hard drive. But they'll be completely removed from this app!",
                                           @"Remove Songs",
                                           @"Wait, never mind!",
                                           nil);
        
        if (result == NSAlertDefaultReturn) {
            for (SDSong* song in [self selectedSongs]) {
                [[SDCoreData sharedCoreData].managedObjectContext deleteObject: song];
            }
        }
    }
    else {
        [[self selectedPlaylist] removeSongs: [NSOrderedSet orderedSetWithArray:[self selectedSongs]]];
    }
    
}









- (IBAction) cut:(id)sender {
    [self copy:sender];
    [[self selectedPlaylist] removeSongs: [NSOrderedSet orderedSetWithArray:[self selectedSongs]]];
}




- (IBAction) copy:(id)sender {
    NSArray* songs = [self selectedSongs];
    NSArray* uuids = [songs valueForKeyPath:@"objectID.URIRepresentation"];
    
    NSUInteger playlistIndex = [[self.playlistsArrayController arrangedObjects] indexOfObject:[self selectedPlaylist]];
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:@{@"uuids": uuids, @"playlist": @(playlistIndex)}];
    
    [[NSPasteboard generalPasteboard] declareTypes:@[@"Song"] owner:nil];
    [[NSPasteboard generalPasteboard] setData:data
                                      forType:@"Song"];
}

- (IBAction) paste:(id)sender {
    NSData* rawData = [[NSPasteboard generalPasteboard] dataForType:@"Song"];
    NSDictionary* data = [NSKeyedUnarchiver unarchiveObjectWithData:rawData];
    
    NSArray* uuids = [data objectForKey:@"uuids"];
    
    NSMutableArray* draggingSongs = [NSMutableArray array];
    for (NSURL* uri in uuids) {
        NSManagedObjectID* mid = [[SDCoreData sharedCoreData].persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
        NSManagedObject* obj = [[SDCoreData sharedCoreData].managedObjectContext objectWithID:mid];
        [draggingSongs addObject:obj];
    }
    
    NSIndexSet* indices = [self.songsTable selectedRowIndexes];
    
    NSUInteger toIndex = [indices lastIndex] + 1;
    
    if ([indices count] == 0) {
        [[self selectedPlaylist] addSongs:[NSOrderedSet orderedSetWithArray:draggingSongs]];
    }
    else {
        [[self selectedPlaylist] addSongs:draggingSongs
                                  atIndex:toIndex];
    }
    
    [self.songsArrayController setSelectedObjects: draggingSongs];
}









+ (NSSet*) keyPathsForValuesAffectingFilterPredicate {
    return [NSSet setWithArray:@[@"filterString"]];
}

- (NSPredicate*) filterPredicate {
    if ([self.filterString length] == 0)
        return nil;
    else
        return [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@) OR (artist CONTAINS[cd] %@) OR (album CONTAINS[cd] %@)",
                self.filterString,
                self.filterString,
                self.filterString
                ];
}







- (IBAction) closeSearchBar:(id)sender {
    [self toggleSearchBar:NO];
    [self.searchField setStringValue:@""];
    self.filterString = nil;
}


- (IBAction) performFindPanelAction:(id)sender {
    [self toggleSearchBar:YES];
}

- (void) toggleSearchBar:(BOOL)shouldShow {
    BOOL isShowing = ![self.searchContainerView isHidden];
    
    if (shouldShow != isShowing) {
        NSRect songsTableFrame = [self.songsHousingView bounds];
        
        if (shouldShow) {
            NSRect searchSectionFrame = [self.searchContainerView frame];
            NSDivideRect(songsTableFrame, &searchSectionFrame, &songsTableFrame, searchSectionFrame.size.height, NSMinYEdge);
        }
        
        [self.searchContainerView setHidden: !shouldShow];
        [self.songsScrollView setFrame:songsTableFrame];
    }
    
    if (shouldShow)
        [[self.searchField window] makeFirstResponder: self.searchField];
}





- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
//    NSLog(@"%@", NSStringFromSelector(command));
    if (control == self.searchField) {
        if (command == @selector(cancelOperation:)) {
            [self toggleSearchBar:NO];
            [self.searchField setStringValue:@""];
            self.filterString = nil;
            [[self.songsTable window] makeFirstResponder: self.songsTable];
            [self.songsTable scrollRowToVisible: [self.songsArrayController selectionIndex]];
            return YES;
        }
        if (command == @selector(insertNewline:)) {
//            [[self.songsTable window] makeFirstResponder: self.songsTable];
            [self startPlayingSong: nil];
            return YES;
        }
        if (command == @selector(moveUp:)) {
            [self.songsTable moveUpAndExtend:NO];
            return YES;
        }
        if (command == @selector(moveDown:)) {
            [self.songsTable moveDownAndExtend:NO];
            return YES;
        }
        if (command == @selector(moveUpAndModifySelection:)) {
            [self.songsTable moveUpAndExtend:YES];
            return YES;
        }
        if (command == @selector(moveDownAndModifySelection:)) {
            [self.songsTable moveDownAndExtend:YES];
            return YES;
        }
    }
    
    return NO;
}















#pragma mark - Playing music


- (IBAction) playPause:(id)sender {
    if ([SDMusicPlayer sharedPlayer].stopped) {
        NSArray* selectedSongs = [self selectedSongs];
        
        if ([selectedSongs count] == 1) {
            [[SDMusicPlayer sharedPlayer] playSong:[selectedSongs lastObject]
                                        inPlaylist:self.selectedPlaylist];
        }
        else {
            [[SDMusicPlayer sharedPlayer] playPlaylist:self.selectedPlaylist];
        }
    }
    else {
        if ([[SDMusicPlayer sharedPlayer] isPlaying])
            [[SDMusicPlayer sharedPlayer] pause];
        else
            [[SDMusicPlayer sharedPlayer] resume];
    }
}







- (IBAction) jumpToSongs:(id)sender {
    [[self.songsTable window] makeFirstResponder: self.songsTable];
}







#pragma mark - Songs table, Drag / Drop


- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSArray* songs = [[self.songsArrayController arrangedObjects] objectsAtIndexes:rowIndexes];
    NSArray* uuids = [songs valueForKeyPath:@"objectID.URIRepresentation"];
    
    NSUInteger playlistIndex = [[self.playlistsArrayController arrangedObjects] indexOfObject:[self selectedPlaylist]];
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:@{@"uuids": uuids, @"playlist": @(playlistIndex)}];
    
    [pboard setData:data
            forType:@"Song"];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    if (operation == NSTableViewDropAbove && ![[self selectedPlaylist] isMaster])
        return NSDragOperationCopy;
    else
        return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    NSData* rawData = [[info draggingPasteboard] dataForType:@"Song"];
    NSDictionary* data = [NSKeyedUnarchiver unarchiveObjectWithData:rawData];
    
    NSArray* uuids = [data objectForKey:@"uuids"];
    
    NSMutableArray* draggingSongs = [NSMutableArray array];
    for (NSURL* uri in uuids) {
        NSManagedObjectID* mid = [[SDCoreData sharedCoreData].persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
        NSManagedObject* obj = [[SDCoreData sharedCoreData].managedObjectContext objectWithID:mid];
        [draggingSongs addObject:obj];
    }
    
    NSUInteger playlistIndex = [[data objectForKey:@"playlist"] unsignedIntegerValue];
    SDPlaylist* fromPlaylist = [[self.playlistsArrayController arrangedObjects] objectAtIndex:playlistIndex];
    
    if (fromPlaylist == [self selectedPlaylist]) {
        [[self selectedPlaylist] moveSongs:draggingSongs
                                   toIndex:row];
    }
    else {
        [[self selectedPlaylist] addSongs:draggingSongs
                                  atIndex:row];
    }
    
    return YES;
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    [aTableView reloadData];
}

















- (IBAction) jumpToCurrentSong:(id)sender {
    if ([SDMusicPlayer sharedPlayer].stopped)
        return;
    
    [self.playlistsArrayController setSelectedObjects: @[[SDMusicPlayer sharedPlayer].currentPlaylist]];
    [self.songsArrayController setSelectedObjects: @[[SDMusicPlayer sharedPlayer].currentSong]];
    [self.songsTable scrollRowToVisible: [self.songsArrayController selectionIndex]];
    [[self.songsTable window] makeFirstResponder: self.songsTable];
}








@end
