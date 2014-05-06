//
//  XPCManager.h
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/06.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#define ENABLE_KEYBOARD_REQUEST "enable build in keyboard"
#define DISABLE_KEYBOARD_REQUEST "disable build in keyboard"

#define REQUEST_KEY "request"
#define RESPONSE_KEY "reply"

@interface XPCManager : NSObject

@property xpc_connection_t connection;
@property NSString* bundleID;

- (void)sendRequest:(NSString *)request;

@end
