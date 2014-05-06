//
//  AppDelegate.h
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/04.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "USBDeviceManager.h"
#import "PreferencePaneWindowController.h"

#define BUILD_IN_KEYBOARD_ENABLE 1
#define BUILD_IN_KEYBOARD_DISABLE 0
#define kHelperBundleID @"DisableKeyboardHelper"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem * statusItem;
}

@property (assign) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *kbChangeMenu;
@property BOOL kbStatus;

@property (strong) PreferencePaneWindowController *prefPaneWindowController;
@property USBDeviceManager *usbManager;

@end
