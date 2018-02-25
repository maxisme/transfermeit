//
//  PopUpView.m
//  Transfer Me It
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import "PopUpWindow.h"

#import <QuartzCore/QuartzCore.h>
#import <STHTTPRequest/STHTTPRequest.h>

#import "CustomVars.h"
#import "CustomFunctions.h"
#import "Button.h"
#import "SubmitButton.h"
#import "DesktopNotification.h"
#import "Keys.h"
#import "Upload.h"
#import "Download.h"

@interface BorderTextField : NSTextField
@end
@implementation BorderTextField
-(id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        [self setWantsLayer:YES];
        [self.layer setBorderColor:(__bridge CGColorRef _Nullable)([CustomVars red])];
        [self.layer setBorderWidth:4];
        [self setBezeled:YES];
        [self.layer setMasksToBounds:true];
    }
    
    return self;
}
@end

@interface KeyWindow: NSWindow
- (BOOL) canBecomeKeyWindow;
@end

@implementation KeyWindow
- (BOOL) canBecomeKeyWindow{ return YES; }
@end

@implementation PopUpWindow

#define MAX_FILE_LEN 40
-(id)init{
    if (self != [super init]) return nil;
    
    _windowWidth = [CustomVars windowWidth];
    _windowHeight = [CustomVars windowHeight];
    
    _keychain = [[Keys alloc] init];
    _uuid = [CustomFunctions getSystemUUID];
    
    return self;
}

#pragma mark - windows
-(void)setSendToFriendView:(NSRect)statusBarFrame filePath:(NSString*)filePath{
    _viewName = @"stf";
    
    [self createDynamicInputWindow];

    [self createLabel:@"E N T E R  F R I E N D S  C O D E"];

    // create a on hover tooltip which tells you the file path you are wanting to upload
    int tooltip_wh = 15;
    Button* fileButton = [[Button alloc] initWithFrame:CGRectMake(_windowWidth - (tooltip_wh + 5), _windowHeight - tooltip_wh - 20, tooltip_wh, tooltip_wh)];
    [fileButton setImage:[NSImage imageNamed:@"file.png"]];
    [fileButton setImageScaling:NSImageScaleProportionallyDown];
    [fileButton setBordered:false];
    [fileButton setFocusRingType:NSFocusRingTypeNone];
    [fileButton updateTrackingAreas];
    fileButton.message = filePath;
    [fileButton setAction:@selector(popUpMessage:)];
    [_view addSubview:fileButton];
    
    // create the plane submit button
    [self createSubButton];
    [_subButton setUploadFilePath:filePath];
    [_subButton setAction:@selector(uploadFile)];

    [[self window] makeFirstResponder:_inputCode];
    
    [self showView:statusBarFrame];
}

-(void)downloadView:(NSRect)statusBarFrame downloadInfo:(NSString*)downloadInfo{
    _viewName = @"dlv";
    [self createDownloadWindow:downloadInfo];
    [self showView:statusBarFrame];
}

-(void)setEnterPermCodeView:(NSRect)statusBarFrame{
    _viewName = @"epc";
    [self createDynamicInputWindow];
    
    //change labels
    [_label setStringValue:@"E N T E R  C U S T O M  C O D E"];
    _inputCode.stringValue = @"";
    
    [self createSubButton];
    [_subButton setAction:@selector(togglePermenantUser)];
    
    [[self window] makeFirstResponder:_inputCode];
    
    [self showView:statusBarFrame];
}

-(void)setEnterRegistrationKeyView:(NSRect)statusBarFrame{
    _viewName = @"erk";
    [self createDynamicInputWindow];
    
    //change labels
    [self createLabel:@"E N T E R  C R E D I T  C O D E"];
    
    [self createSubButton];
    [_subButton setAction:@selector(setCreditCode)];
    
    [[self window] makeFirstResponder:_inputCode];
    
    [self showView:statusBarFrame];
}

#pragma mark - window helpers

