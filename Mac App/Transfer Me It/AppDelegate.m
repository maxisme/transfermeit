//
//  AppDelegate.m
//  Transfer Me It
//
//  Created by Max Mitchell on 10/02/2017.
//  Copyright © 2017 Maximilian Mitchell. All rights reserved.
//

#import "AppDelegate.h"

#import <Sentry/Sentry.h>
#import <ExceptionHandling/NSExceptionHandler.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#import "MenuBar.h"
#import "PopUpWindow.h"
#import "User.h"
#import "CustomFunctions.h"
#import "Keys.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [CustomFunctions onlyOneInstanceOfApp];
    
    // Sentry
    NSError *error = nil;
    SentryClient *client = [[SentryClient alloc] initWithDsn:@"https://ef8959eede4e4b8eaaad403586bb149d@sentry.io/1527114" didFailWithError:&error];
    SentryClient.sharedClient = client;
    [SentryClient.sharedClient startCrashHandlerWithError:&error];
    if (nil != error) {
        NSLog(@"sentry: %@", error);
    }
    
    // Logging
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24 * 7;
    [DDLog addLogger:fileLogger];
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // log to xcode output
    [DDLog addLogger:[DDOSLogger sharedInstance]]; // log apple stuff
    [[NSUserDefaults standardUserDefaults] setObject:[[fileLogger currentLogFileInfo] filePath] forKey:@"logging_path"];
    DDLogDebug(@"Started");
    
    // handle crashing logs
    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask:NSLogAndHandleEveryExceptionMask];
    [[NSExceptionHandler defaultExceptionHandler] setDelegate:self];
    
    // enables finder right click
    [NSApp setServicesProvider:self];
    NSUpdateDynamicServices();
    
    if(![[[Keys alloc] init] getKey:@"UUID Key"]){
        // first time using app
        [CustomFunctions openOnStartup];
    }
    
    _w = [[PopUpWindow alloc] init];
    _mb = [[MenuBar alloc] initWithStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] window:_w];
    
    [[[User alloc] initWithMenuBar:_mb] create]; // initiate user
    
    //check for app update
    [CustomFunctions checkForUpdate:false];
}

- (BOOL)exceptionHandler:(NSExceptionHandler *)sender shouldLogException:(NSException *)exception mask:(NSUInteger)aMask{

    NSString* exc = [exception reason];
    DDLogError(@"Stack: %@", [NSThread callStackSymbols]);
    DDLogError(@"Crash Exception: %@", exc);

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Okay"];
    [alert setMessageText:@"App unexpectedly closed! We have been notified. Please reopen app."];
    [alert setInformativeText:[NSString stringWithFormat:@"Crash Message: %@", exc]];
    [alert setAlertStyle:NSAlertStyleCritical];
    [alert runModal];

    [NSApp terminate:self]; // force close app

    return true;
}

# pragma mark - finder right click send file
- (void)finderService:(NSPasteboard *)pboard
              userData:(NSString *)userData
                 error:(NSString **)error {
    if([[pboard types] containsObject:NSFilenamesPboardType]){
        NSArray* fileArray=[pboard propertyListForType:NSFilenamesPboardType];
        [_w setSendToFriendView:[[_mb valueForKey:@"window"] frame] filePath:fileArray[0]];
    }
}

@end
