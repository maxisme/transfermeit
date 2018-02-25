//
//  PopUpView.h
//  Transfer Me It
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PopUpWindow : NSObject
@property NSString* filePath;

@property NSWindow* window;
@property NSTextField *label;
@property NSTextField *labelShaddow;
@property NSTextField *inputCode;
@property NSTextField* errorMessage;

@end
