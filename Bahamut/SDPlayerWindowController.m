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




#define SDWindowTitleBackgroundColor [NSColor colorWithCalibratedWhite:0.87 alpha:1.0]
#define SDWindowBackgroundColor [NSColor colorWithCalibratedWhite:0.94 alpha:1.0]
#define SDWindowInsideBordersColor [NSColor colorWithCalibratedWhite:0.70 alpha:1.0]

#define SDUnfocusedAmount (.40)



//- (void) viewDidMoveToWindow {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeKeyWindow:) name:NSWindowDidBecomeKeyNotification object:[self window]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResignKeyWindow:) name:NSWindowDidResignKeyNotification object:[self window]];
//}
//
//- (void) didBecomeKeyWindow:(NSNotification*)note {
//    self.isFocused = YES;
//    [self setNeedsDisplay:YES];
//}
//
//- (void) didResignKeyWindow:(NSNotification*)note {
//    self.isFocused = NO;
//    [self setNeedsDisplay:YES];
//}
//
//- (void) dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}




static void sd_swizzle(Class kls, NSString* selName, IMP imp) {
    SEL sel = NSSelectorFromString(selName);
    Method meth = class_getInstanceMethod(kls, sel);
    const char* enc = method_getTypeEncoding(meth);
    class_addMethod(kls, sel, imp, enc);
}







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

@property (weak) IBOutlet NSView* realContentView;
@property (weak) IBOutlet NSView* realTitleView;

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
    
    [[self window] setBackgroundColor:SDWindowTitleBackgroundColor];
    [[self window] setTitle:@"Bahamut"];
    
    [self punchAppleInTheFace];
    
    NSRect realContentViewFrame = [[[self window] contentView] bounds];
    realContentViewFrame.size.height -= 11.0;
    [self.realContentView setFrame:realContentViewFrame];
    [[[[self window] contentView] superview] addSubview:self.realTitleView];
    
    NSRect titleViewFrame = [self.realTitleView frame];
    titleViewFrame.origin.y += 22.0;
    [self.realTitleView setFrame:titleViewFrame];
    
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

- (void) punchAppleInTheFace {
    [[self.window standardWindowButton:NSWindowCloseButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    
    NSView* themeView = [self.window.contentView superview];
    NSString* className = [@"SD" stringByAppendingString: [themeView className]];
    Class c = NSClassFromString(className);
    if (c == nil) {
        c = objc_allocateClassPair([themeView class], [className UTF8String], 0);
        sd_swizzle(c, @"class", imp_implementationWithBlock(^{ return NSClassFromString(@"NSThemeFrame"); }));
        sd_swizzle(c, @"className", imp_implementationWithBlock(^{ return @"NSThemeFrame"; }));
        sd_swizzle(c, @"_titlebarTitleRect", imp_implementationWithBlock(^{ return NSZeroRect; }));
        objc_registerClassPair(c);
    }
    object_setClass(themeView, c);
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