-(void)createSubButton{
    int button_width = 55;
    [_subButton setFrame:CGRectMake((_windowWidth/2) - (button_width/2), (_windowHeight/2) - 67, button_width, 30)];
    [_subButton updateTrackingAreas];
    [_subButton setEnabled:true];
    [_subButton setImage:[NSImage imageNamed:@"send.png"]];
    [_subButton setAlternateImage:[NSImage imageNamed:@"send_hover.png"]];
    [_subButton setImageScaling:NSImageScaleProportionallyDown];
    [_subButton setButtonType:NSMomentaryChangeButton];
    [_subButton setBordered:NO];
    [_subButton setHidden:NO];
    [_subButton setUploadFilePath:nil];
    [_subButton updateTrackingAreas];
}

-(void)createLabel:(NSString*)string{
    [_label setStringValue:string];
}

-(void)createWindow{
    NSRect viewFrame = NSMakeRect(0,
                                  0,
                                  _windowWidth,
                                  _windowWidth);
    
    _window = [[KeyWindow alloc] initWithContentRect:viewFrame styleMask:0 backing:NSBackingStoreBuffered defer:YES];
    [_window setIdentifier:@"default"];
    [_window setOpaque:NO];
    [_window setBackgroundColor: [NSColor clearColor]];
    [_window setReleasedWhenClosed: NO];
    [_window setDelegate:(id)self];
    [_window setHasShadow: YES];
    [_window setHidesOnDeactivate:YES];
    [_window setLevel:NSFloatingWindowLevel];
    
    // Create NSview
    _view = nil;
    _view = [_window contentView];
    [_view setWantsLayer:YES];
    _view.layer.backgroundColor = [NSColor clearColor].CGColor;
    
    //add arrow icon
    NSImage *up = [NSImage imageNamed:@"up.png"];
    int up_h = 20;
    _up_arrow = [[NSImageView alloc] initWithFrame:NSMakeRect(_windowWidth/2 - (up_h / 2), 0, up_h, up_h)];
    [_up_arrow setImage:up];
    [_view addSubview:_up_arrow];
    
    //fill background
    NSTextField* bg = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, _windowWidth, _windowHeight-15)]; // -15 for up icon
    bg.backgroundColor = [CustomVars offwhite];
    bg.editable = false;
    bg.bordered = false;
    bg.wantsLayer = true;
    bg.layer.cornerRadius = 10.0f;
    [_view addSubview:bg];
    
    //create hidden pastebutton
    NSButton *pasteButton = [[NSButton alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [pasteButton setKeyEquivalentModifierMask: NSCommandKeyMask];
    [pasteButton setKeyEquivalent:@"v"];
    [pasteButton setAction:@selector(pasteToFriendCode)];
    [_view addSubview:pasteButton];
    
    //create hidden select all button
    NSButton *selectAllButton = [[NSButton alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [selectAllButton setKeyEquivalentModifierMask: NSCommandKeyMask];
    [selectAllButton setKeyEquivalent:@"a"];
    [selectAllButton setAction:@selector(selectFriendCode)];
    [_view addSubview:selectAllButton];
    
    //create hidden enter button
    NSButton *enterButton = [[NSButton alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [enterButton setKeyEquivalent:@"\r"];
    [enterButton setAction:@selector(enter)];
    [_view addSubview:enterButton];
}



//creates template input window to be used by:
// - input of friends code
// - input of reg code
// - input of perm code
-(void)createDynamicInputWindow{
    [self createWindow];
    
    _label = [[NSTextField alloc] initWithFrame:CGRectMake((_windowWidth/2) - (250/2), (_windowHeight/2)+25, 250, 20)];
    _label.backgroundColor = [NSColor clearColor];
    [_label setAlignment:NSTextAlignmentCenter];
    [_label setFont:[NSFont fontWithName:@"Montserrat-Medium" size:13]];
    [_label setTextColor:[CustomVars black]];
    [_label setEditable:false];
    [_label setBordered:false];
    [_view addSubview:_label];
    
    //create editable text field
    _inputCode = [[BorderTextField alloc] initWithFrame:CGRectMake(
                                                               (_windowWidth/2) - (150/2),
                                                               (_windowHeight/2) - (30/2) -10,
                                                               150,
                                                               30)];
    [_inputCode setAlignment:NSTextAlignmentCenter];
    [_inputCode.cell setWraps:NO];
    [_inputCode.cell setScrollable:YES];
    [_inputCode setFont:[NSFont systemFontOfSize:20]];
    [_inputCode setTextColor:[CustomVars black]];
    [_inputCode setFocusRingType:NSFocusRingTypeNone];
    [_inputCode setDelegate:(id)self];
    [_view addSubview:_inputCode];
    
    // create submit button
    _subButton = [[SubmitButton alloc] init];
    [_view addSubview:_subButton];
    
    //file path textfield
    _errorMessage = [[NSTextField alloc] init];
    [_errorMessage setBackgroundColor:[NSColor clearColor]];
    [_errorMessage setAlignment:NSTextAlignmentCenter];
    [_errorMessage setFont:[NSFont fontWithName:@"Montserrat-Regular" size:9]];
    [_errorMessage setTextColor:[CustomVars red]];
    [_errorMessage setEditable:false];
    [_errorMessage setBordered:false];
    [_errorMessage setFrame:CGRectMake(0, 0, _windowWidth, 15)];
    [_view addSubview:_errorMessage];
    
}

-(void)createDownloadWindow:(NSString*)downloadInfo{
    [self createWindow];
    [_window setHidesOnDeactivate:NO]; // prevent user from being able to click off the notification.
    
    //decode json
    NSString* fileName = [[CustomFunctions jsonToVal:downloadInfo key:@"path"] lastPathComponent];
    unsigned long long fs = [CustomFunctions stringToULL:[CustomFunctions jsonToVal:downloadInfo key:@"file-size"]];
    NSString* fileSize = [NSByteCountFormatter stringFromByteCount:fs countStyle:NSByteCountFormatterCountStyleFile];
    
    NSTextField* incomingFile = [[NSTextField alloc] initWithFrame:CGRectMake((_windowWidth/2) - (250/2), (_windowHeight/2)+25, 250, 20)];
    [incomingFile setBackgroundColor:[NSColor clearColor]];
    [incomingFile setAlignment:NSTextAlignmentCenter];
    [incomingFile setFont:[NSFont fontWithName:@"Montserrat-Medium" size:13]];
    [incomingFile setTextColor:[CustomVars black]];
    [incomingFile setEditable:false];
    [incomingFile setBordered:false];
    [incomingFile setStringValue:@"I N C O M I N G  F I L E"];
    [_view addSubview:incomingFile];
    
    NSMutableParagraphStyle *centre = [[NSMutableParagraphStyle alloc] init];
    [centre setAlignment:NSCenterTextAlignment];
    
    // DOWNLOAD PATH BUTTON POP UP
    //get width of text
    NSFont* filePathFont = [NSFont fontWithName:@"Montserrat-Regular" size:15];
    int maxWidthFilePath = [CustomFunctions widthOfString:fileName withFont:filePathFont] + 5;
    if(maxWidthFilePath > _windowWidth){
        maxWidthFilePath = _windowWidth; //make sure not wider than window
        // crop string
        int remove_front = (int)[fileName length] - MAX_FILE_LEN + 3; //amount of charachters to remove from the front of string.
        fileName = [NSString stringWithFormat:@"...%@", [fileName substringWithRange:NSMakeRange(remove_front, [fileName length] - remove_front)]];
    }
    //get x position of text
    int x = (_windowWidth / 2) - (maxWidthFilePath / 2);
    Button* downloadPath = [[Button alloc] initWithFrame:CGRectMake(x, (_windowHeight /2) - 30, maxWidthFilePath, 50)];
    [downloadPath setFocusRingType:NSFocusRingTypeNone];
    [downloadPath setBordered:false];
    // attribute font for delete button
    NSMutableAttributedString *dlAttr = [[NSMutableAttributedString alloc] initWithString:fileName];
    NSRange dlRange = NSMakeRange(0, [dlAttr length]);
    [dlAttr addAttribute:NSParagraphStyleAttributeName value:centre range:dlRange];
    [dlAttr addAttribute:NSForegroundColorAttributeName value:[CustomVars grey] range:dlRange];
    [dlAttr addAttribute:NSFontAttributeName value:filePathFont range:dlRange];
    [dlAttr fixAttributesInRange:dlRange];
    // add attribute
    [downloadPath setAttributedTitle:dlAttr];
    [downloadPath setMessage:fileSize];
    [downloadPath setAction:@selector(popUpMessage:)];
    [downloadPath updateTrackingAreas];
    [_view addSubview:downloadPath];
    
    
    // bottom button variables
    NSFont* btnFont = [NSFont fontWithName:@"Montserrat-Medium" size:13];
    int btn_h = 40;
    
    ///////////////////////////
    // download button
    ///////////////////////////
    Button* downloadBtn = [[Button alloc] initWithFrame:CGRectMake(_windowWidth / 2, 0, _windowWidth / 2, btn_h)];
    [downloadBtn setFocusRingType:NSFocusRingTypeNone];
    [downloadBtn setBordered:false];
    // attribute font for delete button
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"DOWNLOAD"];
    NSRange range = NSMakeRange(0, [attr length]);
    [attr addAttribute:NSParagraphStyleAttributeName value:centre range:range];
    [attr addAttribute:NSForegroundColorAttributeName value:[CustomVars black] range:range];
    [attr addAttribute:NSFontAttributeName value:btnFont range:range];
    [attr fixAttributesInRange:range];
    // add attribute
    [downloadBtn setAttributedTitle:attr];
    [downloadBtn updateTrackingAreas];
    [downloadBtn setMessage:downloadInfo];
    [downloadBtn setAction:@selector(downloadFile:)];
    [_view addSubview:downloadBtn];
    
    ///////////////////////////
    // ignore/delete button
    ///////////////////////////
    Button* deleteBtn = [[Button alloc] initWithFrame:CGRectMake(0, 0, _windowWidth / 2, btn_h)];
    [deleteBtn setFocusRingType:NSFocusRingTypeNone];
    [deleteBtn setBordered:false];
    // attribute font for delete button
    NSMutableAttributedString *deleteAttr = [[NSMutableAttributedString alloc] initWithString:@"IGNORE"];
    NSRange deleteRange = NSMakeRange(0, [deleteAttr length]);
    [deleteAttr addAttribute:NSParagraphStyleAttributeName value:centre range:deleteRange];
    [deleteAttr addAttribute:NSForegroundColorAttributeName value:[CustomVars grey] range:deleteRange];
    [deleteAttr addAttribute:NSFontAttributeName value:btnFont range:deleteRange];
    [deleteAttr fixAttributesInRange:deleteRange];
    // add attribute
    [deleteBtn setAttributedTitle:deleteAttr];
    [deleteBtn updateTrackingAreas];
    [deleteBtn setMessage:downloadInfo];
    [deleteBtn setAction:@selector(ignoreFile:)];
    [_view addSubview:deleteBtn];
    
    
    ///////////////////////////
    // spliter boarders
    ///////////////////////////
    //horizontal border bottom
    NSView *hor_bor_bot = [[NSView alloc] initWithFrame:CGRectMake(0, btn_h, _windowWidth, 1)];
    hor_bor_bot.wantsLayer = TRUE;
    [hor_bor_bot.layer setBackgroundColor:[[CustomVars boarder] CGColor]];
    [_view addSubview:hor_bor_bot];
    
    //vertical button splitter boarder
    NSView *vert_bor_top = [[NSView alloc] initWithFrame:CGRectMake((_windowWidth / 2) -  1, 0, 1, btn_h)];
    vert_bor_top.wantsLayer = TRUE;
    [vert_bor_top.layer setBackgroundColor:[[CustomVars boarder] CGColor]];
    [_view addSubview:vert_bor_top];
}


-(void)positionWindow:(NSRect)statusBarFrame{
    float menu_icon_width = statusBarFrame.size.width;
    float menu_icon_x = statusBarFrame.origin.x;
    float menu_icon_y = statusBarFrame.origin.y;
    
    //calculate positions of window on screen and arrow
    float arrow_x = _windowWidth/2 - (_up_arrow.frame.size.width/2);
    float arrow_y = _windowHeight - _up_arrow.frame.size.height;
    float window_x = (menu_icon_x + menu_icon_width/2) - _windowWidth / 2;
    float window_y = menu_icon_y - _windowHeight;
    
    // update positions
    [_up_arrow setFrame:NSMakeRect(arrow_x, arrow_y, _up_arrow.frame.size.width, _up_arrow.frame.size.height)];
    [_window setFrame:NSMakeRect(window_x, window_y, _windowWidth, _windowHeight) display:true];
    [_view setFrame:CGRectMake(0, 0, _windowWidth, _windowHeight + arrow_y)];
}

-(void)popUpMessage:(Button *)sender {
    NSString* message = sender.message;
    
    //create content of popover
    NSFont* f = [NSFont fontWithName:@"Montserrat-Regular" size:11];
    int width = [CustomFunctions widthOfString:message withFont:f] + 20; // 20 is extra width padding
    NSViewController *viewController = [[NSViewController alloc]init];
    viewController.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    NSTextField* b = [[NSTextField alloc] initWithFrame:CGRectMake(5, -4, width, 30)]; // x & y val to handle strange font centre
    [b setBordered:FALSE];
    [b setEditable:FALSE];
    [b setBackgroundColor:[NSColor clearColor]];
    [b setFont:f];
    [b setStringValue:message];
    [viewController.view addSubview:b];
    
    NSPopover *po = [[NSPopover alloc] init];
    [po setContentSize:viewController.view.frame.size];
    [po setBehavior:NSPopoverBehaviorSemitransient];
    [po setAnimates:YES];
    [po setContentViewController:viewController];
    [po showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge]; //NSMinYEdge = below 
}

// Make sure send to friend view only takes an input of a friend code
NSString* string_before;
- (void)controlTextDidChange:(NSNotification *)notification {
    if([_viewName isEqual: @"stf"] || [_viewName isEqual: @"epc"]){
        NSTextField *textField = [notification object];
        NSString* string = textField.stringValue;
        
        //make upper as typing
        string = [string uppercaseString];
        
        //make sure user is less than userCodeLength
        if([string length] > [CustomVars userCodeLength]){
            string = string_before;
        }else{
            string_before = string;
        }
        
        //make upper after editing or pasting
        [textField setStringValue:[string uppercaseString]];
    }
}

-(void)showView:(NSRect)statusBarFrame{
    [NSApp activateIgnoringOtherApps:YES];
    
    // remove all desktop notifications
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _window.alphaValue = 0;
        _window.animator.alphaValue = 0.0f;
        [self positionWindow:statusBarFrame];
        [_window makeKeyAndOrderFront:_view];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.4;
            _window.animator.alphaValue = 1.0f;
        } completionHandler:nil];
    });
}

