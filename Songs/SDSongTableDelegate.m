//
//  SDSongTableDelegate.m
//  Songs
//
//  Created by Steven on 8/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDSongTableDelegate.h"




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

@property IBOutlet NSTableView* songsTable;

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
    
//    [self toggleSearchBar:NO];
    
//    [self.songsTable registerForDraggedTypes:@[SDSongDragType]];
}


@end
