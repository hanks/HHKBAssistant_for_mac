//
//  PreferenceUtil.h
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/05.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "USBDeviceManager.h"

#define PREFERENCE_NAME @"preferences"
#define DEVICES_KEY @"target_devices"

@interface PreferenceUtil : NSObject <DataSourceDelegate>

@property NSMutableDictionary* plistDic;

- (NSObject *)read:(NSString *)key;
- (void)write:(NSString *)key value:(NSObject *)value;
+ (id)getSharedInstance;
- (void)update;

@end
