//
//  User.h
//  Transfer Me It
//
//  Created by Maximilian Mitchell on 13/02/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MenuBar;
@class Socket;
@class PopUpWindow;
@class Keys;

@interface User : NSObject
//helpers
@property bool createFailed;

//classes
@property (strong, nonatomic) MenuBar* menuBar;
@property (strong, nonatomic) Socket* socket;
@property (strong, nonatomic) PopUpWindow* window;
@property (strong, nonatomic) Keys* keychain;

//properties
@property NSString* code;
@property unsigned long long maxFileUpload;
@property unsigned long long bandwidthLeft;
@property int maxTime;
@property int tier;
@property (readonly) NSString* uuid;
@property NSDate *endTime;

-(id)initWithMenuBar:(MenuBar*)mb;
-(void)create;
@end
