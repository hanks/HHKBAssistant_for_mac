//
//  PreferenceUtil.h
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/05.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PREFERENCE_NAME @"preferences.plist"

@interface PreferenceUtil : NSObject

@property NSMutableDictionary* plistDic;

- (NSObject *)read:(NSString *)key;
- (void)write:(NSString *)key value:(NSObject *)value;
+ (id)getSharedInstance;
- (void)update;

@end
