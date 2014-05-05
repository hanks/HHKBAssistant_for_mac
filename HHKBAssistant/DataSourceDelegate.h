//
//  DataSourceDelegate.h
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/06.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Foundation/Foundation.h>

// define data source operation deleaget
@protocol DataSourceDelegate <NSObject>

- (void) addDevice:(NSString *)deviceName;
- (void) removeDevice:(NSString *)deviceName;

- (NSMutableArray*) getDeviceArr;

- (NSInteger) isAutoDisable;
- (void) setAutoDisable:(NSInteger)flag;

- (NSInteger) isEnableVoice;
- (void) setEnableVoice:(NSInteger)flag;

- (NSInteger) isInMsgEnable;
- (void) setInMsgEnable:(NSInteger)flag;

- (NSInteger) isOutMsgEnable;
- (void) setOutMsgEnable:(NSInteger)flag;

- (NSString *) getInMsg;
- (void) setInMsg:(NSString *)msg;

- (NSString *) getOutMsg;
- (void) setOutMsg:(NSString *)msg;

@end
