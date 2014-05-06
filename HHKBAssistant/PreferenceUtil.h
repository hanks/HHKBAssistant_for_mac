//
//  PreferenceUtil.h
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/05.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreferencePaneWindowController.h"
#import "Constants.h"

@interface PreferenceUtil : NSObject <DataSourceDelegate>

@property NSMutableDictionary* plistDic;
@property NSString *plistPath;

- (id)read:(NSString *)key;
- (void)write;
+ (id)getSharedInstance;
- (void)update;

@end
