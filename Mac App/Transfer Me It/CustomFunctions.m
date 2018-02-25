//
//  CustomFunctions.m
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "CustomFunctions.h"

#import <CommonCrypto/CommonDigest.h>
#import <Sparkle/Sparkle.h>

@implementation CustomFunctions

#pragma mark - app
+ (BOOL)toggleOpenOnStartup{
    if(![self doesOpenOnStartup]){
        [self openOnStartup];
        return true;
    }else{
        [self dontOpenOnStartup];
        return false;
    }
}

+ (BOOL)doesOpenOnStartup{
    BOOL found = NO;
    UInt32 seedValue;
    CFURLRef thePath = NULL;
    LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
    // and pop it in an array so we can iterate through it to find our item.
    CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
    for (id item in (__bridge NSArray *)loginItemsArray) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
        if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
            if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
                found = YES;
                break;
            }
            // Docs for LSSharedFileListItemResolve say we're responsible
            // for releasing the CFURLRef that is returned
            if (thePath != NULL) CFRelease(thePath);
        }
    }
    if (loginItemsArray != NULL) CFRelease(loginItemsArray);
    
    return found;
}

+ (void)openOnStartup{
    if(![self doesOpenOnStartup]){
        LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        if (loginListRef) {
            // Insert the item at the bottom of Login Items list.
            LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginListRef,
                                                                                 kLSSharedFileListItemBeforeFirst,
                                                                                 NULL,
                                                                                 NULL,
                                                                                 (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]],
                                                                                 NULL,
                                                                                 NULL);
            if (loginItemRef) {
                CFRelease(loginItemRef);
            }
            CFRelease(loginListRef);
        }
    }
}

+ (void)dontOpenOnStartup{
    if([self doesOpenOnStartup]){
        LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginListRef,
                                                                             kLSSharedFileListItemBeforeFirst,
                                                                             NULL,
                                                                             NULL,
                                                                             (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]],
                                                                             NULL,
                                                                             NULL);
        
        // Insert the item at the bottom of Login Items list.
        LSSharedFileListItemRemove(loginListRef, loginItemRef);
    }
}

+ (void)onlyOneInstanceOfApp {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
        NSLog(@"already open app");
        [self quit];
    }
}

+ (void)quit{
    [NSApp terminate:self];
}

+ (NSString *)getSystemUUID {
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    if (!platformExpert)
        return nil;
    
    CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,CFSTR(kIOPlatformUUIDKey),kCFAllocatorDefault, 0);
    IOObjectRelease(platformExpert);
    if (!serialNumberAsCFString)
        return nil;
    
    return (__bridge NSString *)(serialNumberAsCFString);;
}

+ (BOOL)fileIsPath:(NSString*)path {
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) return !isDir;
    return false;
}

+ (BOOL)dndIsOn{
    NSString* path =  [[NSString stringWithFormat:@"~/Library/Preferences/ByHost/com.apple.notificationcenterui.%@.plist", [self getSystemUUID]] stringByExpandingTildeInPath];
    
    return [[NSDictionary dictionaryWithContentsOfFile:path][@"doNotDisturb"] boolValue];
}

+ (NSString*)cleanUpString:(NSString*)unfilteredString{
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    NSString* removed_special_chars = [[unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    return [removed_special_chars stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (NSString*)choosePathWindow:(NSString*)title buttonTitle:(NSString*)buttonTitle allowDir:(BOOL)dir allowFile:(BOOL)file{
    [NSApp activateIgnoringOtherApps:YES];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setLevel:NSFloatingWindowLevel];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:dir];
    [openPanel setCanCreateDirectories:dir];
    [openPanel setCanChooseFiles:file];
    [openPanel setMessage:title];
    [openPanel setPrompt:buttonTitle];
    
    if ([openPanel runModal] == NSModalResponseOK)
    {
        NSArray *files = [openPanel URLs];
        return [[files objectAtIndex:0] path];
    }
    
    return nil;
}

+ (NSString *)hash:(NSData *)data{
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString*)overflowString:(NSString*)string size:(int)size{
    if([string length] > size){
        string = [NSString stringWithFormat:@"%@...", [string substringToIndex:size]];
    }
    return string;
}

+ (NSString *)randomString:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint_fast32_t)[letters length])]];
    }
    
    return randomString;
}

