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
    [myWindow close];
}

- (IBAction)save:(id)sender {
    // get info from controls and save to plist file
    NSInteger flag;
    
    flag = [autoDisableCheckbox state];
    [delegate setAutoDisable:flag];
    
    flag = [enableVoiceCheckbox state];
    [delegate setEnableVoice:flag];

    flag = [inMsgCheckbox state];
    [delegate setInMsgEnable:flag];

    flag = [outMsgCheckbox state];
    [delegate setOutMsgEnable:flag];

    
    NSString *text;
    
    text = [inMsgTextField stringValue];
    [delegate setInMsg:text];
    
    text = [outMsgTextField stringValue];
    [delegate setOutMsg:text];
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
    [autoDisableCheckbox setState:[delegate isAutoDisable]];
    [enableVoiceCheckbox setState:[delegate isEnableVoice]];
    [inMsgCheckbox setState:[delegate isInMsgEnable]];
    [outMsgCheckbox setState:[delegate isOutMsgEnable]];
    [inMsgTextField setStringValue:[delegate getInMsg]];
    [outMsgTextField setStringValue:[delegate getOutMsg]];
}

@end
