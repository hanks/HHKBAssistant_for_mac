HHKB Assistant for mac
===========================

A funny helper tool for HHKB professional keyboard on mac. Its main job is that it can auto detect the HHKB professional keyboard plugged in and out, and do some actions you want. For example, disable mac build-in keyboard.

## Why
I bought HHKB Professional keyboard last week, and I often use it like this:  
  
![alt text][scenario]  
  
The reason is simple, everytime I need to execute some magic shell commands to disable mac build-in keyboard before I put HHKB on macbook, or else HHKB will press keys in build-in keyboard to interrupt you work. And then do the command again when I plugged out HHKB to enable build-in keyboard.   

So this app is to help me do the repetitive job, and **I also add one funny feature to make a voice message when HHKB is in and out.** You can download and try it.

[scenario]:
https://raw.githubusercontent.com/hanks/HHKBAssistant_for_mac/master/Demo/work_scenario.jpg "scenario"

## Demo
Here I use **console output** to demo it.  Message is simple, use a forever loop to detect HHKB plugged in and out, and do the disable/enable build-in keyboard action at the same time.   

You maybe notice message [**disable build-in keyboard is error**], because I use **unload keyboard driver** to do the disable action, and you will **always get a error message** when you want to unload build-in keyboard driver dynamically, but it still works.
  
![alt text][demo]

[demo]: 
https://raw.githubusercontent.com/hanks/HHKBAssistant_for_mac/master/Demo/demo.gif "demo"

##Usage
[menu]: 
https://raw.githubusercontent.com/hanks/HHKBAssistant_for_mac/master/Demo/menu.jpg "menu"
[preference]: 
https://raw.githubusercontent.com/hanks/HHKBAssistant_for_mac/master/Demo/preference.png "preference"

**HHKBAssistant** is also just a status bar app like <a href='https://github.com/hanks/MuteIt_for_mac'>**MuteIt**</a>, just an icon in the system menu bar.   

![alt text][menu]  
※The first menu is to let you can **disable/enable keyboard anytime manually.** 

I also provide a **Preference** window to create your personal settings.  
![alt text][preference]  

You can input your favorite messages into text fields to speak when HHKB is in and out. **The device name will be always spoken, when your check this voice message feature on.**

##Implementation  
I use command:  
>sudo kextunload                                                                                               /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext  

>sudo kextload  /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext

to disable/enable mac build-in keyboard manually. It seems to unload/load driver for build-in keyboard and works fine.   

**So how to do it in the code.** In my opinion, I needed to do three tasks.  
1. detect usb device  
2. unload/load the driver   
3. run sudo command  

The first task, you can reference <a href='https://developer.apple.com/library/mac/samplecode/USBPrivateDataSample/Listings/USBPrivateDataSample_c.html#//apple_ref/doc/uid/DTS10000456-USBPrivateDataSample_c-DontLinkElementID_4'>USB Device Detect</a>  and use some **multi-thread** implementations.
  
The second task is simple, just use <a href='https://developer.apple.com/library/mac/documentation/IOKit/Reference/KextManager_header_reference/Reference/reference.html'>KextManager</a> API will do me favor.

The third one, is a little complicated. I found Apple documents say when you want to run **sudo** authentication task, with the security consideration, you should use something like:  
1. <a href='http://launchd.info/'>launchd</a>  
2. <a href='https://developer.apple.com/library/mac/samplecode/SMJobBless/Introduction/Intro.html'>SMJobBless</a>    
3. <a href='http://atnan.com/blog/2012/02/29/modern-privileged-helper-tools-using-smjobbless-plus-xpc'>XPC service</a>  
4. wrap obj-c code to c static function  
5. codesign  
6. etc...  

to abstract the high rights task to a sub helper tool run as a launchd process, and use XPC service to communication between main application and this helper tool.  

**When finish the main three tasks, the whole thing is almost done.**  

## Install
Download app from <a href='https://raw.githubusercontent.com/hanks/HHKBAssistant_for_mac/master/Installer/HHKB Assistant Installer.dmg'>here</a>, and install like other mac apps.

The installer UI will be like this:  
![alt text][installer]  

※It will ask you to input **root password** to install the helper tool. Because disable keyboard needs **sudo authentication**.  
[installer]: 
https://raw.githubusercontent.com/hanks/HHKBAssistant_for_mac/master/Demo/installer.png "installer"
  
## Uninstall
I also create a simple <a href='https://raw.githubusercontent.com/hanks/HHKBAssistant_for_mac/master/Installer/Uninstall.sh'>uninstall script here</a>, just contains three lines of sudo rm commands, you can check it and use it to remove all the related files.

## Bugs
1. Now I **can not** find a correct way to detect build-in keyboard is disabled or not, because I want to use detect keyboard driver is loaded or not, but the driver is always loaded whether keyboard is disabled or not..., **the first menu item will not be displayed correctly.**

## Contribution
**Waiting for your pull requests**

## Lisence
MIT Lisence
