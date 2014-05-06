//
//  main.c
//  DisableKeyboardHelper
//
//  Created by 周 涵 on 2014/05/06.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#include <syslog.h>
#include <xpc/xpc.h>
#include <IOKit/kext/KextManager.h>
#import "../HHKBAssistant/Constants.h"

static void __XPC_Peer_Event_Handler(xpc_connection_t connection, xpc_object_t event) {
    syslog(LOG_NOTICE, "Received event in helper.");
    
	xpc_type_t type = xpc_get_type(event);
    
	if (type == XPC_TYPE_ERROR) {
		if (event == XPC_ERROR_CONNECTION_INVALID) {
			// The client process on the other end of the connection has either
			// crashed or cancelled the connection. After receiving this error,
			// the connection is in an invalid state, and you do not need to
			// call xpc_connection_cancel(). Just tear down any associated state
			// here.
            
		} else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
			// Handle per-connection termination cleanup.
		}
        
	} else {
        const char *request = xpc_dictionary_get_string(event, REQUEST_KEY);
        if (request != NULL) {
            // handle request
            syslog(LOG_NOTICE, request);
            
            OSReturn ret;
            
            if (strcmp(request, DISABLE_KEYBOARD_REQUEST) == 0) {
                // disable build in keyboard
                ret = KextManagerUnloadKextWithIdentifier(CFSTR(BUILD_IN_KEYBOARD_KEXT_ID));
            } else if (strcmp(request, ENABLE_KEYBOARD_REQUEST) == 0) {
                // enable build in keyboard
                CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, NULL, 0, NULL);
                ret = KextManagerLoadKextWithIdentifier(CFSTR(BUILD_IN_KEYBOARD_KEXT_ID), array);
                CFRelease(array);
            }
            
            xpc_connection_t remote = xpc_dictionary_get_remote_connection(event);
            xpc_object_t reply = xpc_dictionary_create_reply(event);
            
            char msg[50] = "";
            strcat(msg, request);
            if (ret == kOSReturnSuccess) {
                strcat(msg, " is done!");
            } else {
                strcat(msg, " is error!");
            }
            
            // create reply message and send back to main app
            xpc_dictionary_set_string(reply, RESPONSE_KEY, msg);
            xpc_connection_send_message(remote, reply);
            
            xpc_release(reply);
        }
    }
}


static void __XPC_Connection_Handler(xpc_connection_t connection)  {
    syslog(LOG_NOTICE, "Configuring message event handler for helper.");
    
	xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
		__XPC_Peer_Event_Handler(connection, event);
	});
	
	xpc_connection_resume(connection);
}

int main(int argc, const char * argv[]) {
    xpc_connection_t service = xpc_connection_create_mach_service(kHelperBundleID,
                                                                  dispatch_get_main_queue(),
                                                                  XPC_CONNECTION_MACH_SERVICE_LISTENER);
    
    if (!service) {
        syslog(LOG_NOTICE, "Failed to create service.");
        exit(EXIT_FAILURE);
    }
    
    syslog(LOG_NOTICE, "Configuring connection event handler for helper");
    xpc_connection_set_event_handler(service, ^(xpc_object_t connection) {
        __XPC_Connection_Handler(connection);
    });
    
    xpc_connection_resume(service);
    
    dispatch_main();
    
    xpc_release(service);
    
    return EXIT_SUCCESS;
}