#pragma mark - actions
-(void)uploadFile{
    // send message to User class to upload file with params:
    NSString* jsonInfo = [CustomFunctions dicToJsonString:@{
                                       @"path": _subButton.uploadFilePath,
                                       @"friendCode": [CustomFunctions cleanUpString:_inputCode.stringValue]
                                       }];
    [CustomFunctions sendNotificationCenter:jsonInfo name:@"upload-file"];
}

-(void)downloadFile:(Button *)sender{
    _viewName = nil; // allows user to click on MenuBar again.
    NSString* downloadLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"saveLocation"];
    if(downloadLocation == nil){
        // not specified default save location
        downloadLocation = [CustomFunctions choosePathWindow:@"Choose your download location" buttonTitle:@"Save" allowDir:true allowFile:false];
        if(downloadLocation == nil) return;
    }else{
        [self closeWindow];
    }
    
    // send message to User class to download file with params:
    NSString* downloadInfo = sender.message;
    NSString* jsonInfo = [CustomFunctions dicToJsonString:@{
                                                            @"localPath": downloadLocation,
                                                            @"serverPath": [CustomFunctions jsonToVal:downloadInfo key:@"path"],
                                                            @"dlRef": [CustomFunctions jsonToVal:downloadInfo key:@"ref"],
                                                            @"friendUUID": [CustomFunctions jsonToVal:downloadInfo key:@"UUID"]
                                                            }];
    [CustomFunctions sendNotificationCenter:jsonInfo name:@"download-file"];
}

