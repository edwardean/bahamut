//
//  SDMediaKeyHijacker.m
//  Songs
//
//  Created by Steven on 8/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDMediaKeyHijacker.h"

#import "SPMediaKeyTap.h"

@interface SDMediaKeyHijacker ()

@property SPMediaKeyTap *keyTap;

@end

// mostly copy+pasted straight out of SPMediaKeyTap example, cuz well, who has time for this crap?

@implementation SDMediaKeyHijacker

+ (void)initialize {
	if ([self class] != [SDMediaKeyHijacker self])
        return;
	
	// Register defaults for the whitelist of apps that want to use media keys
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
                 kMediaKeyUsingBundleIdentifiersDefaultsKey: [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers]
     }];
}

- (void) hijack {
	self.keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
    [self.keyTap startWatchingMediaKeys];
}

-(void)mediaKeyTap:(SPMediaKeyTap*)_keyTap receivedMediaKeyEvent:(NSEvent*)event; {
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
//	int keyRepeat = (keyFlags & 0x1);
	
	if (keyIsPressed) {
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
                [[NSNotificationCenter defaultCenter] postNotificationName:SDMediaKeyPressedPlayPause object:nil];
				break;
				
			case NX_KEYTYPE_FAST:
                [[NSNotificationCenter defaultCenter] postNotificationName:SDMediaKeyPressedNext object:nil];
				break;
				
			case NX_KEYTYPE_REWIND:
                [[NSNotificationCenter defaultCenter] postNotificationName:SDMediaKeyPressedPrevious object:nil];
				break;
		}
	}
}

@end
