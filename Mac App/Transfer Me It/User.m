//
//  User.m
//  Transfer Me It
//
//  Created by Maximilian Mitchell on 13/02/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import "User.h"

#import <STHTTPRequest/STHTTPRequest.h>

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
    
    //listen for user time left asker (menuBar.h)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askForRealTime) name:@"ask-time" object:nil];
    
    // listen for keep alive message to not delete a file that is being downloaded (Download.h)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendKeepAlive:) name:@"keep-alive" object:nil];
    
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
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"setTime"] != nil){
        wantedTime = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"setTime"];
    }
    [self create:wantedTime];
}

-(void)createFromMenu:(NSNotification*)obj{
    int wantedTime = [(NSString*)obj.userInfo intValue];
    [self create:wantedTime];
}

-(void)create:(int)wantedTime{
    _code = nil;
    
    if(!_createFailed) [_menuBar setRequestingCodeMenu];
    
    NSString* permUserCode = @"";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user_code"] != nil) permUserCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user_code"];
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/addNewUser.php"];
    r.timeoutSeconds = 3;
    
    NSString *uuidKey = [_keychain getKey:@"UUID Key"];
    if(uuidKey == nil) uuidKey = @"";
    
    r.POSTDictionary = @{ @"server_key":[LOOCryptString serverKey],
                          @"UUID":_uuid,
                          @"UUIDKey":uuidKey,
                          @"mins": [NSString stringWithFormat:@"%d", wantedTime],
                          @"perm_user_code":permUserCode, // this proves that the client knows they have a perm_user_code (extra security)
                          @"pub_key": [[[RSAClass alloc] initWithKeys:_keychain] getPub]}; // pass public key to server
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        _createFailed = false;
        NSString* userCode = [CustomFunctions jsonToVal:body key:@"user_code"];
        if(![userCode isEqual: @""]){
            
            // effectively the password for the account on transferme.it where your UUID is your username.
            NSString* newUUIDkey = [CustomFunctions jsonToVal:body key:@"UUID_key"];
            if([newUUIDkey length] == 100){ // only happens when using tmi for the first time.
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
            
            _secondCount    = 0;
            _timeLeft       = [[CustomVars dateFormat] dateFromString:[CustomFunctions jsonToVal:body key:@"time_left"]];
            
            _maxTime        = [[CustomFunctions jsonToVal:body key:@"mins_allowed"] intValue];
            _tier           = [[CustomFunctions jsonToVal:body key:@"user_tier"] intValue];
            
            [[NSUserDefaults standardUserDefaults] setInteger:wantedTime forKey:@"setTime"];
            _wantedTime = wantedTime;
            
            if(!_socket) [self createSocket];
            
            [self setDefaultMenu];
        }else{
            NSString* status = [CustomFunctions jsonToVal:body key:@"status"];
            if([status isEqual: @"brute"]){
                //made too many new user requests return old data
                [self setDefaultMenu];
            }else if([status isEqual: @"socket_down"]){
                [_menuBar setErrorMenu:@"Server Socket Down!"];
                // try connect again in 10 seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _createFailed=true;
                    [self create];
                });
            }else if([status isEqual: @"invalid_pub_key"]){
                // if this occurs something pretty seriously wrong has happened as the user has passed the client side key validation
                // but not the server.
                [DesktopNotification send:@"Error Creating User!" message:@"Invalid public key uploaded. Generated new one."];
                
                [[[RSAClass alloc] initWithKeys:_keychain] generatePair]; // create new keys
                [self create];
                NSLog(@"Invalid Public Key");
            }else if([status isEqual: @"perm_code_lie"]){
                [DesktopNotification send:@"Permenant Code Error!" message:@"You have had your perm code removed."];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"perm_user_code"];
                [self create];
            }else if([status isEqual: @"invalid_UUID_key"]){
                [_keychain deleteKey:@"UUID Key"];
                [DesktopNotification send:@"Emergency!" message:@"Your UUID Key has been purged. Please contact hello@transferme.it."];
            }else{
                NSLog(@"Error creating user %@", body);
                [DesktopNotification send:@"Error Creating User!" message:status];
                [CustomFunctions quit];
            }
        }
    };
    
    r.errorBlock = ^(NSError *error) {
        NSLog(@"USER ERROR: %@",[error localizedDescription]);
        [_menuBar setErrorMenu:@"Network Error!"];
        _code = false;
        
        // try again in 5 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"Creating new user after fail");
            [self create];
        });
    };
    
    [r startAsynchronous];
}

-(void)setDefaultMenu{
    [_menuBar setDefaultMenu:self.code bandwidthLeft:self.bandwidthLeft maxFileUpload:self.maxFileUpload maxTime:self.maxTime wantedTime:self.wantedTime userTier:self.tier timeLeft:self.timeLeft];
}