-(void)ignoreFile:(Button *)sender{
    [self closeWindow];
    // get variables
    NSString* downloadInfo = sender.message;
    NSString* friendUUID = [CustomFunctions jsonToVal:downloadInfo key:@"UUID"];
    NSString* path = [CustomFunctions jsonToVal:downloadInfo key:@"path"];
    unsigned long long ref = [CustomFunctions stringToULL:[CustomFunctions jsonToVal:downloadInfo key:@"ref"]];
    
    // end download early (empty file hash)
    [[[Download alloc] initWithKeychain:_keychain menuBar:nil window:self] finishedDownload:path friendUUID:friendUUID downloadRef:ref hash:@""];
    
}

// function is used to both add and remove permenant codes depending on whether the user is using one already
-(void)togglePermenantUser{
    // only will have customCode if setting a custom code. Will be empty when removing code and when creating just a random perm code
    NSString* customCode = [CustomFunctions cleanUpString:_inputCode.stringValue];
    if(!customCode){
        customCode = @"";
    }
    
    NSString* currentPermCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user_code"];
    if(!currentPermCode){
        currentPermCode = @"";
    }
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/togglePermenantUser.php"];
    
    r.POSTDictionary = @{ @"customCode":customCode, @"currentPermCode":currentPermCode, @"UUID":_uuid, @"UUIDKey":[_keychain getKey:@"UUIDKey"]};
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        if([body length] > 0){
            NSString* code = [CustomFunctions jsonToVal:body key:@"perm_user_code"];
            if(code.length > 0){
                [DesktopNotification send:@"Success!" message:[NSString stringWithFormat:@"You now have the permenant code %@", code]];
                [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"perm_user_code"];
                [CustomFunctions sendNotificationCenter:nil name:@"create-user"];
            }else{
                if([[CustomFunctions jsonToVal:body key:@"status"] isEqual: @"removed"]){
                    [DesktopNotification send:@"Removed Your Permenant Code!" message:@"Your code will now change"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"perm_user_code"];
                    [CustomFunctions sendNotificationCenter:nil name:@"create-user"];
                }else{
                    NSLog(@"toggle error: %@", body);
                    [DesktopNotification send:@"Error Setting Permenant Code!" message:body];
                }
            }
        }
    };
    
    r.errorBlock = ^(NSError *error) {
        NSLog(@"Error setting perm user: %@",error);
    };
    
    [r startAsynchronous];
}

