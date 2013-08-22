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
#import "SDPlaylist.h"





static NSString* SDSongDragType = @"SDSongDragType";
static NSString* SDPlaylistDragType = @"SDPlaylistDragType";



@interface SDTableRowView : NSTableRowView
@end

@implementation SDTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if ([[self window] firstResponder] == [self superview] && [[self window] isKeyWindow]) {
        [[NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:1.0] setFill];
        [[NSBezierPath bezierPathWithRect:self.bounds] fill];
    }
    else {
        [[NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:0.5] setFill];
        [[NSBezierPath bezierPathWithRect:self.bounds] fill];
    }
}

@end






@interface SDPlaylistTableDelegate ()

@property (weak) IBOutlet NSTableView* playlistsTable;
@property (weak) IBOutlet NSArrayController* playlistsArrayController;

@end


@implementation SDPlaylistTableDelegate


- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self.playlistsTable registerForDraggedTypes:@[SDPlaylistDragType]];
    [self.playlistsTable registerForDraggedTypes:@[SDSongDragType]];
    
    [self.playlistsTable setTarget:self];
    [self.playlistsTable setDoubleAction:@selector(doubleClickedThing:)];
}



- (IBAction) severelyDeleteSomething:(id)sender {
    SDPlaylist* playlist = [[self.playlistsArrayController selectedObjects] lastObject];
    [[playlist managedObjectContext] deleteObject: playlist];
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






- (SDPlaylist*) selectedPlaylist {
    return [[self.playlistsArrayController selectedObjects] lastObject];
}



- (BOOL) respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(severelyDeleteSomething:)) {
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



// TODO: selectPlaylist:




// TODO: update "right triangle" icon when song playing-status changes





- (void) doubleClickedThing:(id)sender {
    NSInteger row = [self.playlistsTable clickedRow];
    
    if (row < 0)
        return;
    
    SDPlaylist* playlist = [[self.playlistsArrayController arrangedObjects] objectAtIndex:row];
    [[SDMusicPlayer sharedPlayer] playPlaylist: playlist];
}

















#pragma mark - Playlists, Drag / Drop

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    [pboard setPropertyList:@([rowIndexes firstIndex])
                    forType:SDPlaylistDragType];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    if ([[[info draggingPasteboard] types] containsObject: SDPlaylistDragType]) {
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
    if ([[[info draggingPasteboard] types] containsObject: SDPlaylistDragType]) {
        NSUInteger playlistIndex = [[[info draggingPasteboard] propertyListForType:SDPlaylistDragType] unsignedIntegerValue];
        
        NSDictionary* bindingInfo = [self.playlistsArrayController infoForBinding:@"contentArray"];
        NSMutableOrderedSet* s = [[bindingInfo objectForKey:NSObservedObjectKey] mutableOrderedSetValueForKeyPath:[bindingInfo objectForKey:NSObservedKeyPathKey]];
        
        if (playlistIndex <= row)
            row--;
        
        [s moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:playlistIndex] toIndex:row];
        
        return YES;
    }
    else {
        NSData* rawData = [[info draggingPasteboard] dataForType:SDSongDragType];
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
