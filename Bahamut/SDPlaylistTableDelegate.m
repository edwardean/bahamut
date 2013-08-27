//
//  SDPlaylistTableDelegate.m
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylistTableDelegate.h"


#import "SDMusicPlayer.h"

#import "SDCoreData.h"
#import "SDUserData.h"

#import "SDTableRowView.h"



@interface SDPlaylistTableDelegate ()

@property (weak) IBOutlet NSTableView* playlistsTable;
@property (weak) IBOutlet NSArrayController* playlistsArrayController;

@end


@implementation SDPlaylistTableDelegate


- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self.playlistsTable registerForDraggedTypes:@[@"Playlist"]];
    [self.playlistsTable registerForDraggedTypes:@[@"Song"]];
    
    [self.playlistsTable setTarget:self];
    [self.playlistsTable setDoubleAction:@selector(doubleClickedThing:)];
    
    [[self.playlistsTable window] makeFirstResponder: self.playlistsTable];
}



- (IBAction) severelyDeleteSomething:(id)sender {
    for (SDPlaylist* playlist in [self.playlistsArrayController selectedObjects]) {
        if ([playlist isMaster])
            continue;
        
        [[playlist managedObjectContext] deleteObject: playlist];
    }
}




- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    return [tableView makeViewWithIdentifier:@"ExistingPlaylist" owner:self];
}


- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[SDTableRowView alloc] init];
}



- (IBAction) makeNewPlaylist:(id)sender {
    SDPlaylist* playlist = [[SDPlaylist alloc] initWithEntity:[NSEntityDescription entityForName:@"SDPlaylist"
                                                                          inManagedObjectContext:[SDUserData sharedUserData].managedObjectContext]
                               insertIntoManagedObjectContext:[SDUserData sharedUserData].managedObjectContext];
    
    [[SDUserData sharedUserData] addPlaylistsObject: playlist];
    
    [self.playlistsArrayController setSelectedObjects: @[playlist]];
    [self.playlistsTable editColumn:0
                                row:[self.playlistsTable selectedRow]
                          withEvent:nil
                             select:YES];
}




- (IBAction) startPlayingPlaylist:(id)sender {
    [[SDMusicPlayer sharedPlayer] playPlaylist: [self selectedPlaylist]];
}




- (SDPlaylist*) selectedPlaylist {
    return [[self.playlistsArrayController selectedObjects] lastObject];
}



- (BOOL) respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(paste:)) {
        return ([[self.playlistsTable window] firstResponder] == self.playlistsTable) && ([[NSPasteboard generalPasteboard] availableTypeFromArray:@[@"Song"]] != nil);
    }
    else if (aSelector == @selector(severelyDeleteSomething:)) {
        if ([[self.playlistsTable window] firstResponder] != self.playlistsTable)
            return NO;
        
        if ([self selectedPlaylist] == nil)
            return NO;
        
        if ([[self selectedPlaylist] isMaster])
            return NO;
        
        return YES;
    }
    else {
        return [super respondsToSelector:aSelector];
    }
}





- (void) doubleClickedThing:(id)sender {
    NSInteger row = [self.playlistsTable clickedRow];
    
    if (row < 0)
        return;
    
    SDPlaylist* playlist = [[self.playlistsArrayController arrangedObjects] objectAtIndex:row];
    [[SDMusicPlayer sharedPlayer] playPlaylist: playlist];
}







- (IBAction) jumpToPlaylists:(id)sender {
    [[self.playlistsTable window] makeFirstResponder: self.playlistsTable];
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
    
    NSUInteger playlistIndex = [[data objectForKey:@"playlist"] unsignedIntegerValue];
    SDPlaylist* fromPlaylist = [[self.playlistsArrayController arrangedObjects] objectAtIndex:playlistIndex];
    
    if (fromPlaylist != [self selectedPlaylist]) {
        [[self selectedPlaylist] addSongs:[NSOrderedSet orderedSetWithArray:draggingSongs]];
    }
}







- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    [NSApp sendAction:@selector(closeSearchBar:) to:nil from:nil];
}








#pragma mark - Playlists, Drag / Drop

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    [pboard setPropertyList:@([rowIndexes firstIndex])
                    forType:@"Playlist"];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    if ([[[info draggingPasteboard] types] containsObject: @"Playlist"]) {
        if (operation == NSTableViewDropAbove)
            return NSDragOperationMove;
        else
            return NSDragOperationNone;
    }
    else {
        if (operation == NSTableViewDropOn && ![[[self.playlistsArrayController arrangedObjects] objectAtIndex: row] isMaster]) {
            return NSDragOperationCopy;
        }
        else
            return NSDragOperationNone;
    }
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    if ([[[info draggingPasteboard] types] containsObject: @"Playlist"]) {
        NSUInteger playlistIndex = [[[info draggingPasteboard] propertyListForType:@"Playlist"] unsignedIntegerValue];
        
        NSDictionary* bindingInfo = [self.playlistsArrayController infoForBinding:@"contentArray"];
        NSMutableOrderedSet* s = [[bindingInfo objectForKey:NSObservedObjectKey] mutableOrderedSetValueForKeyPath:[bindingInfo objectForKey:NSObservedKeyPathKey]];
        
        if (playlistIndex <= row)
            row--;
        
        [s moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:playlistIndex] toIndex:row];
        
        return YES;
    }
    else {
        NSData* rawData = [[info draggingPasteboard] dataForType:@"Song"];
        NSDictionary* data = [NSKeyedUnarchiver unarchiveObjectWithData:rawData];
        
        NSArray* uuids = [data objectForKey:@"uuids"];
        NSMutableArray* songs = [NSMutableArray array];
        for (NSURL* uri in uuids) {
            NSManagedObjectID* mid = [[SDCoreData sharedCoreData].persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
            NSManagedObject* obj = [[SDCoreData sharedCoreData].managedObjectContext objectWithID:mid];
            [songs addObject:obj];
        }
        
        SDPlaylist* toPlaylist = [[self.playlistsArrayController arrangedObjects] objectAtIndex: row];
        [toPlaylist addSongs: [NSOrderedSet orderedSetWithArray:songs]];
        
        return YES;
    }
}






@end
