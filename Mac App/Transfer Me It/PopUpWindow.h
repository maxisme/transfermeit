//
//  PopUpView.h
//  Transfer Me It
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SubmitButton;
@class MenuBar;
@class Keys;
@class Button;
@class BorderTextField;
@class KeyWindow;

@interface PopUpWindow : NSObject
@property NSString* viewName;

@property NSString* filePath;

@property KeyWindow* inputWindow;

@property (readonly) int windowWidth;
@property (readonly) int windowHeight;

@property NSTextField *label;
@property BorderTextField *inputCode;
@property SubmitButton* subButton;
@property NSTextField* errorMessage;
@property NSImageView *up_arrow;
@property Button *file_button;

@property Keys* keychain;
@property NSString* uuid;

-(void)inputError:(NSString*)message;
-(void)flyAway;

-(void)closeInputWindow;

-(void)setSendToFriendView:(NSRect)statusBarFrame filePath:(NSString*)filePath;
-(void)setEnterPermCodeView:(NSRect)statusBarFrame;
-(void)setEnterRegistrationKeyView:(NSRect)statusBarFrame;
-(void)downloadView:(NSRect)statusBarFrame downloadInfo:(NSString*)downloadInfo;

-(void)togglePermenantUser;
@end
