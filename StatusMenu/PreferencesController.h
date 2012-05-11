//
//  PreferencesController.h
//  StatusMenu
//
//  Created by Cyrus Stoller on 5/10/12.
//  Copyright 2012 Cyrus Stoller. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController{
    IBOutlet NSView *general_prefs_view;
    IBOutlet NSView *account_prefs_view;
    
    IBOutlet NSToolbar *toolbar;
    
    int currentViewTag;
}
    
- (IBAction)switchView:(id)sender;

@end
