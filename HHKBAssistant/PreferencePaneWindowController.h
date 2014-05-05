//
//  PreferencePaneWindowController.h
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/05.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataSourceDelegate.h"

#define XIBNAME @"prefpane"

@interface PreferencePaneWindowController : NSWindowController

@property (strong) IBOutlet NSWindow *myWindow;

// delegate for plist data source
@property (nonatomic, assign) id<DataSourceDelegate>  delegate;

////////////
/// Controls
////////////
@property (weak) IBOutlet NSButton *autoDisableCheckbox;
@property (weak) IBOutlet NSButton *enableVoiceCheckbox;
@property (weak) IBOutlet NSButton *inMsgCheckbox;
@property (weak) IBOutlet NSButton *outMsgCheckbox;
@property (weak) IBOutlet NSTextField *inMsgTextField;
@property (weak) IBOutlet NSTextField *outMsgTextField;

- (id)initWithXibAndDelegate:(NSString *)windowNibName delegate:(id<DataSourceDelegate>)newDelegate;

@end
