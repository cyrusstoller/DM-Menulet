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
#import "GrowlNotifiers.h"
#import "PreferenceKeys.h"

@implementation StatusMenuAppDelegate

@synthesize window, lastEventId, pathModificationDates, appStartedTimestamp;

#pragma mark -
#pragma mark life cycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _userDefaults = [NSUserDefaults standardUserDefaults];
    // Insert code here to initialize your application
    NSDictionary *appDefaults = [NSDictionary
                                 dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"CacheDataAgressively"];
    [_userDefaults registerDefaults:appDefaults];
    
    // registering growl
    [GrowlApplicationBridge setGrowlDelegate:self];

    
    // For registering for fsevents
    fm = [NSFileManager defaultManager];
    self.lastEventId = (NSNumber *)[_userDefaults objectForKey:LAST_EVENT_ID_KEY];
    pathModificationDates = [[_userDefaults dictionaryForKey:PATH_MODIFICATION_DATES_KEY] mutableCopy];    
    // NSLog(@"%lld",[lastEventId unsignedLongLongValue]);
    [self initializeEventStream];
}

- (void)awakeFromNib{
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:statusMenu];
    
    //    To add an image instead of words
    //    [statusItem setImage:<#(NSImage *)#>];
    [statusItem setTitle:@"Data Mustard"];
    [statusItem setHighlightMode:YES];
}

- (NSApplicationTerminateReply)applicationShouldTerminate: (NSApplication *)app
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:lastEventId forKey:LAST_EVENT_ID_KEY];
    [defaults synchronize];
    FSEventStreamStop(stream);
    FSEventStreamInvalidate(stream);
    return NSTerminateNow;
}

#pragma mark -
#pragma mark Menu Actions

- (IBAction)openDataMustard:(NSMenuItem *)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.datamustard.com/"]];
}

- (IBAction)openDataMustardFolder:(NSMenuItem *)sender{
    [[NSWorkspace sharedWorkspace] openFile:[NSHomeDirectory() stringByAppendingPathComponent:@"DataMustard"]];
}

- (IBAction)openPreferences:(id)sender{
    if (!_preferencesController) {
        _preferencesController = [[PreferencesController alloc] init];
    }    
    
    //    To get this to work properly I had to set LSUIElement to True in the plist
    
    [NSApp activateIgnoringOtherApps:YES];
    [_preferencesController.window makeKeyAndOrderFront:self];
    [_preferencesController showWindow:self];    
}

- (IBAction)openAbout:(id)sender{
    if (!_aboutController) {
        _aboutController = [[AboutController alloc] init];
    }
    [NSApp activateIgnoringOtherApps:YES];
    [_aboutController.window makeKeyAndOrderFront:self];
    [_aboutController showWindow:self];
}

- (IBAction)quit:(id)sender{
    [NSApp terminate:nil];
}


#pragma mark -
#pragma mark Growl

- (NSDictionary *) registrationDictionaryForGrowl {
	NSDictionary *notificationsWithDescriptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   NotifierNewFileHumanReadableDescription, NotifierNewFileNotification,
                                                   NotifierModifiedFileHumanReadableDescription, NotifierModifiedFileNotificaiton,
												   nil];
	
	NSArray *allNotifications = [notificationsWithDescriptions allKeys];
	
	//Don't turn the sync notiifications on by default; they're noisy and not all that interesting.
	NSMutableArray *defaultNotifications = [allNotifications mutableCopy];
	[defaultNotifications removeObject:NotifierModifiedFileNotificaiton];
	
	NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"Data Mustard Status Bar", GROWL_APP_NAME,
							 allNotifications, GROWL_NOTIFICATIONS_ALL,
							 defaultNotifications,	GROWL_NOTIFICATIONS_DEFAULT,
							 notificationsWithDescriptions,	GROWL_NOTIFICATIONS_HUMAN_READABLE_NAMES,
							 nil];
	
	[defaultNotifications release];
	
	return regDict;
}


- (NSString *) applicationNameForGrowl{
    return @"Data Mustard Status Bar";
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


- (void) sendGrowl:(id)sender{
    [GrowlApplicationBridge notifyWithTitle:@"wow" 
             description:@"blah" 
        notificationName:NotifierNewFileNotification 
                iconData:[NSData data] 
                priority:0 
                isSticky:NO 
            clickContext:@"" 
           /* identifier:@"" */]; // make it show multiple growls
}

#pragma mark -
#pragma mark FSEvents

- (void) initializeEventStream
{
    NSArray *pathsToWatch = [NSArray arrayWithObject:[_userDefaults stringForKey:SPECIAL_DIRECTORY_KEY]];
    void *appPointer = (void *)self;
    FSEventStreamContext context = {0, appPointer, NULL, NULL, NULL};
    NSTimeInterval latency = 1.0;
    stream = FSEventStreamCreate(NULL,
                                 &fsevents_callback,
                                 &context,
                                 (CFArrayRef) pathsToWatch,
                                 [lastEventId unsignedLongLongValue],
                                 (CFAbsoluteTime) latency,
                                 kFSEventStreamCreateFlagUseCFTypes
                                 );
    
    FSEventStreamScheduleWithRunLoop(stream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
}

void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[])
{
    StatusMenuAppDelegate *appDelegate = (StatusMenuAppDelegate *)userData;
    size_t i;
    for(i=0; i < numEvents; i++){
        [appDelegate updateLastEventId:(unsigned long long) eventIds[i]];
        [appDelegate addModifiedFilesAtPath:[(NSArray *)eventPaths objectAtIndex:i]];
    }
}

- (void) updateLastEventId:(unsigned long long)lastId{
    self.lastEventId = [NSNumber numberWithUnsignedLongLong:lastId];
//    NSLog(@"%lld --- %lld", [lastEventId unsignedLongLongValue], lastId);    
}

- (void)updateLastModificationDateForPath: (NSString *)path
{
    if (!pathModificationDates) {
        pathModificationDates = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSDate date], path, nil];
    }else{
        [pathModificationDates setObject:[NSDate date] forKey:path];
    }
}

- (NSDate *)lastModificationDateForPath: (NSString *)path
{
	if(nil != [pathModificationDates valueForKey:path]) {
		return [pathModificationDates valueForKey:path];
	}
	else{
		return appStartedTimestamp;
	}
}

- (void) addModifiedFilesAtPath: (NSString *)path;
{
    NSArray *contents = [fm contentsOfDirectoryAtPath:path error:nil];
    NSString *fullPath = nil;
    BOOL addedFile = false;
    
    for(NSString* node in contents) {
        fullPath = [NSString stringWithFormat:@"%@/%@",path,node];
        if ([self fileIsValid:fullPath])
        {
            NSDictionary *fileAttributes = [fm attributesOfItemAtPath:fullPath error:NULL];
            NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
            if([fileModDate compare:[self lastModificationDateForPath:path]] == NSOrderedDescending) 
            {
                NSLog(@"%@", fullPath);
                addedFile = true;
            }
        }
    }
    
    if (addedFile) {
        // Send growl notification
        [self sendGrowl:nil];
    }
    
    [self updateLastModificationDateForPath:path];
}

- (BOOL) fileIsValid: (NSString *) path{
//    NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
//    return [sharedWorkspace type:[sharedWorkspace typeOfFile:path error:NULL] 
//                  conformsToType:@"public.image"];
    return YES;
}

- (void) resetFSEvents{
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStop(stream);
    FSEventStreamInvalidate(stream);
    [self initializeEventStream];
}

@end