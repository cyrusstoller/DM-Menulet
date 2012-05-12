//
//  PreferencesController.m
//  StatusMenu
//
//  Created by Cyrus Stoller on 5/10/12.
//  Copyright 2012 Cyrus Stoller. All rights reserved.
//

#import "PreferencesController.h"

#define USERNAME_KEY @"user_username_key"
#define PASSWORD_KEY @"user_password_key"

@implementation PreferencesController

- (id)init
{
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        // Initialization code here.
        
//        NSLog(@"defaults\n");
//        NSLog(@"user: %@", [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME_KEY]);
//        NSLog(@"pass: %@", [[NSUserDefaults standardUserDefaults] stringForKey:PASSWORD_KEY]);
        
    }
    
    return self;
}

-(void)textDidEndEditing:(NSNotification *)notification { 
//    if ([notification object] == username) {
//        NSLog(@"user : %@", [username stringValue]);
//    }else{
//        NSLog(@"pass : %@", [password stringValue]);
//    }    

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[username stringValue] forKey:USERNAME_KEY];
    [defaults setObject:[password stringValue] forKey:PASSWORD_KEY];
    
    [defaults synchronize];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSString *username_text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] 
                                                                stringForKey:USERNAME_KEY]];
    NSString *password_text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] 
                                                                stringForKey:PASSWORD_KEY]];
    [username setStringValue:username_text];
    [password setStringValue:password_text];
    
    [username setDelegate:self];
    [password setDelegate:self];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(textDidEndEditing:)
               name: NSControlTextDidChangeNotification
             object:username];
    [nc addObserver:self
           selector:@selector(textDidEndEditing:)
               name: NSControlTextDidChangeNotification
             object:password];
}


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
    int tag = (int) [sender tag];
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
