//
//  User.m
//  Transfer Me It
//
//  Created by Maximilian Mitchell on 13/02/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import "User.h"

#import <STHTTPRequest/STHTTPRequest.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#import "CustomVars.h"
#import "CustomFunctions.h"
#import "Keys.h"
#import "MenuBar.h"
#import "RSAClass.h"
#import "DesktopNotification.h"
#import "Socket.h"
#import "PopUpWindow.h"
#import "Download.h"
#import "Upload.h"

#import "LOOCryptString.h"

@implementation User
-(id)initWithMenuBar:(MenuBar*)mb{
    if (self != [super init]) return nil;
    
    //initialisers g
    _window = mb.w;
    _menuBar = mb;
    
    _uuid = [CustomFunctions getSystemUUID];
    _keychain = [[Keys alloc] init];
    
    // get user details from server
    _createFailed = false;
    
    //listen for create new user message (PopUpWindow.h)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(create) name:@"create-user" object:nil];
    
    //listen for create new user message (menuBar.h)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createFromMenu:) name:@"create-user-menu" object:nil];
    
    // listen for keep alive message to not delete a file that is being downloaded (Download.h)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendKeepAlive:) name:@"keep-alive" object:nil];
    
    // listen for refresh of user stats
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserStats) name:@"user-stats" object:nil];
    
    // listen for setting default status item menu (menuBar.h)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDefaultMenu) name:@"set-default-menu" object:nil];
    
    // listen for download (PopUpWindow.h)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFileListener:) name:@"download-file" object:nil];
    
    // listen for upload (PopUpWindow.h)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFileListener:) name:@"upload-file" object:nil];
    
    //run a timer in main thread so as to manipulate menu and menu-icon
    NSTimer*timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(everySecond) userInfo:nil repeats:YES];
    NSRunLoop * rl = [NSRunLoop mainRunLoop];
    [rl addTimer:timer forMode:NSRunLoopCommonModes];
    return self;
}

#pragma mark - create a user
-(void)create{
    int wantedTime = 10;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"wantedTime"] != nil){
        wantedTime = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"wantedTime"];
    }
    [self create:wantedTime];
}

-(void)createFromMenu:(NSNotification*)obj{
    int wantedTime = [(NSString*)obj.userInfo intValue];
    [self create:wantedTime];
}

bool UUID_purge;
-(void)create:(int)wantedTime{
    _code = nil;
    
    if(!_createFailed) [_menuBar setRequestingCodeMenu];
    
    NSString* permUserCode = @"";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user_code"] != nil) permUserCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user_code"];
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://sock.transferme.it/code"];
    r.requestHeaders = [[NSMutableDictionary alloc] initWithDictionary:@{@"Sec-Key":[LOOCryptString serverKey]}];
    r.timeoutSeconds = 3;
    
    NSString *uuidKey = [_keychain getKey:@"UUID Key"];
    if(uuidKey == nil) uuidKey = @"";
    
    r.POSTDictionary = @{
        @"UUID":_uuid,
        @"UUID_key":uuidKey,
        @"wanted_mins": [NSString stringWithFormat:@"%d", wantedTime],
        @"perm_user_code":permUserCode, // this proves that the client knows they have a perm_user_code (extra security)
        @"public_key": [[[RSAClass alloc] initWithKeys:_keychain] getPub]
    };
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        _createFailed = false;
        NSString* userCode = [CustomFunctions jsonToVal:body key:@"user_code"];
        if(![userCode isEqual: @""]){
            
            // effectively the password for the account on transferme.it where your UUID is your username.
            NSString* newUUIDkey = [CustomFunctions jsonToVal:body key:@"UUID_key"];
            if([newUUIDkey length] > 0){ // only happens when using tmi for the first time.
                //receiving the key
                if(![_keychain setKey:@"UUID Key" withPassword:newUUIDkey]){
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"Major Key Error"];
                    [alert setInformativeText:@"Problem storing key in keychain. Please contact hello@transferme.it"];
                    [alert addButtonWithTitle:@"Okay"];
                    [alert runModal];
                    [CustomFunctions quit];
                }
            }
            
            // store all information from creating a new user
            _code           = userCode;
            _bandwidthLeft  = [[CustomFunctions jsonToVal:body key:@"bw_left"] integerValue];
            _maxFileUpload  = [[CustomFunctions jsonToVal:body key:@"max_fs"] integerValue];
            // work out time left
            _endTime       = [CustomFunctions formatGoTime:[CustomFunctions jsonToVal:body key:@"end_time"]];
            _maxTime        = [[CustomFunctions jsonToVal:body key:@"mins_allowed"] intValue];
            _tier           = [[CustomFunctions jsonToVal:body key:@"user_tier"] intValue];
            
            [[NSUserDefaults standardUserDefaults] setInteger:[[CustomFunctions jsonToVal:body key:@"wanted_mins"] intValue] forKey:@"wantedTime"];
            
            if(!_socket) [self createSocket];
            
            [self setDefaultMenu];
        }
    };
    
    r.errorBlock = ^(NSError *error) {
        DDLogDebug(@"USER ERROR: %@", r.responseString);
        int responseCode = r.responseStatus;
        if(responseCode == 401){
            // if this occurs something pretty seriously wrong has happened as the user has passed the client side key validation
            // but not the server.
            [DesktopNotification send:@"Error Creating User!" message:@"Invalid public key uploaded. Generated new one."];
            
            [[[RSAClass alloc] initWithKeys:_keychain] generatePair]; // create new keys
            [self create];
            DDLogDebug(@"Invalid Public Key");
        }else if(responseCode == 402){
            [_keychain deleteKey:@"UUID Key"];
            if(!UUID_purge){
                UUID_purge = TRUE;
                [DesktopNotification send:@"Emergency!" message:@"Your UUID Key has been purged. Please contact hello@transferme.it."];
            }
        }
        [_menuBar setErrorMenu:@"Network Error!"];
        _code = false;
        
        // try again in 5 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DDLogDebug(@"Creating new user after fail");
            [self create];
        });
    };
    
    [r startAsynchronous];
}