-(void)setCreditCode{
    NSString* code = [CustomFunctions cleanUpString:_inputCode.stringValue];
    
    if([code length] != 100){
        [DesktopNotification send:@"Credit Code Invalid!" message:@"The code may already be in use. Make sure codes are case sensitive."];
    }else{
        [self closeWindow];
        
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/regCredit.php"];
        
        r.POSTDictionary = @{ @"UUID":_uuid, @"UUIDKey":[_keychain getKey:@"UUIDKey"], @"pro_code":[CustomFunctions cleanUpString:code]};
        
        r.completionBlock = ^(NSDictionary *headers, NSString *body){
            if ([body  isEqual: @"0"]) {
                [DesktopNotification send:@"Success!" message:@"You have added credit to your account."];
                [CustomFunctions sendNotificationCenter:nil name:@"create-user"];
            }else{
                [DesktopNotification send:@"Credit Code Invalid!" message:@"The code may already be in use. Make sure codes are case sensitive."];
            }
        };
        
        r.errorBlock = ^(NSError *error) {
            NSLog(@"Error registering credit: %@",error);
        };
        
        [r startAsynchronous];
    }
}

-(void)pasteToFriendCode{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    NSString* pasteString = [pasteBoard stringForType:NSPasteboardTypeString];
    _inputCode.stringValue = [pasteString uppercaseString];
}

