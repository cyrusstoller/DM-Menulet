//
//  PreferencesController.h
//  StatusMenu
//
//  Created by Cyrus Stoller on 5/10/12.
//  Copyright 2012 Cyrus Stoller. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController<NSTextFieldDelegate>{
    IBOutlet NSView *general_prefs_view;
    IBOutlet NSView *account_prefs_view;
    
    IBOutlet NSToolbar *toolbar;
    IBOutlet NSTextField *username;
    IBOutlet NSSecureTextField *password;
    
    IBOutlet NSMenuItem *special_directory;
    
    int currentViewTag;
}
    
@property (nonatomic, retain) IBOutlet NSMenuItem *special_directory;

- (IBAction)switchView:(id)sender;

- (IBAction)selectFile:(id)sender;

- (IBAction)openSignUp:(id)sender;

@end
