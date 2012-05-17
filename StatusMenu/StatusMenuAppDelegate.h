//
//  StatusMenuAppDelegate.h
//  StatusMenu
//
//  Created by Cyrus Stoller on 5/10/12.
//  Copyright 2012 Cyrus Stoller. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <growl/growl.h>
#import <CoreServices/CoreServices.h>

@class PreferencesController;
@class AboutController;

@interface StatusMenuAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate> {
    NSWindow *window;
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    PreferencesController *_preferencesController;
    AboutController *_aboutController;
    NSUserDefaults *_userDefaults;
    
    // For registering for fsevents
    NSFileManager* fm;
    NSNumber* lastEventId;
    FSEventStreamRef stream;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)openDataMustard:(id)sender;
-(IBAction)openDataMustardFolder:(id)sender;

-(IBAction)openPreferences:(id)sender;
-(IBAction)openAbout:(id)sender;
-(IBAction)quit:(id)sender;

// Growl Interface
-(void)sendGrowl:(id)sender;

// For registering fsevents
- (void) initializeEventStream;
void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[]);
- (void) updateLastEventId:(FSEventStreamEventId)lastId;
//- (void) addModifiedImagesAtPath: (NSString *)path;
- (void) resetFSEvents;


@end
