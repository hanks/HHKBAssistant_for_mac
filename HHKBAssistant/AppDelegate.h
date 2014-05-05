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

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem * statusItem;
    AuthorizationRef myAuthRef;
}

@property (strong) PreferencePaneWindowController *prefPaneWindowController;
@property (assign) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *kbChangeMenu;
@property BOOL kbStatus;
@property NSString *kbKextIdentifier;
@property USBDeviceManager *usbManager;

@end
