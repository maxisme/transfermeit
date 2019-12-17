//
//  UserNotification.m
//  Transfer Me It
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import "DesktopNotification.h"
#import "CustomFunctions.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation DesktopNotification

# pragma mark - send notifications
+(void)send:(NSString*)title message:(NSString*)message{
    [self send:title message:message activate:@"" close:@"" variables:nil];
}

+(void)send:(NSString*)title message:(NSString*)message activate:(NSString*)button1 close:(NSString*)button2{
    [self send:title message:message activate:button1 close:button2 variables:nil];
}

+(void)send:(NSString*)title message:(NSString*)message activate:(NSString*)button1 close:(NSString*)button2 variables:(NSDictionary*)variables{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.userInfo = variables;
    notification.informativeText = message;
    
    if(button1.length > 0){
        notification.actionButtonTitle = button1;
    }else{
        [notification setHasActionButton:NO];
    }
    
    if(button2.length > 0){
        notification.otherButtonTitle = button2;
    }else{
        [notification setHasReplyButton:NO];
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    // to allow notifications even when app is at front
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
    
}

#pragma mark - handle notifications
+ (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

+ (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification{
    DDLogDebug(@"activated notification");
    NSString* filePath = notification.userInfo[@"file_path"];
    
    if([notification.title isEqual: @"File Too Big!"]){
        [CustomFunctions goPro];
    }else if(filePath){
        NSArray *fileURLs = [NSArray arrayWithObjects:[NSURL fileURLWithPath:filePath], nil];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
    }
}

@end
