//
//  MUPlayerWindowController.m
//  Songs
//
//  Created by Steven Degutis on 3/25/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDPlayerWindowController.h"

#import "SDMusicPlayer.h"

#import "SDCoreData.h"

#import "SDPlaylistTableDelegate.h"
#import "SDSongTableDelegate.h"

#import "SDImporter.h"

#import <objc/runtime.h>




#define SDWindowTitleBackgroundColor [NSColor colorWithCalibratedWhite:0.91 alpha:1.0]
#define SDUnfocusedWindowTitleBackgroundColor [NSColor colorWithCalibratedWhite:0.96 alpha:1.0]

#define SDWindowBackgroundColor [NSColor colorWithCalibratedWhite:0.96 alpha:1.0]

#define SDWindowInsideBordersColor [NSColor colorWithCalibratedWhite:0.70 alpha:1.0]




@interface SDClipView : NSView
@end
@implementation SDClipView

- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = [self bounds];
    CGFloat r = 4.0;
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:r yRadius:r];
    [path addClip];
    
    CGFloat titleBarHeight = 34.0;
    CGFloat controlBarHeight = 66.0;
    CGFloat bottomBarHeight = 37.0;
    
    NSRect titleBar, controlBar, bottomBar;
    NSRect titleBarBorder, controlBarBorder, bottomBarBorder;
    NSRect bla;
    
    NSDivideRect(rect, &bottomBar, &bla, bottomBarHeight, NSMinYEdge);
    NSDivideRect(rect, &titleBar, &bla, titleBarHeight + controlBarHeight, NSMaxYEdge);
    NSDivideRect(titleBar, &titleBar, &controlBar, titleBarHeight, NSMaxYEdge);
    
    NSDivideRect(titleBar, &titleBarBorder, &titleBar, 1.0, NSMinYEdge);
    NSDivideRect(controlBar, &controlBarBorder, &controlBar, 1.0, NSMinYEdge);
    NSDivideRect(bottomBar, &bottomBarBorder, &bottomBar, 1.0, NSMaxYEdge);
    
    [SDWindowTitleBackgroundColor setFill];
    [NSBezierPath fillRect:NSIntersectionRect(dirtyRect, titleBar)];
    
    [SDWindowBackgroundColor setFill];
    [NSBezierPath fillRect:NSIntersectionRect(dirtyRect, controlBar)];
    
    [SDWindowBackgroundColor setFill];
    [NSBezierPath fillRect:NSIntersectionRect(dirtyRect, bottomBar)];
    
    [SDWindowInsideBordersColor setFill];
    [NSBezierPath fillRect:NSIntersectionRect(dirtyRect, titleBarBorder)];
    [NSBezierPath fillRect:NSIntersectionRect(dirtyRect, controlBarBorder)];
    [NSBezierPath fillRect:NSIntersectionRect(dirtyRect, bottomBarBorder)];
}

@end




@interface SDBox : NSView

@property CALayer* borderLayer;

@property BOOL borderBottom;
@property BOOL drawsBackground;

@end
@implementation SDBox


- (void) awakeFromNib {
    [self setWantsLayer:YES];
    
//    NSLog(@"%d", self.borderBottom);
    
    self.borderLayer = [[CALayer alloc] init];
    self.borderLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    self.borderLayer.backgroundColor = SDWindowInsideBordersColor.CGColor;
    
    CGRect r = self.layer.bounds, bla;
    CGRectDivide(r, &r, &bla, 1.0, self.borderBottom ? NSMinYEdge : NSMaxYEdge);
    self.borderLayer.frame = r;
    
    [self.layer addSublayer:self.borderLayer];
}

- (void) viewDidMoveToWindow {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeKeyWindow:) name:NSWindowDidBecomeKeyNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResignKeyWindow:) name:NSWindowDidResignKeyNotification object:[self window]];
}

- (void) didBecomeKeyWindow:(NSNotification*)note {
    if (self.drawsBackground)
        self.layer.backgroundColor = SDWindowTitleBackgroundColor.CGColor;
}

- (void) didResignKeyWindow:(NSNotification*)note {
    if (self.drawsBackground)
        self.layer.backgroundColor = SDUnfocusedWindowTitleBackgroundColor.CGColor;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end



@interface SDPlayerWindow : NSWindow
@end

@implementation SDPlayerWindow

- (BOOL) canBecomeKeyWindow { return YES; }
- (BOOL) canBecomeMainWindow { return YES; }

- (BOOL) respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(performClose:) || aSelector == @selector(performZoom:) || aSelector == @selector(performMiniaturize:))
        return NO;
    else
        return [super respondsToSelector:aSelector];
}

@end



@interface SDPlayerWindowController ()

@property IBOutlet SDPlaylistTableDelegate* playlistTableDelegate;
@property IBOutlet SDSongTableDelegate* songTableDelegate;

