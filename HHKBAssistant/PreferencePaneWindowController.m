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

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)_init {
    // use preference info from plist to init window control

}

@end
