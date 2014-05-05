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
@synthesize plistPath;

- (NSMutableDictionary *)load {
    return [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
}

- (void)update {
    plistDic = [self load];
}

- (NSObject *)read:(NSString *)key {
    return [plistDic objectForKey:key];
}

- (void)write {
    [plistDic writeToFile:plistPath atomically:YES];
}

#pragma mark delegate Methods
- (void) addDevice:(NSString *)deviceName {
    NSMutableArray *arr = [self getDeviceArr];
    [arr addObject:deviceName];
    [plistDic setObject:arr forKey:DEVICES_KEY];
    [self write];
}

- (void) removeDevice:(NSString *)deviceName {
    NSMutableArray *arr = [self getDeviceArr];
    [arr removeObject:deviceName];
    [plistDic setObject:arr forKey:DEVICES_KEY];
    [self write];
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
        // init path
        plistPath = [[NSBundle mainBundle] pathForResource:PREFERENCE_NAME ofType:@"plist"];
        
        // init
        [self update];
    }
    return self;
}

@end