+ (NSString*)jsonToVal:(NSString*)json key:(NSString*)key{
    NSMutableDictionary* dic = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    if([dic objectForKey:key]) return [dic objectForKey:key];
    return @"";
}

+ (NSString*)dicToJsonString:(NSDictionary*)dic{
    NSError* error;
    NSData *jd = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) return @"";
    return [[NSString alloc] initWithData:jd encoding:NSUTF8StringEncoding];
}

+ (unsigned long long)bytesToMega:(unsigned long long)bytes{
    return bytes / 1048576;
}

// used to calculate the size of a file after it will have been encrypted using RNEncryptor
+ (unsigned long long)bytesToEncrypted:(unsigned long long)bytes{
    int overhead = 66;
    
    if (bytes == 0) {
        return 16 + overhead;
    }
    
    int remainder = bytes % 16;
    if (remainder == 0) {
        return bytes + 16 + overhead;
    }
    
    return bytes + 16 - remainder + overhead;
}

+ (void)copyText:(NSString*)text{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString:text forType:NSStringPboardType];
}

+ (void)goPro{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://transferme.it/#Credit"]];
}

// sends local notification to listeners in other classes.
+ (void)sendNotificationCenter:(id)message name:(NSString*)name{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:message];
}

+ (void)setStoredBool:(NSString*)name b:(bool)b{
    [[NSUserDefaults standardUserDefaults] setBool:b forKey:name];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getStoredBool:(NSString*)name{
    return [[NSUserDefaults standardUserDefaults] boolForKey:name];
}

+ (bool)writeDataToFile:(NSData*)file destinationPath:(NSString*)path{
    return [file writeToFile:path atomically:YES];
}

+ (NSString*)stringToPhonetic:(NSString*)string{
    NSString* phonetic = @"";
    unsigned int len = (int)[string length];
    unsigned short buffer[len];
    
    [string getCharacters:buffer range:NSMakeRange(0, len)];
    
    for(int i = 0; i < len; ++i) {
        char current = buffer[i];
        phonetic = [NSString stringWithFormat:@"%@ %@",phonetic, [self letterToPhonetic:current]];
    }
    return [phonetic stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

+ (NSString*)letterToPhonetic:(char)letter{
    switch (letter) {
        case 'A':
            return @"Alfa";
        case 'B':
            return @"Bravo";
        case 'C':
            return @"Charlie";
        case 'D':
            return @"Delta";
        case 'E':
            return @"Echo";
        case 'F':
            return @"Foxtrot";
        case 'G':
            return @"Golf";
        case 'H':
            return @"Hotel";
        case 'I':
            return @"India";
        case 'J':
            return @"Juliett";
        case 'K':
            return @"Kilo";
        case 'L':
            return @"Lima";
        case 'M':
            return @"Mike";
        case 'N':
            return @"November";
        case 'O':
            return @"Oscar";
        case 'P':
            return @"Papa";
        case 'Q':
            return @"Quebec";
        case 'R':
            return @"Romeo";
        case 'S':
            return @"Sierra";
        case 'T':
            return @"Tango";
        case 'U':
            return @"Uniform";
        case 'V':
            return @"Victor";
        case 'W':
            return @"Whiskey";
        case 'X':
            return @"Xray";
        case 'Y':
            return @"Yankee";
        case 'Z':
            return @"Zulu";
        default:
            return [NSString stringWithFormat:@"%c",letter];
    }
}

+ (void)checkForUpdate:(bool)fg{
    if(fg){
        [[SUUpdater sharedUpdater] checkForUpdates:self];
    }else{
        [[SUUpdater sharedUpdater] checkForUpdatesInBackground];
    }
}

+ (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

+ (unsigned long long)stringToULL:(NSString*)str{
    return [[[[NSNumberFormatter alloc] init] numberFromString:str] unsignedLongLongValue];
}
@end
