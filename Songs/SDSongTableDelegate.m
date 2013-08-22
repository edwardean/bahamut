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

#define SDSongDragType @"SDSongDragType"







@interface SDTextFieldCell : NSTextFieldCell
@end
@implementation SDTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSBezierPath* path = [NSBezierPath bezierPathWithRect:cellFrame];
    
    [[NSColor whiteColor] setFill];
    [path fill];
    
    if ([[controlView window] firstResponder] == [[controlView window] fieldEditor:NO forObject:controlView]) {
        [[NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:1.0] setStroke];
        
        cellFrame = NSInsetRect(cellFrame, 0.5, 0.5);
        NSBezierPath* path = [NSBezierPath bezierPathWithRect:cellFrame];
        [path setLineWidth:2.0];
        [path stroke];
    }
    
    [self drawInteriorWithFrame:cellFrame inView:controlView];
}

@end






@interface SDSongsTableHeaderCell : NSTableHeaderCell
@end
@implementation SDSongsTableHeaderCell

- (NSRect)drawingRectForBounds:(NSRect)theRect {
    theRect.origin.y += 7;
    return theRect;
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)view {
    [[NSColor colorWithDeviceWhite:0.97 alpha:1.0] setFill];
    [NSBezierPath fillRect:cellFrame];
    
    [self drawInteriorWithFrame:cellFrame inView:view];
}

@end







@interface SDSongsTableView : NSTableView
@end
@implementation SDSongsTableView

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
    NSRange aVisibleRowIndexes = [self rowsInRect:clipRect];
    NSIndexSet* aSelectedRowIndexes = [self selectedRowIndexes];
    
    NSUInteger aRow = aVisibleRowIndexes.location;
    NSUInteger anEndRow = aRow + aVisibleRowIndexes.length;
    
    if (self == [[self window] firstResponder] && [[self window] isMainWindow] && [[self window] isKeyWindow]) {
        [[NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:1.0] setFill];
    }
    else {
        [[NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:0.5] setFill];
    }
    
    for (; aRow < anEndRow; aRow++) {
        if ([aSelectedRowIndexes containsIndex:aRow]) {
            [[NSBezierPath bezierPathWithRect:[self rectOfRow:aRow]] fill];
        }
    }
}

@end



@interface SDSongCell : NSTextFieldCell
@end
@implementation SDSongCell

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView: (NSView *)controlView {
    return nil;
}

@end


@interface SDSongTableDelegate ()

@property (weak) IBOutlet NSTableView* songsTable;
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
    
    [self.songsTable registerForDraggedTypes:@[SDSongDragType]];
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
    if (aSelector == @selector(severelyDeleteSomething:)) {
        if ([[self.songsTable window] firstResponder] != self.songsTable)
            return NO;
        
        if ([[self selectedPlaylist] isMaster])
            return NO;
        
        if ([[self.songsTable selectedRowIndexes] count] < 1)
            return NO;
        
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

- (IBAction) severelyDeleteSomething:(id)sender {
    [[self selectedPlaylist] removeSongs: [NSOrderedSet orderedSetWithArray:[self selectedSongs]]];
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
    if (control == self.searchField && command == @selector(cancelOperation:)) {
        [self toggleSearchBar:NO];
        [self.searchField setStringValue:@""];
        self.filterString = nil;
        return YES;
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













#pragma mark - Songs table, Drag / Drop


- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSArray* songs = [[self.songsArrayController arrangedObjects] objectsAtIndexes:rowIndexes];
    NSArray* uuids = [songs valueForKeyPath:@"objectID.URIRepresentation"];
    
    NSUInteger playlistIndex = [[self.playlistsArrayController arrangedObjects] indexOfObject:[self selectedPlaylist]];
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:@{@"uuids": uuids, @"playlist": @(playlistIndex)}];
    
    [pboard setData:data
            forType:SDSongDragType];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    if (operation == NSTableViewDropAbove && ![[self selectedPlaylist] isMaster])
        return NSDragOperationCopy;
    else
        return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    NSData* rawData = [[info draggingPasteboard] dataForType:SDSongDragType];
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








@end
