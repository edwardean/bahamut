//
//  SDPreferencesWindowController.h
//  Bahamut
//
//  Created by Steven on 8/22/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define SDPrefShowMenuItemChangedNotification @"SDPrefShowMenuItemChangedNotification"
#define SDPrefShowMenuItemKey @"SDPrefShowMenuItemKey"

#define SDPrefShowDockIconChangedNotification @"SDPrefShowDockIconChangedNotification"
#define SDPrefShowDockIconKey @"SDPrefShowDockIconKey"

#define SDPrefStatusItemLeftSepKey @"statusItemLeftSeparatorSymbol"
#define SDPrefStatusItemMiddleSepKey @"statusItemMiddleSeparatorSymbol"
#define SDPrefStatusItemRightSepKey @"statusItemRightSeparatorSymbol"

#define SDPrefStatusItemFontSizeKey @"statusItemFontSize"
#define SDPrefStatusItemTitleOptionsKey @"statusItemTitleOptions"

#define SDPrefBringToFrontHotkeyKey @"SDPrefBringToFrontHotkeyKey"

@interface SDPreferencesWindowController : NSWindowController

@end
