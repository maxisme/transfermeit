//
//  AppDelegate.h
//  Transfer Me It
//
//  Created by Max Mitchell on 10/02/2017.
//  Copyright © 2017 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <STHTTPRequest/STHTTPRequest.h>
#import <SocketRocket/SRWebSocket.h>
#import <SocketRocket/SocketRocket.h>
#import <Sparkle/Sparkle.h>
#import <RNCryptor_objc/RNDecryptor.h>
#import <RNCryptor_objc/RNEncryptor.h>
#import <SAMKeychain/SAMKeychain.h>
#import <GZIP/GZIP.h>

#define LOG_LEVEL_DEF ddLogLevel
@import CocoaLumberjack;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSURLConnectionDataDelegate, NSUserNotificationCenterDelegate>
//other
@property BOOL successfulNewUser;
@property BOOL isMonitoring;
@property BOOL settingPermUser;
@property BOOL isGettingRegistrationCode;
@property BOOL isProUser;
@property int timeEndCount;
@property NSString* uuid;
@property NSDateFormatter *time_format;
@property NSDate *current_time;
@property SAMKeychainQuery *keychainQuery;

//animation menu bar
@property NSTimer*animateTimer;
@property int lastAnimate;

//for menu updates
@property int lastY;

//menu bar
@property NSStatusItem *statusItem;
@property NSMenu *menu;

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

@property NSMenuItem* showOnStartupItem;

//upload
@property NSWindow* window;
@property NSView* view;
@property NSString* uploadFilePath;
@property BOOL isUploading;
@property STHTTPRequest *uploadReq;
- (void)chooseFriend;

//new user
@property NSString *userCode;
@property NSString *phoneticUser;
@property unsigned long long bandwidthLeft;
@property NSString *maxTime;
@property NSString *wantedTime;
@property int userTier;
@property BOOL isCreatingUser;
@property NSString* regCode;

//download
@property NSMutableData *downloadData;
@property NSUInteger receivedBytes;
@property NSMutableArray* files;
@property NSMutableArray* keys;
@property NSString* downloadingPath;
@property BOOL isDownloading;
@property BOOL hasRequestedDownload;
@property long long responseExpectedContentLength;
@property (nonatomic, strong, readonly) NSMutableData *responseData;
@property NSURLConnection * connection;
@property NSString* tempStoreIncomingPath;
@property NSString* dlStartTime;
@property STHTTPRequest *downloadReq;

//desktop notification
@property NSString* previousDesktopTitle;
@property int notificationCount;

//UIVIEW
@property NSTextField *label;
@property NSTextField *labelShaddow;
@property NSTextField *inputCode;
@property NSTextField* errorMessage;

//monitor socket
@property (strong) SRWebSocket* webSocket;
@property BOOL connectedToSocket;
@property BOOL authedSocket;

@property NSString* theTime5;

@end
