//
//  StatusMenuAppDelegate.h
//  StatusMenu
//
//  Created by Cyrus Stoller on 5/10/12.
//  Copyright 2012 Cyrus Stoller. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PreferencesController;
@class AboutController;

@interface StatusMenuAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    PreferencesController *_preferencesController;
    AboutController *_aboutController;
    NSUserDefaults *_userDefaults;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)openDataMustard:(id)sender;
-(IBAction)openDataMustardFolder:(id)sender;

-(IBAction)openPreferences:(id)sender;
-(IBAction)openAbout:(id)sender;
-(IBAction)quit:(id)sender;

@end
