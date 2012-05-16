//
//  StatusMenuAppDelegate.m
//  StatusMenu
//
//  Created by Cyrus Stoller on 5/10/12.
//  Copyright 2012 Cyrus Stoller. All rights reserved.
//

#import "StatusMenuAppDelegate.h"
#import "PreferencesController.h"
#import "AboutController.h"

@implementation StatusMenuAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _userDefaults = [NSUserDefaults standardUserDefaults];
    // Insert code here to initialize your application
    NSDictionary *appDefaults = [NSDictionary
                                 dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"CacheDataAgressively"];
    [_userDefaults registerDefaults:appDefaults];
    
    
    // registering with Growl
    NSBundle *mainBundle = [NSBundle mainBundle];

    NSString *path = [[mainBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
	NSLog(@"path: %@", path);
	NSBundle *growlFramework = [NSBundle bundleWithPath:path];
	if([growlFramework load])
	{
		NSDictionary *infoDictionary = [growlFramework infoDictionary];
		NSLog(@"Using Growl.framework %@ (%@)",
			  [infoDictionary objectForKey:@"CFBundleShortVersionString"],
			  [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey]);
        
		Class GAB = NSClassFromString(@"GrowlApplicationBridge");
		if([GAB respondsToSelector:@selector(setGrowlDelegate:)]){
            [GAB performSelector:@selector(setGrowlDelegate:) withObject:self];
        }
	}

    
}

-(void)awakeFromNib{
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:statusMenu];
    
    //    To add an image instead of words
    //    [statusItem setImage:<#(NSImage *)#>];
    [statusItem setTitle:@"Data Mustard"];
    [statusItem setHighlightMode:YES];
}

-(IBAction)openDataMustard:(NSMenuItem *)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.datamustard.com/"]];
}

-(IBAction)openDataMustardFolder:(NSMenuItem *)sender{
    [[NSWorkspace sharedWorkspace] openFile:[NSHomeDirectory() stringByAppendingPathComponent:@"DataMustard"]];
}

-(IBAction)openPreferences:(id)sender{
    if (!_preferencesController) {
        _preferencesController = [[PreferencesController alloc] init];
    }    
    
    //    To get this to work properly I had to set LSUIElement to True in the plist
    
    [NSApp activateIgnoringOtherApps:YES];
    [_preferencesController.window makeKeyAndOrderFront:self];
    [_preferencesController showWindow:self];    
}

-(IBAction)openAbout:(id)sender{
    if (!_aboutController) {
        _aboutController = [[AboutController alloc] init];
    }
    [NSApp activateIgnoringOtherApps:YES];
    [_aboutController.window makeKeyAndOrderFront:self];
    [_aboutController showWindow:self];
}

-(IBAction)quit:(id)sender{
    [NSApp terminate:nil];
}


#pragma mark -
#pragma mark Growl

//-(NSDictionary *) registrationDictionaryForGrowl{
//
//}


- (NSString *) applicationNameForGrowl{
    return @"Data Mustard";
}

//- (NSData *) applicationIconDataForGrowl{
//    
//}


- (void) growlNotificationWasClicked:(id)clickContext{
    NSLog(@"Notification was clicked");
}

//- (void) growlNotificationTimedOut:(id)clickContext{
//    
//}

// Posting a notification to growl
//+[GrowlApplicationBridge
//  notifyWithTitle:(NSString *)title
//  description:(NSString *)description
//  notificationName:(NSString *)notificationName
//  iconData:(NSData *)iconData
//  priority:(signed int)priority
//  isSticky:(BOOL)isSticky
//  clickContext:(id)clickContext]

@end