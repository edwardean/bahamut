//
//  SDTrackPositionView.h
//  Songs
//
//  Created by Steven Degutis on 3/26/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SDTrackPositionViewDelegate <NSObject>

- (void) trackPositionMovedTo:(CGFloat)newValue;

@end

@interface SDTrackPositionView : NSControl

@property CGFloat maxValue;
@property CGFloat currentValue;

@property (weak) IBOutlet id<SDTrackPositionViewDelegate> trackPositionDelegate;

@end
