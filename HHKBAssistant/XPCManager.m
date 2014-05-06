//
//  XPCManager.m
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/06.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import "XPCManager.h"

@implementation XPCManager

@synthesize connection;
@synthesize bundleID;

- (void)sendRequest:(char *)request {
    // wake up connection
    xpc_connection_resume(connection);
    
    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_string(message, REQUEST_KEY, request);
    
    NSLog(@"%@", [NSString stringWithFormat:@"Sending request: %s", request]);
    
    xpc_connection_send_message_with_reply(connection, message, dispatch_get_main_queue(), ^(xpc_object_t event) {
        const char* response = xpc_dictionary_get_string(event, RESPONSE_KEY);
        NSLog(@"%@", [NSString stringWithFormat:@"Received response: %s.", response]);
    });
}

- (void)initConnection {
    connection = xpc_connection_create_mach_service(kHelperBundleID, NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
    
    if (!connection) {
        NSLog(@"%@", @"Failed to create XPC connection.");
        return;
    }
    
    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        xpc_type_t type = xpc_get_type(event);
        
        if (type == XPC_TYPE_ERROR) {
            
            if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
                NSLog(@"%@", @"XPC connection interupted.");
                
            } else if (event == XPC_ERROR_CONNECTION_INVALID) {
                NSLog(@"%@", @"XPC connection invalid, releasing.");
            } else {
                NSLog(@"%@", @"Unexpected XPC connection error.");
            }
        } else {
            NSLog(@"%@", @"Unexpected XPC connection event.");
        }
    });

}

#pragma mark Singleton Methods
+ (id)getSharedInstance {
    static XPCManager *xpcManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xpcManager = [[self alloc] initWithBundleID:kHelperBundleID];
    });
    return xpcManager;
}

- (id)initWithBundleID:(char *)_bundleID {
    if (self = [super init]) {
        self.bundleID = _bundleID;
        
        // init connection
        [self initConnection];
    }
    return self;
}

@end
