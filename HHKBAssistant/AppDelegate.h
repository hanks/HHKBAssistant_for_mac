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
#import "XPCManager.h"
#import "Constants.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    NSStatusItem * statusItem;
}

@property (assign) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *kbChangeMenu;
@property BOOL kbStatus;

@property PreferencePaneWindowController *prefPaneWindowController;
@property USBDeviceManager *usbManager;
@property XPCManager *xpcManager;

@end
