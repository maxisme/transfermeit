//
//  AppDelegate.m
//  Transfer Me It
//
//  Created by Max Mitchell on 10/02/2017.
//  Copyright © 2017 Maximilian Mitchell. All rights reserved.
//

#import "AppDelegate.h"

#import "MenuBar.h"
#import "PopUpWindow.h"
#import "User.h"
#import "CustomFunctions.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    /* for testing remove comment and remove keychain */
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    [CustomFunctions onlyOneInstanceOfApp];
    
    // finder right click
    [NSApp setServicesProvider:self];
    NSUpdateDynamicServices();
    
    _w = [[PopUpWindow alloc] init];
    _mb = [[MenuBar alloc] initWithStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] window:_w];
    
    [[[User alloc] initWithMenuBar:_mb] create]; // initiate user
    
    //check for transferme.it update
    [CustomFunctions checkForUpdate:false];
    
    [_w downloadView:[[_mb valueForKey:@"window"] frame] downloadInfo:@"{\"path\":\"foo.zip\"}"];
}

# pragma mark - finder right click
- (void)finderService:(NSPasteboard *)pboard
              userData:(NSString *)userData
                 error:(NSString **)error {
    if([[pboard types] containsObject:NSFilenamesPboardType]){
        NSArray* fileArray=[pboard propertyListForType:NSFilenamesPboardType];
        [_w setSendToFriendView:[[_mb valueForKey:@"window"] frame] filePath:fileArray[0]];
    }
}
@end