-(void)selectFriendCode{
    [_inputCode selectText:self];
}

-(void)enter{
    [_subButton performClick:self];
}

-(void)closeWindow{
    _viewName = nil; // allows user to click on MenuBar again after download.
    [_window close];
    [_window orderOut:self];
}

-(void)inputError:(NSString*)message{
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeOutAnimation.duration = 0.3;
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    [_errorMessage.layer addAnimation:fadeOutAnimation forKey:nil];
    
    NSLog(@"error send %@", message);
    _errorMessage.stringValue = message;
    [self shakeLayer:_subButton.layer];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutErrorText) object:@""];
    [self performSelector:@selector(fadeOutErrorText) withObject:@"" afterDelay:4];
}

#pragma mark - animations

-(void)fadeOutErrorText{
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0];
    fadeOutAnimation.duration = 0.4;
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    [_errorMessage.layer addAnimation:fadeOutAnimation forKey:nil];
}

-(void)animatePlane{
    CAMediaTimingFunction*easing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *xAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    [xAnimation setToValue:[NSNumber numberWithFloat:200]];
    [xAnimation setBeginTime:0.0];
    [xAnimation setDuration:0.7];
    xAnimation.timingFunction = easing;
    
    CABasicAnimation *yAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [yAnimation setToValue:[NSNumber numberWithFloat:10]];
    [yAnimation setBeginTime:0.2];
    [yAnimation setDuration:0.7];
    yAnimation.timingFunction = easing;
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotate setToValue:[NSNumber numberWithFloat:(15/180) * M_PI]];
    [rotate setBeginTime:0.3];
    [rotate setDuration:0.7];
    rotate.timingFunction = easing;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:0.7];
    [group setAnimations:[NSArray arrayWithObjects:xAnimation, yAnimation, rotate, nil]];
    
    [_subButton.layer addAnimation:group forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _window.alphaValue = 1.0;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.3;
            _window.animator.alphaValue = 0.0f; // fade window out
        }
        completionHandler:^{
            _window.alphaValue = 1.0f; // reset window opacity
            
            //close window
            [self closeWindow];
        }];
    });
}

