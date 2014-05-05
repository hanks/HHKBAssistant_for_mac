//
//  USBDeviceManager.m
//  HHKBAssistant
//
//  Created by 周 涵 on 2014/05/05.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import "USBDeviceManager.h"

@implementation USBDeviceManager

@synthesize privateDataRef;
@synthesize gNotifyPort;
@synthesize gAddedIter;
@synthesize gRunLoop;
@synthesize targetDeviceArr;


//////////////////////////////////////////////////
// wrapper object-c method to c callback function
//////////////////////////////////////////////////
static void DeviceNotification(void *refCon, io_service_t service, natural_t messageType, void *messageArgument) {
    [(__bridge USBDeviceManager *)refCon addDeviceNotification:service messageType:messageType messageArgument:messageArgument];
}

static void DeviceAdded(void *refCon, io_iterator_t iterator) {
    [(__bridge USBDeviceManager *)refCon detectDeviceAdded:iterator];
}

static void SignalHandler(int sigraised) {
    NSLog(@"\nInterrupted.\n");
    exit(0);
}
//////////////////////////////////////////////////
// wrapper end
//////////////////////////////////////////////////

- (void) addDeviceNotification:(io_service_t)service messageType:(natural_t)messageType messageArgument:(void *)messageArgument {
    kern_return_t	kr;
    
    if (messageType == kIOMessageServiceIsTerminated) {
        NSLog(@"Device removed.\n");
        
        // Dump our private data to stderr just to see what it looks like.
        NSLog(@"privateDataRef->deviceName: ");
		CFShow(privateDataRef->deviceName);
		NSLog(@"privateDataRef->locationID: %u.\n\n", privateDataRef->locationID);
        
        // Free the data we're no longer using now that the device is going away
        CFRelease(privateDataRef->deviceName);
        
        if (privateDataRef->deviceInterface) {
            kr = (*privateDataRef->deviceInterface)->Release(privateDataRef->deviceInterface);
        }
        
        kr = IOObjectRelease(privateDataRef->notification);
        
        free(privateDataRef);
    }

}

- (void) detectDeviceAdded:(io_iterator_t) iterator {
    kern_return_t		kr;
    io_service_t		usbDevice;
    IOCFPlugInInterface	**plugInInterface = NULL;
    SInt32				score;
    HRESULT 			res;
    
    while ((usbDevice = IOIteratorNext(iterator))) {
        io_name_t		deviceName;
        CFStringRef		deviceNameAsCFString;
        privateDataRef = NULL;
        UInt32			locationID;
        
        // Add some app-specific information about this device.
        // Create a buffer to hold the data.
        privateDataRef = malloc(sizeof(MyPrivateData));
        bzero(privateDataRef, sizeof(MyPrivateData));
        
        // Get the USB device's name.
        kr = IORegistryEntryGetName(usbDevice, deviceName);
		if (KERN_SUCCESS != kr) {
            deviceName[0] = '\0';
        }
        
        deviceNameAsCFString = CFStringCreateWithCString(kCFAllocatorDefault, deviceName,
                                                         kCFStringEncodingASCII);
        
        // compare device name to target device
        for (int i = 0; i < [targetDeviceArr count]; i++) {
            NSString *targetDeviceName = [targetDeviceArr objectAtIndex:i];
            if (strcmp(deviceName, [targetDeviceName UTF8String]) == 0) {
                // if hit, do action
                
                // voice
                system("say HHKB Professional is ready");
                
                // Save the device's name to our private data.
                privateDataRef->deviceName = deviceNameAsCFString;
                
                // Now, get the locationID of this device. In order to do this, we need to create an IOUSBDeviceInterface
                // for our device. This will create the necessary connections between our userland application and the
                // kernel object for the USB Device.
                kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
                                                       &plugInInterface, &score);
                
                if ((kIOReturnSuccess != kr) || !plugInInterface) {
                    NSLog(@"IOCreatePlugInInterfaceForService returned 0x%08x.\n", kr);
                    continue;
                }
                
                // Use the plugin interface to retrieve the device interface.
                res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
                                                         (LPVOID*) &privateDataRef->deviceInterface);
                
                // Now done with the plugin interface.
                (*plugInInterface)->Release(plugInInterface);
                
                if (res || privateDataRef->deviceInterface == NULL) {
                    NSLog(@"QueryInterface returned %d.\n", (int) res);
                    continue;
                }
                
                // Now that we have the IOUSBDeviceInterface, we can call the routines in IOUSBLib.h.
                // In this case, fetch the locationID. The locationID uniquely identifies the device
                // and will remain the same, even across reboots, so long as the bus topology doesn't change.
                
                kr = (*privateDataRef->deviceInterface)->GetLocationID(privateDataRef->deviceInterface, &locationID);
                if (KERN_SUCCESS != kr) {
                    NSLog(@"GetLocationID returned 0x%08x.\n", kr);
                    continue;
                }
                else {
                    NSLog(@"Location ID: %u\n\n", locationID);
                }
                
                privateDataRef->locationID = locationID;
                
                // Register for an interest notification of this device being removed. Use a reference to our
                // private data as the refCon which will be passed to the notification callback.
                kr = IOServiceAddInterestNotification(gNotifyPort,						// notifyPort
                                                      usbDevice,						// service
                                                      kIOGeneralInterest,				// interestType
                                                      DeviceNotification,				// callback
                                                      (__bridge void *)self,					// refCon
                                                      &(privateDataRef->notification)	// notification
                                                      );
                
                if (KERN_SUCCESS != kr) {
                    NSLog(@"IOServiceAddInterestNotification returned 0x%08x.\n", kr);
                }

            }
        }
        
        // Done with this USB device; release the reference added by IOIteratorNext
        kr = IOObjectRelease(usbDevice);
    }

}