#pragma mark - Socket Handler
-(void)handleSocketMessage:(NSString*)json{
    NSString* type = [CustomFunctions jsonToVal:json key:@"type"];
    
    if([type  isEqual: @"download"]){
        NSString* path = [CustomFunctions jsonToVal:json key:@"path"];
        NSString* friendUUID = [CustomFunctions jsonToVal:json key:@"UUID"];
        NSLog(@"actual %@",[CustomFunctions jsonToVal:json key:@"ref"]);
        unsigned long long ref = [CustomFunctions stringToULL:[CustomFunctions jsonToVal:json key:@"ref"]];
        NSLog(@"new %llu",ref);
        
        if([CustomFunctions getStoredBool:@"autoDownload"]){
            // auto download to location
            [[[Download alloc] initWithKeychain:_keychain menuBar:_menuBar] downloadTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"saveLocation"] friendUUID:friendUUID downloadPath:path downloadRef:ref];
        }else{
            // Open window asking client whether they would like to download the file
            [_window downloadView:[[_menuBar valueForKey:@"window"] frame] downloadInfo:json];
        }
    }else if([type  isEqual: @"time"]){
        _socket.authed = true;
        if([_menuBar.menuName isEqual: @"error"] && _code) [self setDefaultMenu];
        
        NSString* time = [CustomFunctions jsonToVal:json key:@"time"];
        if([time isEqual: @"-"]){
            // account ended - create a new one
            NSLog(@"account told to terminate");
            [self create];
        }else{
            _secondCount = 0;
            _timeLeft = [[CustomVars dateFormat] dateFromString:time];
        }
    }else if([type  isEqual: @"bw"]){
        _bandwidthLeft  = [[CustomFunctions jsonToVal:json key:@"bw_left"] integerValue];
        _maxFileUpload  = [[CustomFunctions jsonToVal:json key:@"max_fs"] integerValue];
        
        // reload menu with updated bandwdith and max file upload size
        [self setDefaultMenu];
    }else if([type isEqual: @"downloaded"]){
        NSString* message = [CustomFunctions jsonToVal:json key:@"title"];
        NSString* path = [CustomFunctions jsonToVal:json key:@"message"];
        
        //ask what bandwidth is left
        [self askForRealBandwidth];
        
        //Your friend succesfully downloaded the file!
        [DesktopNotification send:message message:[NSString stringWithFormat:@"%@", [path lastPathComponent]]];
        
    }else if(![type isEqual: @"Error"]){ //don't need to alert user of this
        NSString* message = [CustomFunctions jsonToVal:json key:@"message"];
        if([message isEqual: @"already_connected"]){
            [self.menuBar setErrorMenu:@"Two user error!"];
        }else{
            NSLog(@"incoming socket error: %@",message);
            [DesktopNotification send:@"Socket Error" message:message];
        }
    }else{
        NSLog(@"%@",json);
    }
}

#pragma mark - socket
-(void)createSocket{
    NSLog(@"Creating new socket");
    _socket = [[Socket alloc] initWithURL:@"wss://s.transferme.it"];
    
    __weak typeof(self) weakSelf = self;
    
    [_socket setOnConnectBlock:^{
        [_socket send:[weakSelf authMessage]];
    }];
    
    [_socket setOnCloseBlock:^{
        [weakSelf.menuBar setErrorMenu:@"Network Error"];
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
    if(_socket.authed && _code){
        [_socket send:[CustomFunctions dicToJsonString:@{
                                                    @"type":@"keep",
                                                    @"UUID": _uuid,
                                                    @"userCode":_code,
                                                    @"path":path
                                                    }]];
    }
}

-(void)askForRealTime{
    if(_socket.authed && _code){
        [_socket send:[CustomFunctions dicToJsonString:@{
                                                    @"type":@"time",
                                                    @"UUID": _uuid,
                                                    @"userCode":_code
                                                    }]];
    }
}

//used to get the amnt of bandwidth the user has left (after your friend has downloaded)
-(void)askForRealBandwidth{
    if(_socket.authed){
        NSLog(@"asking bw");
        [_socket send:[CustomFunctions dicToJsonString:@{
                                                    @"type":@"bw",
                                                    @"UUID": _uuid
                                                    }]];
    }else{
        //todo this is not the best idea
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self askForRealBandwidth];
        });
    }
}

// send a message to server with authentication details
- (NSString*)authMessage{
    return [CustomFunctions dicToJsonString:@{
                                              @"serverKey": [LOOCryptString serverKey],
                                              @"type":@"connect",
                                              @"UUID": _uuid,
                                              @"UUIDKey": [_keychain getKey:@"UUID Key"]
                                              }];
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
    unsigned long long dlRef = [CustomFunctions stringToULL:[CustomFunctions jsonToVal:jsonInfo key:@"dlRef"]];
    NSString* friendUUID = [CustomFunctions jsonToVal:jsonInfo key:@"friendUUID"];
    
    [[[Download alloc] initWithKeychain:_keychain menuBar:_menuBar] downloadTo:localPath friendUUID:friendUUID downloadPath:serverPath downloadRef:dlRef];
}

#pragma mark - every second
bool dnd_was_on = false;
-(void)everySecond{
    _secondCount++;
    
    // check dnd is not turned on
    if([CustomFunctions dndIsOn]){
        dnd_was_on = true;
        [_menuBar setErrorMenu:@"Please turn off 'Do Not Disturb'"];
    }else if(dnd_was_on){
        [self setDefaultMenu];
    }
    
    // update time in icon menu
    if ([_menuBar.menuName isEqual: @"default"]) { // default menu
        NSDate* deducted_date = [_timeLeft dateByAddingTimeInterval:-_secondCount];
        [_menuBar setMenuTime:deducted_date];
    }
    
    if(_secondCount % 15 == 0){
        [CustomFunctions sendNotificationCenter:nil name:@"ask-time"];
    }
}
@end
