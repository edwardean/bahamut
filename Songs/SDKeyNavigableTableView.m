//
//  SDKeyNavigableTableView.m
//  Songs
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDKeyNavigableTableView.h"

@implementation SDKeyNavigableTableView

- (void) keyDown:(NSEvent *)theEvent {
    NSString* chars = [theEvent charactersIgnoringModifiers];
    NSString* lowerChars = [chars lowercaseString];
    
    if (([theEvent modifierFlags] & NSControlKeyMask) && [lowerChars isEqualToString: @"n"]) {
        [self moveDownAndExtend:[chars isEqualToString: @"N"]];
    }
    else if (([theEvent modifierFlags] & NSControlKeyMask) && [lowerChars isEqualToString: @"p"]) {
        [self moveUpAndExtend:[chars isEqualToString: @"P"]];
    }
    else {
        [super keyDown:theEvent];
    }
}

- (void) moveDownAndExtend:(BOOL)extend {
    NSUInteger nextIndex;
    
    NSUInteger idx = [[self selectedRowIndexes] lastIndex];
    if (idx == NSNotFound)
        nextIndex = 0;
    else
        nextIndex = idx + 1;
    
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:nextIndex] byExtendingSelection: extend];
    [self scrollRowToVisible:[self selectedRow]];
}

- (void) moveUpAndExtend:(BOOL)extend {
    NSUInteger nextIndex;
    
    NSUInteger idx = [[self selectedRowIndexes] firstIndex];
    if (idx == NSNotFound || idx == 0)
        nextIndex = 0;
    else
        nextIndex = idx - 1;
    
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:nextIndex] byExtendingSelection: extend];
    [self scrollRowToVisible:[self selectedRow]];
}

@end
