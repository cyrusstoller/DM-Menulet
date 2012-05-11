//
//  PreferencesController.m
//  StatusMenu
//
//  Created by Cyrus Stoller on 5/10/12.
//  Copyright 2012 Cyrus Stoller. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

- (id)init
{
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//- (void)windowDidLoad
//{
//    [super windowDidLoad];
//    
//    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
//}


- (NSRect)newFrameForNewContentView:(NSView *) view{

    NSWindow *window = [self window];
    NSRect newFrameRect = [window frameRectForContentRect:[view frame]];
    NSRect oldFrameRect = [window frame];
    NSSize newSize = newFrameRect.size;
    NSSize oldSize = oldFrameRect.size;
    
    NSRect frame = [window frame];
    frame.size = newSize;
    frame.origin.y -= (newSize.height - oldSize.height);
    
    return frame;
}

- (NSView *)viewForTag:(int) tag {
    NSView *view = nil;
    switch (tag) {
        case 0:
            view = general_prefs_view;
            break;
        case 1:
            view = account_prefs_view;
            break;
        default:
            view = general_prefs_view;
            break;
    }
    return view;
}

- (BOOL) validateToolbarItem:(NSToolbarItem *)item{
    if ([item tag] == currentViewTag) return NO;
    else return YES;
}

- (void) awakeFromNib{
    [[self window] setContentSize:[general_prefs_view frame].size];
    [[[self window] contentView] addSubview:general_prefs_view];
    [[[self window] contentView] setWantsLayer:YES];
    [toolbar setSelectedItemIdentifier:@"General"];
    
}

- (IBAction)switchView:(id)sender{
    int tag = [sender tag];
    NSView *view = [self viewForTag:tag];
    NSView *previousView = [self viewForTag:currentViewTag];
    currentViewTag = tag;
    
    NSRect newFrame = [self newFrameForNewContentView:view];
    
    
    [NSAnimationContext beginGrouping];
    
    if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) 
        [[NSAnimationContext currentContext] setDuration:1.0];
    
    [[[[self window] contentView] animator] replaceSubview:previousView with:view];
    [[[self window] animator] setFrame:newFrame display:YES];
    
    [NSAnimationContext endGrouping];
}

@end
