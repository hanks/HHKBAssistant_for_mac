//
//  XPCManager.h
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/06.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface XPCManager : NSObject

@property xpc_connection_t connection;
@property char* bundleID;

- (void)sendRequest:(char *)request;
+ (id)getSharedInstance;

@end
