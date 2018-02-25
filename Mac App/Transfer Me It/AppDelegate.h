//
//  AppDelegate.h
//  Transfer Me It
//
//  Created by Max Mitchell on 10/02/2017.
//  Copyright © 2017 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MenuBar;
@class PopUpWindow;

@interface AppDelegate : NSObject <NSApplicationDelegate , NSUserNotificationCenterDelegate>
@property MenuBar* mb;
@property PopUpWindow* w;
@end
