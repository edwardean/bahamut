//
//  SDPlaylistTableDelegate.m
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylistTableDelegate.h"




#import "SDUserData.h"
#import "SDPlaylist.h"


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

@property IBOutlet NSArrayController* playlistsArrayController;

@end


@implementation SDPlaylistTableDelegate



- (IBAction) severelyDeleteSomething:(id)sender {
    //    SDPlaylist* playlist = [[self.playlistsArrayController selectedObjects] lastObject];
    //    [[playlist managedObjectContext] deleteObject: playlist];
}




- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    return [tableView makeViewWithIdentifier:@"ExistingPlaylist" owner:self];
}


- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[SDTableRowView alloc] init];
}

//- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
////    NSLog(@"%@", [self.playlistsArrayController selectedObjects]);
//    //    [self.playlistsViewDelegate selectPlaylist: [self selectedPlaylist]];
//}




- (IBAction) makePlaylist:(id)sender {
//    return;
    
    SDPlaylist* playlist = [[SDPlaylist alloc] initWithEntity:[NSEntityDescription entityForName:@"SDPlaylist"
                                                                          inManagedObjectContext:[SDUserData sharedUserData].managedObjectContext]
                               insertIntoManagedObjectContext:[SDUserData sharedUserData].managedObjectContext];
    
    [[SDUserData sharedUserData] addPlaylistsObject: playlist];
    
    NSLog(@"%@", [SDUserData sharedUserData].playlists);
//    [self.playlistsArrayController rearrangeObjects];
    
//    NSLog(@"%@", [self.playlistsArrayController selectedObjects]);
//    [self.playlistsArrayController add: self];
}

@end
