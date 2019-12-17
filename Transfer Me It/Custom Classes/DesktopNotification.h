//
//  UserNotification.h
//  Transfer Me It
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DesktopNotification : NSObject
@property (nonatomic, copy) void (^onAction)(NSUserNotification*);
@property (nonatomic, copy) void (^onCancel)(NSUserNotification*);

+(void)send:(NSString*)title message:(NSString*)message;
+(void)send:(NSString*)title message:(NSString*)message activate:(NSString*)button1 close:(NSString*)button2;
+(void)send:(NSString*)title message:(NSString*)message activate:(NSString*)button1 close:(NSString*)button2 variables:(NSDictionary*)variables;
@end
