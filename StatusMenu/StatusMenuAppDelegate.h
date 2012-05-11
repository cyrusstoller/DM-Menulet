//
//  StatusMenuAppDelegate.h
//  StatusMenu
//
//  Created by Cyrus Stoller on 5/10/12.
//  Copyright 2012 Cyrus Stoller. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PreferencesController;

@interface StatusMenuAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    PreferencesController *_preferencesController;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)openDataMustard:(id)sender;
-(IBAction)openDataMustardFolder:(id)sender;

-(IBAction)openPreferences:(id)sender;
-(IBAction)quit:(id)sender;

@end
