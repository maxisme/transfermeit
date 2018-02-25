//
//  menuBar.h
//  Transfer Me It
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PopUpWindow;
@class User;

@interface MenuBar : NSView <NSMenuDelegate>

@property (nonatomic, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) PopUpWindow* w;
@property (nonatomic, strong) User* user;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;

@property NSString* menuName;

@property NSMenuItem *itemOne;
@property NSMenuItem *itemTwo;
@property NSMenuItem *itemThree;
@property NSMenuItem *itemFour;
@property NSMenuItem *itemFive;
@property NSMenuItem *itemSix;

@property NSMenuItem *seperator1;
@property NSMenuItem *seperator2;
@property NSMenuItem *seperator3;
@property NSMenuItem *seperator4;
@property NSMenuItem *seperator5;

@property NSMenuItem* accountType;
@property NSMenuItem* timeints;
@property NSMenuItem* permUserItem;

@property NSTimer* animationTimer;
@property int lastAnimateCnt;

-(void)setDefaultMenu:(NSString*)userCode bandwidthLeft:(unsigned long long)bandwidthLeft maxFileUpload:(unsigned long long)maxFileUpload maxTime:(int)maxTime wantedTime:(int)wantedTime userTier:(int)userTier timeLeft:(NSDate*)timeLeft;
-(void)setDMenu;

-(void)setTurnOffDND:(bool)DNDIson;
-(void)setErrorMenu:(NSString*)message;
-(void)setRequestingCodeMenu;
-(void)setMenuTime:(NSDate*)time;

- (id)initWithStatusItem:(NSStatusItem *)statusItem window:(PopUpWindow*)w;

-(void)setUploadMenu:(NSString*)fileName;
-(void)setdownloadMenu:(NSString*)fileName;
-(void)setProgressInfo:(NSString*)message;
@end
