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

@interface PopUpWindow : NSObject
@property NSString* viewName;

@property NSString* filePath;

@property NSWindow* window;
@property NSView* view;

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

-(void)closeWindow;

-(void)inputError:(NSString*)message;
-(void)animatePlane;

-(void)setSendToFriendView:(NSRect)statusBarFrame filePath:(NSString*)filePath;
-(void)setEnterPermCodeView:(NSRect)statusBarFrame;
-(void)setEnterRegistrationKeyView:(NSRect)statusBarFrame;
-(void)downloadView:(NSRect)statusBarFrame downloadInfo:(NSString*)downloadInfo;

-(void)togglePermenantUser;
@end
