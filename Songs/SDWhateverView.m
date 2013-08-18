//
//  SDWhateverView.m
//  Songs
//
//  Created by Steven on 8/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDWhateverView.h"

#import "SDPlaylist.h"

void SDFillColor(NSRect rect, NSColor* color) {
    [color setFill];
    [[NSBezierPath bezierPathWithRect:rect] fill];
}

@interface SDWhateverView ()

@property (copy) void(^dragOp)(SDWhateverView* me, NSEvent* e);
@property CGFloat playlistsWidth;

@end

@implementation SDWhateverView

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.playlistsWidth = 200.0;
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    NSTrackingArea* area = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                        options:NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect
                                                          owner:self
                                                       userInfo:nil];
    [self addTrackingArea:area];
}

- (void) drawBackground {
    NSColor* backgroundColor = [NSColor colorWithCalibratedWhite:0.95 alpha:1.0];
    SDFillColor([self bounds], backgroundColor);
}

- (CGFloat) margin { return 10.0; }
- (CGFloat) playerHeight { return 75.0; }
- (NSColor*) sectionColor { return [NSColor colorWithCalibratedWhite:0.85 alpha:1.0]; }

- (void) getPlayerRect:(NSRect*)playerRect playlistsRect:(NSRect*)playlistsRect songsRect:(NSRect*)songsRect dividerRect:(NSRect*)dividerRect {
    NSRect _playerRect, _playlistsRect, _songsRect, _dividerRect, garbage;
    
    CGFloat margin = [self margin];
    NSRect mainArea = NSInsetRect([self bounds], margin, margin);
    
    NSDivideRect(mainArea, &_playerRect, &_songsRect, [self playerHeight], NSMaxYEdge);
    NSDivideRect(_playerRect, &garbage, &_playerRect, margin, NSMinYEdge);
    NSDivideRect(_songsRect, &_playlistsRect, &_songsRect, [self playlistsWidth], NSMinXEdge);
    NSDivideRect(_songsRect, &_dividerRect, &_songsRect, margin, NSMinXEdge);
    
    if (playerRect) *playerRect = _playerRect;
    if (playlistsRect) *playlistsRect = _playlistsRect;
    if (songsRect) *songsRect = _songsRect;
    if (dividerRect) *dividerRect = _dividerRect;
}

- (void) drawPlayer {
    NSRect playerRect;
    [self getPlayerRect:&playerRect playlistsRect:NULL songsRect:NULL dividerRect:NULL];
    SDFillColor(playerRect, [self sectionColor]);
}

- (void) drawPlaylists {
    NSRect playlistsRect;
    [self getPlayerRect:NULL playlistsRect:&playlistsRect songsRect:NULL dividerRect:NULL];
    SDFillColor(playlistsRect, [self sectionColor]);
    
    CGFloat top = NSMaxY(playlistsRect);
    
    for (SDPlaylist* playlist in self.playlists) {
        NSRect singlePlaylistRect;
        singlePlaylistRect.size.width = playlistsRect.size.width;
        singlePlaylistRect.size.height = 30.0;
        singlePlaylistRect.origin.x = playlistsRect.origin.x;
        singlePlaylistRect.origin.y = top - singlePlaylistRect.size.height;
        
        top -= singlePlaylistRect.size.height;
        
        NSPoint mousePoint = [self convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil];
        
        if (NSPointInRect(mousePoint, singlePlaylistRect)) {
            SDFillColor(singlePlaylistRect, [NSColor colorWithCalibratedHue:206.0/360.0 saturation:0.67 brightness:0.92 alpha:1.0]);
        }
        else {
            SDFillColor(singlePlaylistRect, [NSColor whiteColor]);
        }
    }
}

- (void) drawSongs {
    NSRect songsRect;
    [self getPlayerRect:NULL playlistsRect:NULL songsRect:&songsRect dividerRect:NULL];
    SDFillColor(songsRect, [self sectionColor]);
}

- (void)drawRect:(NSRect)dirtyRect {
    [self drawBackground];
    [self drawPlayer];
    [self drawPlaylists];
    [self drawSongs];
}

- (void) mouseMoved:(NSEvent *)theEvent {
    NSRect dividerRect, playlistsRect;
    [self getPlayerRect:NULL playlistsRect:&playlistsRect songsRect:NULL dividerRect:&dividerRect];
    
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (NSPointInRect(mousePoint, dividerRect)) {
        [[NSCursor resizeLeftRightCursor] set];
    }
    else {
        [[NSCursor arrowCursor] set];
    }
    
    [self setNeedsDisplay:YES];
}

- (void) mouseDown:(NSEvent *)theEvent {
    if ([theEvent clickCount] == 1) {
        NSRect dividerRect;
        [self getPlayerRect:NULL playlistsRect:NULL songsRect:NULL dividerRect:&dividerRect];
        
        NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        if (NSPointInRect(mousePoint, dividerRect)) {
            CGFloat offset = self.playlistsWidth - mousePoint.x;
            self.dragOp = ^(SDWhateverView* self, NSEvent* event) {
                NSPoint mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];
                self.playlistsWidth = mousePoint.x + offset;
                
                self.playlistsWidth = MAX(self.playlistsWidth, 200.0);
                self.playlistsWidth = MIN(self.playlistsWidth, [self bounds].size.width - 200.0);
                
                [self setNeedsDisplay:YES];
            };
        }
    }
    
//    NSLog(@"%ld", [theEvent clickCount]);
}

- (void) mouseDragged:(NSEvent *)theEvent {
    if (self.dragOp)
        self.dragOp(self, theEvent);
}

- (void) mouseUp:(NSEvent *)theEvent {
    self.dragOp = nil;
}

@end
