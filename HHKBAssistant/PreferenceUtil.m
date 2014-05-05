//
//  PreferenceUtil.m
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/05.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import "PreferenceUtil.h"

@implementation PreferenceUtil

@synthesize plistDic;

- (NSMutableDictionary *)load {
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:PREFERENCE_NAME ofType:@"plist"];
    return [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
}

- (void)update {
    plistDic = [self load];
}

- (NSObject *)read:(NSString *)key {
    return [plistDic objectForKey:key];
}

- (void)write:(NSString *)key value:(NSObject *)value {
    
}

#pragma mark delegate Methods
- (void) addDevice:(NSString *)deviceName {
    
}

- (void) removeDevice:(NSString *)deviceName {
    
}

- (NSMutableArray*) getDeviceArr {
    [self update];
    return (NSMutableArray*)[self read:DEVICES_KEY];
}

#pragma mark Singleton Methods
+ (id)getSharedInstance {
    static PreferenceUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
    });
    return sharedUtil;
}

- (id)init {
    if (self = [super init]) {
        // init
        [self update];
    }
    return self;
}

@end