- (int) setupListener {
    CFMutableDictionaryRef 	matchingDict;
    CFRunLoopSourceRef		runLoopSource;
    kern_return_t			kr;
    sig_t					oldHandler;
    
    // Set up a signal handler so we can clean up when we're interrupted from the command line
    // Otherwise we stay in our run loop forever.
    oldHandler = signal(SIGINT, SignalHandler);
    if (oldHandler == SIG_ERR) {
        NSLog(@"Could not establish new signal handler.");
	}
    

    matchingDict = IOServiceMatching(kIOUSBDeviceClassName);	// Interested in instances of class
    // IOUSBDevice and its subclasses
    if (matchingDict == NULL) {
        NSLog(@"IOServiceMatching returned NULL.\n");
        return -1;
    }
    
    // Create a notification port and add its run loop event source to our run loop
    // This is how async notifications get set up.
    gNotifyPort = IONotificationPortCreate(kIOMasterPortDefault);
    runLoopSource = IONotificationPortGetRunLoopSource(gNotifyPort);
    
    gRunLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(gRunLoop, runLoopSource, kCFRunLoopDefaultMode);
    
    // Now set up a notification to be called when a device is first matched by I/O Kit.
    kr = IOServiceAddMatchingNotification(gNotifyPort,					// notifyPort
                                          kIOFirstMatchNotification,	// notificationType
                                          matchingDict,					// matching
                                          DeviceAdded,			        // callback
                                          (__bridge void *)self,		// refCon
                                          &gAddedIter					// notification
                                          );
    
    // Iterate once to get already-present devices and arm the notification
    [self detectDeviceAdded:gAddedIter];
    
    // Start the run loop. Now we'll receive notifications.
    NSLog(@"Starting run loop.\n\n");
    CFRunLoopRun();
    
    // We should never get here
    NSLog(@"Unexpectedly back from CFRunLoopRun()!\n");
    // 1: error status
    // 0: ok status
    return 1;
}

- (void) updateDeviceArr:(NSMutableArray *)newArr {
    targetDeviceArr = newArr;
}

@end
