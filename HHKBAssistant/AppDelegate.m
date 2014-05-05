//
//  AppDelegate.m
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/04.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import "AppDelegate.h"
#import <IOKit/kext/KextManager.h>
#import <ServiceManagement/ServiceManagement.h>
#import "PreferenceUtil.h"



#define BUILD_IN_KEYBOARD_ENABLE 1
#define BUILD_IN_KEYBOARD_DISABLE 0

@implementation AppDelegate

@synthesize usbManager;
@synthesize statusMenu;
@synthesize prefPaneWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
//    self.kbKextIdentifier = @"com.apple.driver.AppleUSBTCKeyboard";
//    NSDictionary *kexts = (__bridge NSDictionary *)KextManagerCopyLoadedKextInfo((__bridge CFArrayRef)[NSArray arrayWithObject: self.kbKextIdentifier], NULL);
//    
//    
//    for (id key in kexts) {
//        NSLog(@"%@: %@", key, kexts[key]);
//    }
    
    // set up listener in background the thread
    [NSThread detachNewThreadSelector:@selector(setupListener) toTarget:usbManager withObject:nil];
}

- (AuthorizationRef) authenticateForKbKext {
    // get authorization
    AuthorizationRef myAuthorizationRef;
    OSStatus myStatus;
    myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,
                                   kAuthorizationFlagDefaults, &myAuthorizationRef);
    // ask for just one auth
    AuthorizationItem myItems[1];
    
    // kext auth
    myItems[0].name = [self.kbKextIdentifier UTF8String];
    myItems[0].valueLength = 0;
    myItems[0].value = NULL;
    myItems[0].flags = 0;
    
    AuthorizationRights myRights;
    myRights.count = sizeof (myItems) / sizeof (myItems[0]);
    myRights.items = myItems;
    
    AuthorizationFlags myFlags;
    myFlags = kAuthorizationFlagDefaults |
    kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagExtendRights;
    
    myStatus = AuthorizationCopyRights(myAuthorizationRef, &myRights,
                                       kAuthorizationEmptyEnvironment, myFlags, NULL);
    return myAuthorizationRef;
}

- (void) freeAuthRef: (AuthorizationRef)authRef {
    // free authrization
    AuthorizationFree (authRef,
                       kAuthorizationFlagDestroyRights);
    
}

- (void)awakeFromNib {
    // add status icon to system menu bar
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    
    // set status bar icon
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"icon_16x16" ofType:@"png"];
    NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    [statusItem setImage:icon];
    [statusItem setToolTip:@"USB Keyboard Helpler"];
    [statusItem setHighlightMode:YES];
    
    // init keyboard change menu title
    self.kbStatus = BUILD_IN_KEYBOARD_DISABLE;
    [self setKbChangeMenuTitle:self.kbStatus];
    
    // init usb device manager
    usbManager = [[USBDeviceManager alloc] init];
    // get preference util
    PreferenceUtil *prefUtil = [PreferenceUtil getSharedInstance];
    // update device array
    [usbManager updateDeviceArr:[prefUtil getDeviceArr]];
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
            
            break;
        case BUILD_IN_KEYBOARD_DISABLE:
            // disable build in keyboard
            
            break;
    }
    
    [self setKbChangeMenuTitle:kbStatus];
}

- (IBAction)openPreferencePane:(id)sender {
    prefPaneWindowController = [[PreferencePaneWindowController alloc] initWithWindowNibName:XIBNAME];
    [prefPaneWindowController showWindow:prefPaneWindowController.myWindow];
    // set focus to new window
    NSApplication *myApp = [NSApplication sharedApplication];
    [myApp activateIgnoringOtherApps:YES];
    [prefPaneWindowController.myWindow orderFrontRegardless];
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
@end

