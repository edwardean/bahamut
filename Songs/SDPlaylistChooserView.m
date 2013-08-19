//
//  SDPlaylistChooserView.m
//  Songs
//
//  Created by Steven on 8/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlaylistChooserView.h"

#import "SDPlaylistTitleView.h"

@interface SDPlaylistChooserView ()

@property (weak) SDPlaylist* chosenPlaylist;
@property NSMutableArray* playlistTitleViews;

@end

@implementation SDPlaylistChooserView

- (id) initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.playlistTitleViews = [NSMutableArray array];
    }
    return self;
}

- (void) selectPlaylist:(SDPlaylist*)playlist {
    NSUInteger idx = [self.playlists indexOfObject:playlist];
    
    for (SDPlaylistTitleView* titleView in self.playlistTitleViews) {
        titleView.selected = NO;
        [titleView setNeedsDisplay:YES];
    }
    
    SDPlaylistTitleView* titleView = [self.playlistTitleViews objectAtIndex:idx];
    
    titleView.selected = YES;
    self.chosenPlaylist = playlist;
    
    [self.delegate didChoosePlaylist:playlist];
}

- (void) redrawPlaylists {
    [self.playlistTitleViews removeAllObjects];
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGRect bounds = [self bounds];
    CGFloat topY = NSMaxY(bounds);
    
    CGFloat height = 30.0;
    
    __weak SDPlaylistChooserView* _self = self;
    
    for (SDPlaylist* playlist in self.playlists) {
        CGRect playlistRect = bounds;
        playlistRect.origin.y = topY - height;
        playlistRect.size.height = height;
        
        SDPlaylistTitleView* titleView = [[SDPlaylistTitleView alloc] init];
        __weak SDPlaylistTitleView* _titleView = titleView;
        
        titleView.hoverCursor = [NSCursor pointingHandCursor];
        titleView.canGetKeyboard = YES;
        
        titleView.clicked = ^(NSEvent* event){
            [_self selectPlaylist:playlist];
        };
        
        titleView.draw = ^{
            [NSGraphicsContext saveGraphicsState];
            
            NSColor* backColor;
            NSColor* textColor;
            
            if (_titleView.selected) {
                backColor = [NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:1.0];
                textColor = [NSColor whiteColor];
            }
            else if (_titleView.hovered) {
                backColor = [NSColor colorWithDeviceHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:0.5];
                textColor = [NSColor textColor];
            }
            else {
                backColor = [NSColor whiteColor];
                textColor = [NSColor textColor];
            }
            
            [backColor setFill];
            [[NSBezierPath bezierPathWithRect:[_titleView bounds]] fill];
            
            [playlist.title drawAtPoint:NSMakePoint(10.0, 7.0)
                         withAttributes:@{
                    NSFontAttributeName: [NSFont labelFontOfSize:12.0],
         NSForegroundColorAttributeName: textColor,
             }];
            
            [NSGraphicsContext restoreGraphicsState];
        };
        
        titleView.pressedUp = ^(NSEvent* event) {
            if (_self.chosenPlaylist == nil || [_self.playlists count] == 0 || _self.chosenPlaylist == [_self.playlists objectAtIndex:0])
                return;
            
            NSUInteger idx = [_self.playlists indexOfObject: _self.chosenPlaylist];
            idx--;
            
            [_self selectPlaylist: [_self.playlists objectAtIndex:idx]];
        };
        
        titleView.pressedDown = ^(NSEvent* event) {
            if (_self.chosenPlaylist == nil || _self.chosenPlaylist == [_self.playlists lastObject])
                return;
            
            NSUInteger idx = [_self.playlists indexOfObject: _self.chosenPlaylist];
            idx++;
            
            [_self selectPlaylist: [_self.playlists objectAtIndex:idx]];
        };
        
        titleView.frame = playlistRect;
        
        [self addSubview:titleView];
        
        [self.playlistTitleViews addObject: titleView];
        
        topY -= height;
    }
}

@end
