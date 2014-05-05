//
//  PreferencePaneWindowController.m
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/05.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import "PreferencePaneWindowController.h"

@interface PreferencePaneWindowController ()

@end

@implementation PreferencePaneWindowController

@synthesize delegate;
@synthesize myWindow;

@synthesize autoDisableCheckbox;
@synthesize enableVoiceCheckbox;
@synthesize inMsgCheckbox;
@synthesize outMsgCheckbox;
@synthesize inMsgTextField;
@synthesize outMsgTextField;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)canel:(id)sender {
    NSLog(@"cacel");
    [myWindow close];
}

- (IBAction)save:(id)sender {
    NSLog(@"save");
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self _initControl];
}

- (id)initWithXibAndDelegate:(NSString *)windowNibName delegate:(id<DataSourceDelegate>)newDelegate {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.delegate = newDelegate;
    }
    return self;
}

- (void)_initControl {
    // use preference info from plist to init window control
    NSLog(@"%zd", [delegate isAutoDisable]);
    NSLog(@"%zd", [delegate isEnableVoice]);
    NSLog(@"%zd", [delegate isInMsgEnable]);
    NSLog(@"%zd", [delegate isOutMsgEnable]);
    NSLog(@"%@", [delegate getInMsg]);
    NSLog(@"%@", [delegate getOutMsg]);
    [autoDisableCheckbox setState:[delegate isAutoDisable]];
    [enableVoiceCheckbox setState:[delegate isEnableVoice]];
    [inMsgCheckbox setState:[delegate isInMsgEnable]];
    [outMsgCheckbox setState:[delegate isOutMsgEnable]];
    [inMsgTextField setStringValue:[delegate getInMsg]];
    [outMsgTextField setStringValue:[delegate getOutMsg]];
}

@end
