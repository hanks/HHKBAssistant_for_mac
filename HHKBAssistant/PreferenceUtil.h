//
//  PreferenceUtil.h
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/05.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreferencePaneWindowController.h"

#define PREFERENCE_NAME @"preferences"

#define DEVICES_KEY @"target_devices"
#define IS_VOICE_MESSAGE_ALL_KEY @"is_voice_message_all_key"
#define IS_VOICE_MESSAGE_IN_KEY @"is_voice_message_in_key"
#define IS_VOICE_MESSAGE_OUT_KEY @"is_voice_message_out_key"
#define IN_MESSAGE_KEY @"in_message"
#define OUT_MESSAGE_KEY @"out_message"
#define IS_AUTO_DISABLE_KEY @"is_auto_disable"

@interface PreferenceUtil : NSObject <DataSourceDelegate>

@property NSMutableDictionary* plistDic;
@property NSString *plistPath;

- (id)read:(NSString *)key;
- (void)write;
+ (id)getSharedInstance;
- (void)update;

@end
