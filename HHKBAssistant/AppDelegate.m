//
//  AppDelegate.m
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/04.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>
#import "PreferenceUtil.h"

@implementation AppDelegate

@synthesize usbManager;
@synthesize statusMenu;
@synthesize prefPaneWindowController;
@synthesize xpcManager;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // set up listener in background the thread
    [NSThread detachNewThreadSelector:@selector(setupListener) toTarget:usbManager withObject:nil];
    
    // register helper tool
    [self addHelper];
}

- (void)awakeFromNib {
    // add status icon to system menu bar
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    
    // set status bar icon
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"icon_16x16" ofType:@"png"];
    NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    [statusItem setImage:icon];
    [statusItem setToolTip:APP_TOOLTIP];
    [statusItem setHighlightMode:YES];
    
    // init keyboard change menu title
    self.kbStatus = BUILD_IN_KEYBOARD_DISABLE;
    [self setKbChangeMenuTitle:self.kbStatus];
    
    // init XPC manager, should before usb manager
    xpcManager = [XPCManager getSharedInstance];
    
    // get preference util
    PreferenceUtil *prefUtil = [PreferenceUtil getSharedInstance];

    // init usb device manager
    usbManager = [[USBDeviceManager alloc] init];
    // update delegate
    usbManager.delegate = prefUtil;
    
    // init preference window controller
    // create window and init
    prefPaneWindowController = [[PreferencePaneWindowController alloc] initWithXibAndDelegate:XIBNAME delegate:prefUtil];
}

- (void)setKbChangeMenuTitle:(BOOL)kbStatus {
    switch (kbStatus) {
        case BUILD_IN_KEYBOARD_DISABLE:
            [self.kbChangeMenu setTitle:@"Enable Build-in Keyboard"];
            break;
        case BUILD_IN_KEYBOARD_ENABLE:
            [self.kbChangeMenu setTitle:@"Disable Build-in Keyboard"];
            break;
    }
}

- (void)changeKeyboardWith:(BOOL)kbStatus {
    switch (kbStatus) {
        case BUILD_IN_KEYBOARD_ENABLE:
            // enable build in keyboard
            [xpcManager sendRequest:ENABLE_KEYBOARD_REQUEST];
            break;
        case BUILD_IN_KEYBOARD_DISABLE:
            // disable build in keyboard
            [xpcManager sendRequest:DISABLE_KEYBOARD_REQUEST];
            break;
    }
    
    [self setKbChangeMenuTitle:kbStatus];
}

- (IBAction)openPreferencePane:(id)sender {
    // show window
    [prefPaneWindowController showWindow:prefPaneWindowController.myWindow];
    
    // set focus to new window
    NSApplication *myApp = [NSApplication sharedApplication];
    [myApp activateIgnoringOtherApps:YES];
    [prefPaneWindowController.myWindow makeKeyAndOrderFront:nil];
}

- (IBAction)changeKeyboardMode:(id)sender {
    self.kbStatus = !self.kbStatus;
    [self changeKeyboardWith:self.kbStatus];
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)runOnStartup:(id)sender {
    [sender setState:![sender state]];
    
    if ([sender state]) {
        // if true to add app to login item lists
        [self addAppAsLoginItem];
    } else {
        // delete from login item lists
        [self deleteAppFromLoginItem];
    }
}

-(void) addAppAsLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

-(void) deleteAppFromLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		for(int i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                                         objectAtIndex:i]);
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

////////////////////////////////////////////
////// Disable keyboard helper util method
////////////////////////////////////////////
#pragma mark Helper Util Method
- (void)addHelper {
    // copy helper execute binary file to /Library/PrivilegedHelperTools
    // copy helper launchd settings plist file to /Library/LaunchDaemons
    NSDictionary *helperInfo = (__bridge NSDictionary*)SMJobCopyDictionary(kSMDomainSystemLaunchd,
                                                                           CFSTR(kHelperBundleID));
    if (!helperInfo)
    {
        AuthorizationItem authItem = { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
        AuthorizationRights authRights = { 1, &authItem };
        AuthorizationFlags flags = kAuthorizationFlagDefaults|
        kAuthorizationFlagInteractionAllowed|
        kAuthorizationFlagPreAuthorize|
        kAuthorizationFlagExtendRights;
        
        AuthorizationRef authRef = NULL;
        OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
        if (status != errAuthorizationSuccess)
        {
            NSLog(@"Failed to create AuthorizationRef, return code %i", status);
        } else
        {
            CFErrorRef error = NULL;
            BOOL result = SMJobBless(kSMDomainSystemLaunchd, CFSTR(kHelperBundleID), authRef, &error);
            if (!result)
            {
                NSLog(@"SMJobBless Failed, error : %@",error);
            } else {
                NSLog(@"SMJobBless is done");
            }
        }
    } else {
        NSLog(@"already registered!!");
    }
}

- (void)removeHelper {
    NSDictionary *helperInfo = (__bridge NSDictionary*)SMJobCopyDictionary(kSMDomainSystemLaunchd,
                                                                           CFSTR(kHelperBundleID));
    if (helperInfo)
    {
        AuthorizationItem authItem = { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
        AuthorizationRights authRights = { 1, &authItem };
        AuthorizationFlags flags = kAuthorizationFlagDefaults|
        kAuthorizationFlagInteractionAllowed|
        kAuthorizationFlagPreAuthorize|
        kAuthorizationFlagExtendRights;
        
        AuthorizationRef authRef = NULL;
        OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
        if (status != errAuthorizationSuccess)
        {
            NSLog(@"Failed to create AuthorizationRef, return code %i", status);
        } else
        {
            CFErrorRef error = NULL;
            BOOL result = SMJobRemove(kSMDomainSystemLaunchd, CFSTR(kHelperBundleID), authRef, YES, &error);
            if (!result)
            {
                NSLog(@"SMJobBless Failed, error : %@",error);
            } else {
                NSLog(@"remove successfully!!");
            }
        }
    }
}
@end