-(void)setDefaultMenu{
    [_menuBar setDefaultMenu:self.code bandwidthLeft:self.bandwidthLeft maxFileUpload:self.maxFileUpload maxTime:self.maxTime userTier:self.tier];
}

#pragma mark - Socket Handler
-(void)handleSocketMessage:(NSString*)json{
    NSDictionary* user = [CustomFunctions jsonToVal:json key:@"user"];
    NSDictionary* download = [CustomFunctions jsonToVal:json key:@"download"];
    NSDictionary* message = [CustomFunctions jsonToVal:json key:@"message"];
    
    if(![download isEqual:[NSNull null]]){
        if([CustomFunctions getStoredBool:@"autoDownload"]){
            // auto download to location
            [[[Download alloc] initWithKeychain:_keychain menuBar:_menuBar] downloadTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"saveLocation"] downloadPath:download[@"file_path"]];
        }else{
            // Open window asking client whether they would like to download the file
            [_window downloadView:[[_menuBar valueForKey:@"window"] frame] downloadInfo:download];
        }
    }else if(![user isEqual:[NSNull null]]){
        if([_menuBar.menuName isEqual: @"error"] && _code) [self setDefaultMenu];
        
        _endTime = [CustomFunctions formatGoTime:user[@"end_time"]];
        if((_endTime == nil || [[NSDate date] compare:_endTime] == NSOrderedAscending) && ![_menuBar.menuName isEqual:@"download"] && ![_menuBar.menuName isEqual:@"upload"]){
            // code expired - create a new one
            [self create];
        }else{
            _bandwidthLeft  = [user[@"bw_left"] integerValue];
            _maxFileUpload  = [user[@"max_fs"] integerValue];
            
            // reload menu with updated bandwdith and max file upload size
            [self setDefaultMenu];
        }
    }else if(![message isEqual:[NSNull null]]){
        [DesktopNotification send:message[@"title"] message:message[@"message"]];
        [CustomFunctions sendNotificationCenter:nil name:@"user-stats"]; // TODO potentially a bit overkill
    }else{
        DDLogDebug(@"Invalid socket message: %@",json);
    }
}

#pragma mark - socket
-(void)createSocket{
    _socket = [[Socket alloc] initWithURL:@"https://sock.transferme.it/ws"];
    
    __weak typeof(self) weakSelf = self;
    
    [_socket setOnConnectBlock:^{
        [weakSelf setDefaultMenu];
    }];
    
    [_socket setOnCloseBlock:^{
        [weakSelf.menuBar setErrorMenu:@"Network Error..."];
    }];
    
    [_socket setOnMessageBlock:^(NSString *message) {
        [weakSelf handleSocketMessage:message];
    }];
}

// used to tell the server not to delete the file as still downloading
// SECURITY: the path of the file on the server (huge complicated path) along with the
// UUID of the user (authenticated) is enough to prevent anyone unencesarrily keeping
// the file on the server.
-(void)sendKeepAlive:(NSNotification*)obj{
    NSString* path = (NSString*)obj.userInfo;
    [_socket send:[CustomFunctions dicToJsonString:@{
        @"type":@"keep-alive",
        @"content":path
    }]];
}

-(void)getUserStats{
    [_socket send:[CustomFunctions dicToJsonString:@{
        @"type":@"stats"
    }]];
}

#pragma mark - upload and download
- (void)uploadFileListener:(NSNotification*)obj{
    NSString* jsonInfo = (NSString*)obj.userInfo;
    NSString* filePath = [CustomFunctions jsonToVal:jsonInfo key:@"path"];
    NSString* friendCode = [CustomFunctions jsonToVal:jsonInfo key:@"friendCode"];
    
    [[[Upload alloc] initWithWindow:_window menuBar:_menuBar] uploadFile:filePath friend:friendCode keys:_keychain];
}

- (void)downloadFileListener:(NSNotification*)obj{
    NSString* jsonInfo = (NSString*)obj.userInfo;
    NSString* localPath = [CustomFunctions jsonToVal:jsonInfo key:@"localPath"];
    NSString* serverPath = [CustomFunctions jsonToVal:jsonInfo key:@"serverPath"];
    [[[Download alloc] initWithKeychain:_keychain menuBar:_menuBar] downloadTo:localPath downloadPath:serverPath];
}

#pragma mark - every second
bool dnd_was_on = false;
-(void)everySecond{
    
    // check dnd is not turned on
    if([CustomFunctions dndIsOn]){
        dnd_was_on = true;
        [_menuBar setErrorMenu:@"Please turn off 'Do Not Disturb'"];
    }else if(dnd_was_on){
        dnd_was_on = false;
        [self setDefaultMenu];
    }
    
    // update time in icon menu
    if ([_menuBar.menuName isEqual: @"default"] && _endTime) { // default menu
        NSTimeInterval diff = [_endTime timeIntervalSinceDate:[NSDate date]];
        [_menuBar setMenuTime:diff];
    }
}
@end
