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
    [self initControl];
    [self initEventListener];
}

- (id)initWithXibAndDelegate:(NSString *)windowNibName delegate:(id<DataSourceDelegate>)newDelegate {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.delegate = newDelegate;
    }
    return self;
}

- (void)initControl {
    // use preference info from plist to init window control
    [autoDisableCheckbox setState:[delegate isAutoDisable]];
    [enableVoiceCheckbox setState:[delegate isEnableVoice]];
    [inMsgCheckbox setState:[delegate isInMsgEnable]];
    [outMsgCheckbox setState:[delegate isOutMsgEnable]];
    [inMsgTextField setStringValue:[delegate getInMsg]];
    [outMsgTextField setStringValue:[delegate getOutMsg]];
    
    // init UI with state
    [self changeWithInMsgState:[inMsgCheckbox state]];
    [self changeWithOutMsgState:[outMsgCheckbox state]];
    [self changeWithEnableVoiceState:[enableVoiceCheckbox state]];
}

//////////////////////////////////////////////////////////////
/// init check evnet listener to checkbox
//////////////////////////////////////////////////////////////
- (void)initEventListener {
    [enableVoiceCheckbox setTarget:self];
    [enableVoiceCheckbox setAction:@selector(enableVoiceStateListener:)];
    
    [inMsgCheckbox setTarget:self];
    [inMsgCheckbox setAction:@selector(inMsgStateListener:)];
    
    [outMsgCheckbox setTarget:self];
    [outMsgCheckbox setAction:@selector(outMsgStateListener:)];
}

- (void)enableVoiceStateListener:(id)sender {
    NSButton *checkbox = (NSButton *)sender;
    NSInteger state = [checkbox state];
    
    [self changeWithEnableVoiceState:state];
}

- (void)inMsgStateListener:(id)sender {
    NSButton *checkbox = (NSButton *)sender;
    NSInteger state = [checkbox state];
    
    [self changeWithInMsgState:state];
}

- (void)outMsgStateListener:(id)sender {
    NSButton *checkbox = (NSButton *)sender;
    NSInteger state = [checkbox state];
    
    [self changeWithOutMsgState:state];
}

//////////////////////////////////////////////////////////////
/// change availability between voice message checkbox state
//////////////////////////////////////////////////////////////
- (void)changeWithEnableVoiceState:(NSInteger)state {
    
    if (state == NSOffState) {
        // when it is unchecked. let its subitems unable
        [inMsgCheckbox setEnabled:NO];
        [outMsgCheckbox setEnabled:NO];
        [inMsgTextField setEnabled:NO];
        [outMsgTextField setEnabled:NO];
    } else {
        [inMsgCheckbox setEnabled:YES];
        [outMsgCheckbox setEnabled:YES];
        
        
        [self changeWithInMsgState:[inMsgCheckbox state]];
        [self changeWithOutMsgState:[outMsgCheckbox state]];
    }
}

- (void)changeWithInMsgState:(NSInteger)state {
    if (state == NSOffState) {
        // when it is unchecked. let its subitems unable
        [inMsgTextField setEnabled:NO];
    } else {
        [inMsgTextField setEnabled:YES];
    }
}

- (void)changeWithOutMsgState:(NSInteger)state {
    if (state == NSOffState) {
        // when it is unchecked. let its subitems unable
        [outMsgTextField setEnabled:NO];
    } else {
        [outMsgTextField setEnabled:YES];
    }
}

@end