-(void)shakeLayer:(CALayer*)layer{
    int repeats = 4;
    float itter_time = 0.04;
    float movement = 5;
    for(int x = 0; x < repeats; x++){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(x*(itter_time*4) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CABasicAnimation *posAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
            [posAnimation setFromValue:[NSNumber numberWithFloat:0]];
            [posAnimation setToValue:[NSNumber numberWithFloat:movement]];
            [posAnimation setBeginTime:0.0];
            [posAnimation setDuration:itter_time];
            
            CABasicAnimation *negAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
            [negAnimation setFromValue:[NSNumber numberWithFloat:movement]];
            [negAnimation setToValue:[NSNumber numberWithFloat:-movement]];
            [negAnimation setBeginTime:itter_time];
            [negAnimation setDuration:itter_time*2];
            
            CABasicAnimation *posAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
            [posAnimation2 setFromValue:[NSNumber numberWithFloat:-movement]];
            [posAnimation2 setToValue:[NSNumber numberWithFloat:0]];
            [posAnimation2 setBeginTime:itter_time*3];
            [posAnimation2 setDuration:itter_time];
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            [group setDuration:itter_time*4];
            [group setAnimations:[NSArray arrayWithObjects:posAnimation, negAnimation, posAnimation2, nil]];
            
            [layer addAnimation:group forKey:nil];
        });
    }
}


@end
