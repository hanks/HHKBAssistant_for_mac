//
//  USBDeviceManager.h
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/05.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>

typedef struct MyPrivateData {
    io_object_t				notification;
    IOUSBDeviceInterface	**deviceInterface;
    CFStringRef				deviceName;
    UInt32					locationID;
} MyPrivateData;

@interface USBDeviceManager : NSObject {

}

// structure for usb device info
@property MyPrivateData* privateDataRef;

@property IONotificationPortRef	gNotifyPort;
@property io_iterator_t			gAddedIter;
@property CFRunLoopRef			gRunLoop;

- (void) addDeviceNotification:(io_service_t)service messageType:(natural_t)messageType messageArgument:(void *)messageArgument;
- (void) detectDeviceAdded:(io_iterator_t) iterator;
- (int) setupListener;

@end
