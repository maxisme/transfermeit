//
//  CustomFunctions.h
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface CustomFunctions : NSObject
+ (BOOL)toggleOpenOnStartup;
+ (BOOL)openOnStartup;
+ (BOOL)doesOpenOnStartup;

+ (void)onlyOneInstanceOfApp;
+ (void)quit;

+ (BOOL)fileIsPath:(NSString*)path;
+ (BOOL)dndIsOn;
+ (NSString*)cleanUpString:(NSString*)unfilteredString;
+ (NSString*)choosePathWindow:(NSString*)title buttonTitle:(NSString*)buttonTitle allowDir:(BOOL)dir allowFile:(BOOL)file;
+ (NSString *)hash:(NSData *)data;
+ (NSString*)overflowString:(NSString*)string size:(int)size;
+ (NSString *)randomString:(int)len;
+ (NSString *)getSystemUUID;
+ (void)copyText:(NSString*)text;

+ (id)jsonToVal:(NSString*)json key:(NSString*)key;
+ (NSString*)dicToJsonString:(NSDictionary*)dic;

+ (unsigned long long)bytesToMega:(unsigned long long)bytes;
+ (unsigned long long)bytesToEncrypted:(unsigned long long)bytes;

+ (void)goPro;
+ (void)sendNotificationCenter:(id)message name:(NSString*)name;

+ (void)setStoredBool:(NSString*)name b:(bool)b;
+ (BOOL)getStoredBool:(NSString*)name;

+ (bool)writeDataToFile:(NSData*)file destinationPath:(NSString*)path;

+ (NSString*)stringToPhonetic:(NSString*)string;
+ (NSString*)letterToPhonetic:(char)letter;

+ (void)checkForUpdate:(bool)fg;
+ (void)checkForBetaUpdate;

+ (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font;
+ (unsigned long long)stringToULL:(NSString*)str;

+ (NSDate*)formatGoTime:(NSString *)goTime;
@end
