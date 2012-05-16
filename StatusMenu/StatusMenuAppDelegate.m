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

#define NotifierUSBConnectionNotification				@"USB Device Connected"
#define NotifierUSBDisconnectionNotification			@"USB Device Disconnected"
#define NotifierVolumeMountedNotification				@"Volume Mounted"
#define NotifierVolumeUnmountedNotification				@"Volume Unmounted"
#define NotifierBluetoothConnectionNotification			@"Bluetooth Device Connected"
#define NotifierBluetoothDisconnectionNotification		@"Bluetooth Device Disconnected"
#define NotifierFireWireConnectionNotification			@"FireWire Device Connected"
#define NotifierFireWireDisconnectionNotification		@"FireWire Device Disconnected"
#define NotifierNetworkLinkUpNotification				@"Network Link Up"
#define NotifierNetworkLinkDownNotification				@"Network Link Down"
#define NotifierNetworkIpAcquiredNotification			@"IP Acquired"
#define NotifierNetworkIpReleasedNotification			@"IP Released"
#define NotifierNetworkAirportConnectNotification		@"AirPort Connected"
#define NotifierNetworkAirportDisconnectNotification	@"AirPort Disconnected"
#define NotifierSyncStartedNotification					@"Sync started"
#define NotifierSyncFinishedNotification				@"Sync finished"
#define NotifierPowerOnACNotification					@"Switched to A/C Power"
#define NotifierPowerOnBatteryNotification				@"Switched to Battery Power"
#define NotifierPowerOnUPSNotification					@"Switched to UPS Power"

#define NotifierUSBConnectionHumanReadableDescription				NSLocalizedString(@"USB Device Connected", "")
#define NotifierUSBDisconnectionHumanReadableDescription			NSLocalizedString(@"USB Device Disconnected", "")
#define NotifierVolumeMountedHumanReadableDescription				NSLocalizedString(@"Volume Mounted", "")
#define NotifierVolumeUnmountedHumanReadableDescription				NSLocalizedString(@"Volume Unmounted", "")
#define NotifierBluetoothConnectionHumanReadableDescription			NSLocalizedString(@"Bluetooth Device Connected", "")
#define NotifierBluetoothDisconnectionHumanReadableDescription		NSLocalizedString(@"Bluetooth Device Disconnected", "")
#define NotifierFireWireConnectionHumanReadableDescription			NSLocalizedString(@"FireWire Device Connected", "")
#define NotifierFireWireDisconnectionHumanReadableDescription		NSLocalizedString(@"FireWire Device Disconnected", "")
#define NotifierNetworkLinkUpHumanReadableDescription				NSLocalizedString(@"Network Link Up", "")
#define NotifierNetworkLinkDownHumanReadableDescription				NSLocalizedString(@"Network Link Down", "")
#define NotifierNetworkIpAcquiredHumanReadableDescription			NSLocalizedString(@"IP Acquired", "")
#define NotifierNetworkIpReleasedHumanReadableDescription			NSLocalizedString(@"IP Released", "")
#define NotifierNetworkAirportConnectHumanReadableDescription		NSLocalizedString(@"AirPort Connected", "")
#define NotifierNetworkAirportDisconnectHumanReadableDescription	NSLocalizedString(@"AirPort Disconnected", "")
#define NotifierSyncStartedHumanReadableDescription					NSLocalizedString(@"Sync started", "")
#define NotifierSyncFinishedHumanReadableDescription				NSLocalizedString(@"Sync finished", "")
#define NotifierPowerOnACHumanReadableDescription					NSLocalizedString(@"Switched to A/C Power", "")
#define NotifierPowerOnBatteryHumanReadableDescription				NSLocalizedString(@"Switched to Battery Power", "")
#define NotifierPowerOnUPSHumanReadableDescription					NSLocalizedString(@"Switched to UPS Power", "")

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

- (NSDictionary *) registrationDictionaryForGrowl {
	NSDictionary *notificationsWithDescriptions = [NSDictionary dictionaryWithObjectsAndKeys:
												   NotifierUSBConnectionHumanReadableDescription, NotifierUSBConnectionNotification,			
												   NotifierUSBDisconnectionHumanReadableDescription, NotifierUSBDisconnectionNotification,		
												   NotifierVolumeMountedHumanReadableDescription, NotifierVolumeMountedNotification,			
												   NotifierVolumeUnmountedHumanReadableDescription, NotifierVolumeUnmountedNotification,			
												   NotifierBluetoothConnectionHumanReadableDescription, NotifierBluetoothConnectionNotification,		
												   NotifierBluetoothDisconnectionHumanReadableDescription, NotifierBluetoothDisconnectionNotification,	
												   NotifierFireWireConnectionHumanReadableDescription, NotifierFireWireConnectionNotification,		
												   NotifierFireWireDisconnectionHumanReadableDescription, NotifierFireWireDisconnectionNotification,	
												   NotifierNetworkLinkUpHumanReadableDescription, NotifierNetworkLinkUpNotification,			
												   NotifierNetworkLinkDownHumanReadableDescription, NotifierNetworkLinkDownNotification,			
												   NotifierNetworkIpAcquiredHumanReadableDescription, NotifierNetworkIpAcquiredNotification,		
												   NotifierNetworkIpReleasedHumanReadableDescription, NotifierNetworkIpReleasedNotification,		
												   NotifierNetworkAirportConnectHumanReadableDescription, NotifierNetworkAirportConnectNotification,	
												   NotifierNetworkAirportDisconnectHumanReadableDescription, NotifierNetworkAirportDisconnectNotification,
												   NotifierSyncStartedHumanReadableDescription, NotifierSyncStartedNotification,				
												   NotifierSyncFinishedHumanReadableDescription, NotifierSyncFinishedNotification,			
												   NotifierPowerOnACHumanReadableDescription, NotifierPowerOnACNotification,				
												   NotifierPowerOnBatteryHumanReadableDescription, NotifierPowerOnBatteryNotification,			
												   NotifierPowerOnUPSHumanReadableDescription, NotifierPowerOnUPSNotification,				
												   nil];
	
	NSArray *allNotifications = [notificationsWithDescriptions allKeys];
	
	//Don't turn the sync notiifications on by default; they're noisy and not all that interesting.
	NSMutableArray *defaultNotifications = [allNotifications mutableCopy];
	[defaultNotifications removeObject:NotifierSyncStartedNotification];
	[defaultNotifications removeObject:NotifierSyncFinishedNotification];
	
	NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"MultiGrowlExample", GROWL_APP_NAME,
							 allNotifications, GROWL_NOTIFICATIONS_ALL,
							 defaultNotifications,	GROWL_NOTIFICATIONS_DEFAULT,
							 notificationsWithDescriptions,	GROWL_NOTIFICATIONS_HUMAN_READABLE_NAMES,
							 nil];
	
	[defaultNotifications release];
	
	return regDict;
}


- (NSString *) applicationNameForGrowl{
    return @"MultiGrowlExample";
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


- (IBAction)sendGrowl:(id)sender{
    Class GAB = NSClassFromString(@"GrowlApplicationBridge");
    [GAB setGrowlDelegate:self];
    [GAB notifyWithTitle:@"wow" description:@"blah" notificationName:@"USB Device Connected" iconData:[NSData data] priority:0 isSticky:NO clickContext:nil identifier:@"cyro"];
    NSLog(@"here");
}

@end