@property (weak) IBOutlet NSSlider* songPositionSlider;
@property (weak) IBOutlet NSButton* playButton;
@property (weak) IBOutlet NSButton* prevButton;
@property (weak) IBOutlet NSButton* nextButton;
@property (weak) IBOutlet NSTextField* currentSongInfoField;
@property (weak) IBOutlet NSTextField* timeElapsedField;
@property (weak) IBOutlet NSTextField* timeRemainingField;
@property (weak) IBOutlet NSSlider* volumeSlider;
@property (weak) IBOutlet NSSlider* rateSlider;

@property NSBox* dragIndicatorBox;

@end

@implementation SDPlayerWindowController

- (NSString*) windowNibName {
    return @"PlayerWindow";
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setNextResponder: self.playlistTableDelegate];
    [self.playlistTableDelegate setNextResponder: self.songTableDelegate];
    
    
    [[self window] registerForDraggedTypes:@[NSFilenamesPboardType]];
    
    [[self window] setTitle:@"Bahamut"];
    [[self window] setMovableByWindowBackground:YES];
    [[self window] setBackgroundColor:[NSColor clearColor]];
//    [[self window] setHasShadow:YES];
    [[self window] setOpaque:NO];
//    [[self window] setAlphaValue:0.0];
    
    
    
    
    
    [self bindViews];
    
    if (![SDMusicPlayer sharedPlayer].stopped) {
        NSDisableScreenUpdates();
        
        double delayInSeconds = 0.05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [NSApp sendAction:@selector(jumpToCurrentSong:) to:nil from:nil];
            
            dispatch_async(dispatch_get_current_queue(), ^{
                NSEnableScreenUpdates();
            });
        });
    }
}

- (void) windowWillClose:(NSNotification *)notification {
    [self unbindViews];
    [self.killedDelegate playerWindowKilled:self];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[SDCoreData sharedCoreData].managedObjectContext undoManager];
}

- (IBAction) performClose:(id)sender {
    [self close];
}

- (IBAction) performZoom:(id)sender {
    [[self window] zoom:sender];
}

- (IBAction) performMiniaturize:(id)sender {
    [[self window] miniaturize:self];
}






// import via dragging into window

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender {
    self.dragIndicatorBox = [[NSBox alloc] init];
    self.dragIndicatorBox.boxType = NSBoxCustom;
    self.dragIndicatorBox.borderWidth = 0.0;
    self.dragIndicatorBox.fillColor = [[NSColor blackColor] colorWithAlphaComponent:0.2];
    [self.dragIndicatorBox setFrame: [[[self window] contentView] bounds]];
    
    [[[self window] contentView] addSubview: self.dragIndicatorBox];
    
    return NSDragOperationLink;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender {
    [self.dragIndicatorBox removeFromSuperview];
    self.dragIndicatorBox = nil;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
    NSArray *paths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    [SDImporter importSongsUnderPaths:paths];
    
    return YES;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender {
    [self.dragIndicatorBox removeFromSuperview];
    self.dragIndicatorBox = nil;
}







- (NSManagedObjectContext*) managedObjectContext {
    return [SDCoreData sharedCoreData].managedObjectContext;
}







- (void) bindViews {
    [self.prevButton bind:@"enabled" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [self.nextButton bind:@"enabled" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"stopped" options:@{NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [self.playButton bind:@"image" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"isPlaying" options:@{NSValueTransformerNameBindingOption: @"SDPlayingImageTransformer"}];
    
    [self.volumeSlider bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"player.volume" options:nil];
    [self.rateSlider bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"player.rate" options:nil];
    
    [self.songPositionSlider bind:@"maxValue" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentSong.duration" options:nil];
    [self.songPositionSlider bind:@"doubleValue" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentTime" options:nil];
    
    [self.timeElapsedField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentTime" options:@{NSValueTransformerNameBindingOption: @"SDTimeForSeconds"}];
    [self.timeRemainingField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"remainingTime" options:@{NSValueTransformerNameBindingOption: @"SDTimeForSeconds"}];
    
    [self.currentSongInfoField bind:@"value" toObject:[SDMusicPlayer sharedPlayer] withKeyPath:@"currentSong" options:@{NSValueTransformerNameBindingOption: @"SDSongInfoTransformer"}];
}

- (void) unbindViews {
    [self.prevButton unbind:@"enabled"];
    [self.nextButton unbind:@"enabled"];
    [self.playButton unbind:@"image"];
    
    [self.volumeSlider unbind:@"value"];
    
    [self.songPositionSlider unbind:@"maxValue"];
    [self.songPositionSlider unbind:@"doubleValue"];
    
    [self.timeElapsedField unbind:@"value"];
    [self.timeRemainingField unbind:@"value"];
    
    [self.currentSongInfoField unbind:@"value"];
}









- (IBAction) trackPositionMovedTo:(id)sender {
    [[SDMusicPlayer sharedPlayer] seekToTime:[self.songPositionSlider doubleValue]];
}

@end
