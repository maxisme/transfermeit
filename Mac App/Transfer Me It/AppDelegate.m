//
//  AppDelegate.m
//  Transfer Me It
//
//  Created by Max Mitchell on 10/02/2017.
//  Copyright © 2017 Maximilian Mitchell. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>
#import <MIHCrypto/MIHPublicKey.h>
#import <MIHCrypto/MIHPrivateKey.h>
#import <MIHCrypto/MIHRSAKeyFactory.h>
#import <MIHCrypto/MIHKeyPair.h>

static DDLogLevel ddLogLevel = DDLogLevelVerbose;

#define FILE_PASS_SIZE 128

//-----DRAG AND DROP MENU ICON
@interface StatusItemView : NSView <NSMenuDelegate> {
@private
    NSImage *_image;
    NSStatusItem *_statusItem;
    BOOL _isHighlighted;
    SEL _action;
    id __unsafe_unretained _target;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@property (nonatomic, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *image;
@property (atomic, weak) AppDelegate* thisapp;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;

@end

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;


- (void)setMenu:(NSMenu *)menu {
    [menu setDelegate:self];
    [super setMenu:menu];
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //register for drags
        NSArray *dragTypes = @[NSURLPboardType, NSFileContentsPboardType, NSFilenamesPboardType];
        [self registerForDraggedTypes:dragTypes];
    }
    
    return self;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [self initWithFrame:itemRect];
    
    if (self != nil)
    {
        _statusItem = statusItem;
        _statusItem.view = self;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
    NSImage *icon = self.image;
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    [icon drawAtPoint:iconPoint fromRect:bounds operation:NSCompositeSourceOver fraction:1.0];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [_thisapp.window close];
    NSMenu *menu = [super menu];
    [_statusItem popUpStatusItemMenu:menu];
    [NSApp sendAction:self.action to:self.target from:self];
}


- (void)menuWillOpen:(NSMenu *)menu {
    [self setHighlighted:YES];
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    [self setHighlighted:NO];
    [self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)newImage
{
    _image = newImage;
    [self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if(_thisapp.authedSocket){
        [self setImage:[NSImage imageNamed:@"drag.png"]];
    }
    
    if ([[sender draggingPasteboard] availableTypeFromArray:@[NSFilenamesPboardType]]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    [self setImage:[NSImage imageNamed:@"icon.png"]];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    [self setImage:[NSImage imageNamed:@"icon.png"]];
    
    NSPasteboard *pb = [sender draggingPasteboard];
    if([[pb pasteboardItems] count] != 1){
        return NO;
    }
    
    if(_thisapp.authedSocket){
        NSURL *url = [NSURL URLFromPasteboard:pb];
        _thisapp.uploadFilePath = url.path;
        [_thisapp chooseFriend];
    }
    
    return NO;
}

@end

//-----MyWindow
@interface MyWindow: NSWindow
{
}
- (BOOL) canBecomeKeyWindow;
@end

@implementation MyWindow
- (BOOL) canBecomeKeyWindow
{
    return YES;
}
@end


//-----MyButton

@interface MyButton: NSButton
@property (nonatomic, strong) NSTrackingArea* trackingArea;
@property (nonatomic, strong) NSImage *imageTmp;
@property (strong) NSCursor *cursor;
@end

@implementation MyButton

-(void)mouseEntered:(NSEvent *)theEvent {
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
    [self updateImages];
    self.image = self.alternateImage;
}

-(void)mouseExited:(NSEvent *)theEvent {
    [super resetCursorRects];
    
    self.image = self.imageTmp;
}

- (void)updateImages {
    self.imageTmp = self.image;
}

-(void)updateTrackingAreas
{
    if(self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    
    [self addTrackingArea:self.trackingArea];
}

- (void)resetCursorRects
{
    if (self.cursor) {
        [self addCursorRect:[self bounds] cursor: self.cursor];
    } else {
        [super resetCursorRects];
    }
}
@end


@interface AppDelegate ()
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupLogging];
    
    //used to delete all locally stored data
    //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    
//    MIHRSAKeyFactory *factory = [[MIHRSAKeyFactory alloc] init];
//    factory.preferedKeySize = MIHRSAKey4096;
//    MIHKeyPair *keyPair       = [factory generateKeyPair];
//
//    id<MIHPublicKey> publicKey = keyPair.public;
//    id<MIHPrivateKey> privateKey = keyPair.private;
//
//    NSString* pub_string = [self keyTo64String:publicKey];
//    NSString* priv_string = [self keyTo64String:privateKey];
//
//    NSLog(@"public key: %@", pub_string);
//    NSLog(@"private key: %@", priv_string);
//
//    NSString* encrypted_string = [self encryptWithKey:@"hi" publicKey:[self string64ToKey:pub_string]];
//    NSLog(@"encrypted message: %@", encrypted_string);
//    NSLog(@"private key: %@", [self decryptWithKey:encrypted_string privKey:[self string64ToKey:priv_string]]);
    
    [self onlyOneInstanceOfApp];
    
    //initiate keychain access
    _keychainQuery = [[SAMKeychainQuery alloc] init];
    _keychainQuery.account = @"Transfer Me It";
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hasShownSetup"] == 1) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"hasShownSetup"];
        [self generateKeys];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self enableLoginItemWithURL];
            [self startUpWindow];
            [self showView];
        });
    }
    
    //set colours
    pink = [NSColor colorWithRed:0.973 green:0.482 blue:0.529 alpha:1];
    grey = [NSColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1];
    blue = [NSColor colorWithRed:0.36 green:0.40 blue:0.52 alpha:1];
    offWhite = [NSColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1];
    
    //initiate time_format
    _time_format = [[NSDateFormatter alloc] init];
    [_time_format setDateFormat:@"mm:ss"];
    
    //initiate UUID
    _uuid = [self getSystemUUID];
    
    //default status variables
    _isMonitoring = false;
    _isCreatingUser = false;
    _successfulNewUser = true;
    
    //initiate file locations and decryption keys
    _files = [[NSMutableArray alloc] init];
    
    //get default user time
    _wantedTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"setTime"];
    if(_wantedTime == nil){
        _wantedTime = @"10";
    }
    
    [self createStatusBarItem];
    [self createNewUser];
    
    NSTimer*timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(everySecond) userInfo:nil repeats:YES];
    
    NSRunLoop * rl = [NSRunLoop mainRunLoop];
    [rl addTimer:timer forMode:NSRunLoopCommonModes];
    
    
    //make desktop notifications show even when app is open
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    //notice when window is closed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowClosed) name:NSWindowWillCloseNotification object:self.view.window];
    
    //notice when window stops being key
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:self];
    
    //check for transferme.it update
    [self checkForUpdate:1];
    
//    NSData* file = [NSData dataWithContentsOfFile:[self adDIR:@"Choose the file you want to send!" buttonTitle:@"Choose" dirBool:NO fileBool:YES]];
//    
//    NSLog(@"fsb: %d", (int)[file length]);
//        NSLog(@"EXPECTED FILE SIZE WHEN ENCRYPTED: %d",[self bytesToEncrypted:(int)[file length]]);
//    
//    NSDate *methodStart = [NSDate date];
//    
//    NSData* c_file = [file gzippedDataWithCompressionLevel:1];
//    
//    NSDate *methodFinish = [NSDate date];
//    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
//    NSLog(@"execution of compression = %f", executionTime);
//    
//    NSLog(@"fsa: %d", (int)[c_file length]);
    
//    [self sendToFriendView];
    
    //ENCRYPT A FILE
//    NSData* file = [NSData dataWithContentsOfFile:[self adDIR:@"Choose the file you want to send!" buttonTitle:@"Choose" dirBool:NO fileBool:YES]];
//    NSLog(@"EXPECTED FILE SIZE WHEN ENCRYPTED: %d",[self bytesToEncrypted:(int)[file length]]);
//    
//    NSData* encrypted_data = [self encryptFile:file password:@"7xuSq6FwfxdGemqXhrizbFnbPqwdBK"];
//    NSLog(@"encrypt size %d", (int)[encrypted_data length]);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        // Generate the file path
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"encrypted"];
//        
//        // Save it into file system
//        [encrypted_data writeToFile:dataPath atomically:YES];
//        
//        NSLog(@"decrypt size: %d", (int)[[self decryptFile:encrypted_data password:@"7xuSq6FwfxdGemqXhrizbFnbPqwdBK"] length]);
//    });
    
    //DECRYPT AT PATH
//    NSData* file = [NSData dataWithContentsOfFile:@"/Users/maxmitch/Downloads/testencryptedfile_test.dat"];
//    NSLog(@"decrypt size: %d", (int)[[self decryptFile:file password:@"7xuSq6FwfxdGemqXhrizbFnbPqwdBK"] length]);
    
    //$ mv /Users/maxmitch/Library/Caches/encrypted ~/Documents/transfermeit/transferme.it/testDownload/
//    [self genKeys];
}

-(void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [_window setContentView:_view];           // Hook the view up to the window
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    //[self deleteUser:0];
}

#pragma mark - view

int window_width = 300;
int window_height = 160;

NSColor *pink;
NSColor *grey;
NSColor *blue;
NSColor *offWhite;
bool isDefaultWindow = false;
MyButton* submitButton;
NSImageView *window_up_arrow_view;

-(void)createDefaultWindow{
    if(!isDefaultWindow){
        isDefaultWindow = true;
        NSRect device_frame = [[_statusItem valueForKey:@"window"] frame];
        
        NSRect viewFrame = NSMakeRect(device_frame.origin.x - window_width/2 + device_frame.size.width/2, device_frame.origin.y - window_height, window_width, window_height);
        
        _window = [[MyWindow alloc] initWithContentRect:viewFrame styleMask:0 backing:NSBackingStoreBuffered defer:YES];
        [_window setIdentifier:@"default"];
        [_window setOpaque:NO];
        [_window setBackgroundColor: [NSColor clearColor]];
        [_window setReleasedWhenClosed: NO];
        [_window setDelegate:(id)self];
        [_window setHasShadow: YES];
        [_window setHidesOnDeactivate:YES];
        [_window setLevel:NSFloatingWindowLevel];
        
        // Setup Preference Menu Action/Target on MainMenu
        NSMenu *mm = [NSApp mainMenu];
        NSMenuItem *myBareMetalAppItem = [mm itemAtIndex:0];
        NSMenu *subMenu = [myBareMetalAppItem submenu];
        NSMenuItem *prefMenu = [subMenu itemWithTag:100];
        prefMenu.target = self;
        
        // Create NSview
        _view = [[self window] contentView];
        [_view setWantsLayer:YES];
        _view.layer.backgroundColor = [NSColor clearColor].CGColor;
        
        //add arrow icon
        NSImage *up = [NSImage imageNamed:@"up_b.png"];
        window_up_arrow_view = [[NSImageView alloc] initWithFrame:NSMakeRect(window_width/2 - 10, window_height-20, 20, 20)];
        [window_up_arrow_view setImage:up];
        [_view addSubview:window_up_arrow_view];
        
        //fill background
        NSTextField* bg = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, window_width, window_height-15)]; // -15 for up icon
        bg.backgroundColor = blue;
        bg.editable = false;
        bg.bordered =false;
        bg.wantsLayer = YES;
        bg.layer.cornerRadius = 10.0f;
        [_view addSubview:bg];
        
        //-------------- BODY -----------------
        NSFont* labelFont = [NSFont fontWithName:@"Montserrat" size:13];
        
        _label = [[NSTextField alloc] initWithFrame:CGRectMake((window_width/2) - (250/2), (window_height/2)+25, 250, 20)];
        _label.backgroundColor = [NSColor clearColor];
        [_label setAlignment:NSTextAlignmentCenter];
        [_label setFont:labelFont];
        [_label setTextColor:offWhite];
        _label.editable = false;
        _label.bordered =false;
        [_view addSubview:_label];
        
        //shaddow of _label
        _labelShaddow = [[NSTextField alloc] initWithFrame:CGRectMake(_label.frame.origin.x + 1, _label.frame.origin.y - 1, _label.frame.size.width, _label.frame.size.height)];
        [_labelShaddow setTextColor:pink];
        _labelShaddow.backgroundColor = [NSColor clearColor];
        [_labelShaddow setAlignment:NSTextAlignmentCenter];
        [_labelShaddow setFont:labelFont];
        _labelShaddow.editable = false;
        _labelShaddow.bordered =false;
        [_view addSubview:_labelShaddow positioned:NSWindowBelow relativeTo:_label];
        
        
        //create editable text field
        _inputCode = [[NSTextField alloc] initWithFrame:CGRectMake(
                                                                   (window_width/2) - (150/2),
                                                                   (window_height/2) - (30/2) -10,
                                                                   150,
                                                                   30)];
        [_inputCode setAlignment:NSTextAlignmentCenter];
        _inputCode.editable = true;
        [_inputCode.cell setWraps:NO];
        [_inputCode.cell setScrollable:YES];
        [_inputCode setBackgroundColor:offWhite];
        [_inputCode setFont:[NSFont systemFontOfSize:20]];
        [_inputCode setTextColor:pink];
        [_inputCode setFocusRingType:NSFocusRingTypeNone];
        [_inputCode setDelegate:(id)self];
        [_view addSubview:_inputCode];
        
        
        //create submitbutton
        submitButton = [[MyButton alloc] init];
        [_view addSubview:submitButton];
        
        //file path textfield
        _errorMessage = [[NSTextField alloc] init];
        _errorMessage.backgroundColor = [NSColor clearColor];
        [_errorMessage setAlignment:NSTextAlignmentCenter];
        [_errorMessage setFont:[NSFont fontWithName:@"Montserrat" size:11]];
        [_errorMessage setTextColor:offWhite];
        _errorMessage.editable = false;
        _errorMessage.bordered = false;
        [_errorMessage setFrame:CGRectMake(0, 0, window_width, 20)];
        
        
        //----------- END OF BODY --------------
        
        
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
}

-(NSRect)positionWindow{
    NSRect frame = [[_statusItem valueForKey:@"window"] frame];
    float screen_width = [[NSScreen mainScreen] frame].size.width;
    
    float x = frame.origin.x - window_width/2 + frame.size.width/2;
    float y = frame.origin.y - window_height;
    if(window_width + x > screen_width){
        int padding = 10;
        x = screen_width - window_width - padding;
        [window_up_arrow_view setFrame:NSMakeRect(frame.origin.x + frame.size.width/2 - x - padding,
                                                  window_up_arrow_view.frame.origin.y,
                                                  window_up_arrow_view.frame.size.width,
                                                  window_up_arrow_view.frame.size.height)];
    }else{
        //centre arrow
        [window_up_arrow_view setFrame:NSMakeRect(window_width/2 - 10, window_height-20, 20, 20)];
    }
    return NSMakeRect(x, y, window_width, window_height);
}

//for friend code
NSString* string_before;
- (void)controlTextDidChange:(NSNotification *)notification {
    if(![_label.stringValue  isEqual: @"E N T E R  R E G I S T R A T I O N  K E Y "]){
        NSTextField *textField = [notification object];
        NSString* string = textField.stringValue;
        
        //make upper
        string = [string uppercaseString];
        
        //make sure user is less than userLength (7)
        if([string length] > userLength){
            string = string_before;
        }else{
            string_before = string;
        }
        
        [textField setStringValue:[string uppercaseString]];
    }
}

-(void)startUpWindow{
    NSRect frame = [[_statusItem valueForKey:@"window"] frame];
    
    NSRect contentSize = NSMakeRect(frame.origin.x - 400/2 + frame.size.width/2, frame.origin.y - 250, 400, 250);
    
    _window = [[NSWindow alloc] initWithContentRect:contentSize styleMask:0 backing:NSBackingStoreBuffered defer:YES];
    [_window setOpaque:NO];
    [_window setBackgroundColor: [NSColor clearColor]];
    //_window.title = @"Transfer Me It";
    [_window setReleasedWhenClosed: NO];
    [_window setDelegate:(id)self];
    [_window setHasShadow: YES];
    [_window setLevel:NSFloatingWindowLevel];
    
    
    _view = [[self window] contentView];
    [_view setWantsLayer:YES];
    _view.layer.backgroundColor = [NSColor clearColor].CGColor;
    _view.layer.cornerRadius = 20;
    
    //fill background
    NSTextField* bg = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, window_width, window_height-20)];
    bg.backgroundColor = pink;
    bg.editable = false;
    bg.bordered =false;
    [_view addSubview:bg];
    
    //arrow
    NSImage *up = [NSImage imageNamed:@"up.png"];
    NSImageView *upView = [[NSImageView alloc] initWithFrame:NSMakeRect(window_width/2 - 10, window_height-28, 20, 28)];
    [upView setImage:up];
    [_view addSubview:upView];
    
    //LABELS
    NSTextField* thankyou = [[NSTextField alloc] initWithFrame:CGRectMake(0, window_height -145, window_width, 50)];
    thankyou.backgroundColor = [NSColor clearColor];
    [thankyou setAlignment:NSTextAlignmentCenter];
    [thankyou setFont:[NSFont fontWithName:@"Montserrat" size:12]];
    [thankyou setTextColor:offWhite];
    thankyou.editable = false;
    thankyou.bordered =false;
    [thankyou setStringValue:@"T h a n k   y o u   f o r   d o w n l o a d i n g"];
    [_view addSubview:thankyou];
    
    NSTextField* tmi = [[NSTextField alloc] initWithFrame:CGRectMake(0, window_height -210, window_width, 100)];
    tmi.backgroundColor = [NSColor clearColor];
    [tmi setAlignment:NSTextAlignmentCenter];
    [tmi setFont:[NSFont fontWithName:@"Montserrat" size:25]];
    [tmi setTextColor:offWhite];
    tmi.editable = false;
    tmi.bordered =false;
    [tmi setStringValue:@"T R A N S F E R  M E  I T"];
    [_view addSubview:tmi];
    
    NSTextField* clickIcon = [[NSTextField alloc] initWithFrame:CGRectMake(0, 35, window_width, 100)];
    clickIcon.backgroundColor = [NSColor clearColor];
    [clickIcon setAlignment:NSTextAlignmentCenter];
    [clickIcon setFont:[NSFont fontWithName:@"Montserrat" size:8]];
    [clickIcon setTextColor:grey];
    clickIcon.editable = false;
    clickIcon.bordered =false;
    [clickIcon setStringValue:@"Click the menu bar icon to close!"];
    [_view addSubview:clickIcon];
    
    NSImage *myImage = [NSImage imageNamed:@"mainicon.png"];
    NSImageView *imView = [[NSImageView alloc] initWithFrame:NSMakeRect(window_width/2 - 40, 55, 80, 80)];
    [imView setImage:myImage];
    [_view addSubview:imView];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    if([_window isVisible]){
        [_window orderOut:self];
        [_window close];
    }
}

-(void)showView{
    //create view controller
    [NSApp activateIgnoringOtherApps:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _window.alphaValue = 1.0;
        [_window setFrame:[self positionWindow] display:true];
        [_window makeKeyAndOrderFront:_view];
    });
}

#pragma mark - NSUserNotification

-(void)desktopAlert:(NSString*)title message:(NSString*)message button1:(NSString*)button1 button2:(NSString*)button2{
    [self desktopAlert:title message:message button1:button1 button2:button2 variables:nil];
}

-(void)desktopAlert:(NSString*)title message:(NSString*)message button1:(NSString*)button1 button2:(NSString*)button2 variables:(NSDictionary*)variables{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.userInfo = variables;
    notification.informativeText = message;
    notification.identifier = [NSString stringWithFormat:@"%d", _notificationCount++];
    if(button1.length > 0){
        notification.actionButtonTitle = button1;
    }else{
        [notification setHasActionButton:NO];
    }
    
    if(button2.length > 0){
        notification.otherButtonTitle = button2;
    }else{
        [notification setHasReplyButton:NO];
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    _previousDesktopTitle = title;
}

//action button for NSUserNotification
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification{
    
    //passed variables
    int ref = [notification.userInfo[@"ref"] intValue];
    NSString* friendUUID = notification.userInfo[@"friendUUID"];
    NSString* filePath = notification.userInfo[@"file_path"];
    
    if([notification.title  isEqual: @"File Received"]){
        NSString* downloadLocation = [self saveLocation];
        if(downloadLocation == nil){
            downloadLocation = [self adDIR:@"Choose your download location" buttonTitle:@"Save" dirBool:true fileBool:false];
            if(downloadLocation == nil){
                [self toldNotToDownload:notification];
                [self desktopAlert:@"Canceled Download!"
                           message:@"Your download has been deleted and cancelled." button1:@"" button2:@""];
            }
        }
        
        [self downloadFile:downloadLocation friendUUID:friendUUID ref:ref];
    }else if([notification.title  isEqual: @"File Too Big!"]){
        [self goPro];
    }else if([notification.actionButtonTitle isEqual: @"View"]
             && filePath.length > 0){
        NSArray *fileURLs = [NSArray arrayWithObjects:[NSURL fileURLWithPath:filePath], nil];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
    }
}

//send notification even if app is at front
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    if([notification.title  isEqual: @"File Received"]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           BOOL notificationStillPresent;
           do {
               notificationStillPresent = NO;
               for (NSUserNotification *note in [[NSUserNotificationCenter defaultUserNotificationCenter]deliveredNotifications]) {
                   if ([note.identifier isEqualToString:notification.identifier]){
                       notificationStillPresent = YES;
                   }
               }
               if (notificationStillPresent){
                   [NSThread sleepForTimeInterval:0.20f];
               }
           } while (notificationStillPresent);
           
           dispatch_async(dispatch_get_main_queue(), ^{
               //called when closed
               if(!_isDownloading){
                   [self toldNotToDownload:notification];
               }
           });
       });
    }
}

-(BOOL)toldNotToDownload:(NSUserNotification *)notification{
    int ref = [notification.userInfo[@"ref"] intValue];
    NSString* friendUUID = notification.userInfo[@"friendUUID"];
    NSString* fin = [self finishedDownload:[self getValueFromArray:ref array:_files] friendUUID:friendUUID ref:ref newuser:false];
    if([fin isEqual: @"1"]) return true;
    return false;
}

#pragma mark - stuff

-(unsigned long long)bytesToMega:(unsigned long long)bytes{
    return bytes / 1048576;
}

-(unsigned long long)bytesToEncrypted:(unsigned long long)bytes{
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

int second_count;
bool dnd_was_on = false;
-(void) everySecond{
    second_count++;
    
    if([self dndIsOn]){
        [self setNoInternetMenu];
        _itemOne.title = @"Please turn off 'Do Not Disturb'!";
        dnd_was_on = true;
    }else if(dnd_was_on){
        dnd_was_on = false;
        [self setDefaultMenu];
    }
    
    if(second_count % 2 == 0){
        [self checkSocket];
    }
    
    if(second_count % 15 == 0){
        [self askForRealTime];
    }
    
    if(second_count % 30 == 0){
        [self sendPing];
        
        if(_isUploading || _isDownloading){
            //will send notification to server to keep file for 1 more minute
            [self sendKeepActive];
        }
    }
    
    // update time in icon menu
    if ([_itemSix.title  isEqual: @"Settings..."]) {
        NSDate* deducted_date = [_current_time dateByAddingTimeInterval:-second_count];
        NSString *time_left = [_time_format stringFromDate:deducted_date];
        if([time_left isEqual: @"00:00"]){
            [self askForRealTime];
        }
        if(!_isUploading && !_isDownloading){
            [_itemTwo setTitle:[NSString stringWithFormat:@"Code will reset in - %@",time_left]];
        }
    }
}

-(void)sendKeepActive{
    if(_connectedToSocket && _uuid && _userCode && _downloadingPath){
        [_webSocket send:[self dicToJsonString:[NSDictionary dictionaryWithObjectsAndKeys:
                                @"keep", @"type",
                                _uuid, @"UUID",
                                _userCode, @"userCode",
                                _downloadingPath, @"path",
                            nil]
                         ]
        ];
    }else{
        DDLogError(@"not all params are avaliable for keep alive");
    }
}

-(void)askForRealTime{
    if(_connectedToSocket && _uuid && _userCode){
        [_webSocket send:[self dicToJsonString:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    @"time", @"type",
                                                    _uuid, @"UUID",
                                                    _userCode, @"userCode",
                                                nil]
                         ]
        ];
    }else{
        DDLogError(@"not all params are avaliable for real time");
    }
}

- (BOOL) fileIsPath: (NSString*) path {
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) return !isDir;
    return false;
}

-(void)checkForUpdate:(int)x{
    SUUpdater* suupdater;
    suupdater = [SUUpdater sharedUpdater];
    if(x != 1){
        [suupdater checkForUpdates:self];
    }else{
        [suupdater checkForUpdatesInBackground];
    }
}

- (void)updaterDidNotFindUpdate:(SUUpdater *)update
{
    DDLogVerbose(@"Sparkle: Updater Did Not Find Update");
}

-(BOOL)dndIsOn{ //do not disturb
    NSString* path =  [[NSString stringWithFormat:@"~/Library/Preferences/ByHost/com.apple.notificationcenterui.%@.plist",_uuid] stringByExpandingTildeInPath];
    
    return [[NSDictionary dictionaryWithContentsOfFile:path][@"doNotDisturb"] boolValue];
}

-(void)windowClosed{
    _inputCode.stringValue = @"";
}

-(void)windowDidResignKey:(NSNotification *)note {
    [_window orderOut:self];
    [_window close];
}

-(NSString*)adDIR:(NSString*)title buttonTitle:(NSString*)buttonTitle dirBool:(BOOL)dir fileBool:(BOOL)file
{
    [_itemFive setEnabled:NO];
    [NSApp activateIgnoringOtherApps:YES];
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setLevel:NSFloatingWindowLevel];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:dir];
    [openPanel setCanCreateDirectories:dir];
    [openPanel setCanChooseFiles:file];
    [openPanel setMessage:title];
    [openPanel setPrompt:buttonTitle];
    NSString* fileName;
    if ([openPanel runModal] == NSModalResponseOK)
    {
        for( NSURL* URL in [openPanel URLs] )
        {
            fileName = [URL path];
            return fileName;
        }
    }
    [_itemFive setEnabled:YES];
    return fileName;
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
    [submitButton performClick:self];
}

-(void)copyCode{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString: _userCode forType:NSStringPboardType];
}

- (void)onlyOneInstanceOfApp {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
        DDLogVerbose(@"Instance of app already open");
        [NSApp terminate:self];
    }
}

- (NSString *)getSystemUUID {
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    if (!platformExpert)
        return nil;
    
    CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,CFSTR(kIOPlatformUUIDKey),kCFAllocatorDefault, 0);
    IOObjectRelease(platformExpert);
    if (!serialNumberAsCFString)
        return nil;
    
    return (__bridge NSString *)(serialNumberAsCFString);;
}

-(void)goPro{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://transferme.it/#credit"]];
}

-(NSString*)cleanUpString:(NSString*)unfilteredString{
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@£$%^&*()_+-={}[]:|;\\<>?,.`~"] invertedSet];
    return [[unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
}

#pragma mark - menu bar
StatusItemView *statusItemView;
- (void)createStatusBarItem {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    statusItemView = [[StatusItemView alloc] initWithStatusItem:_statusItem];
    [statusItemView setImage:[NSImage imageNamed:@"loading.png"]];
    [statusItemView setMenu:[self statusBarMenu]];
    statusItemView.thisapp = self;
}

- (NSMenu *)statusBarMenu {
    //create seperators
    _seperator1 = [NSMenuItem separatorItem];
    _seperator2 = [NSMenuItem separatorItem];
    _seperator3 = [NSMenuItem separatorItem];
    _seperator4 = [NSMenuItem separatorItem];
    _seperator5 = [NSMenuItem separatorItem];
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    _itemOne = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemOne];
    
    [menu addItem:_seperator1];
    
    _itemTwo = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemTwo];
    
    [menu addItem:_seperator2];
    
    _itemThree = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemThree];
    
    [menu addItem:_seperator3];
    
    _itemFour = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemFour];
    
    [menu addItem:_seperator4];
    
    _itemFive = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemFive];
    
    [menu addItem:_seperator5];
    
    _itemSix = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemSix];
    
    //permenant menu
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* view_log = [[NSMenuItem alloc] initWithTitle:@"View Log..." action:@selector(showLoggingFile) keyEquivalent:@""];
    [view_log setTarget:self];
    [menu addItem:view_log];
    
    NSMenuItem* quit = [[NSMenuItem alloc] initWithTitle:@"Quit Transfer Me It" action:@selector(quitApp) keyEquivalent:@""];
    [quit setTarget:self];
    [menu addItem:quit];
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    return menu;
}

-(void)killMenu{
    if(_animateTimer){
        [_animateTimer invalidate];
        _animateTimer = nil;
    }
    
    [_seperator1 setHidden:true];
    [_seperator2 setHidden:true];
    [_seperator3 setHidden:true];
    [_seperator4 setHidden:true];
    [_seperator5 setHidden:true];
    
    [_itemOne setHidden:true];
    _itemOne.action = nil;
    [_itemOne setEnabled:false];
    
    [_itemTwo setHidden:true];
    _itemTwo.action = nil;
    [_itemTwo setEnabled:false];
    _itemTwo.keyEquivalent = @"";
    
    [_itemThree setHidden:true];
    _itemThree.action = nil;
    _itemThree.keyEquivalent = @"";
    [_itemThree setEnabled:false];
    
    [_itemFour setHidden:true];
    _itemFour.action = nil;
    [_itemFour setEnabled:false];
    
    [_itemFive setHidden:true];
    _itemFive.action = nil;
    [_itemFive setEnabled:false];
    [_itemFive setSubmenu:nil];
    
    [_itemSix setHidden:true];
    _itemSix.action = nil;
    [_itemSix setEnabled:false];
    [_itemSix setSubmenu:nil];
}

-(void)setDefaultMenu{
    if(_userCode && !_isDownloading && !_isUploading){
        [self killMenu];
        
        [_animateTimer invalidate];
        _animateTimer = nil;
        
        statusItemView.image = [NSImage imageNamed:@"icon.png"];
        
        //handle seperators
        [_seperator4 setHidden:false];
        [_seperator5 setHidden:false];
        
        _itemOne.title = @"Please turn off 'Do Not Disturb'!";
        _itemOne.action = @selector(copyCode);
        [_itemOne setTarget:self];
        
        //get time left
        _itemTwo.title = [NSString stringWithFormat:@"Code will reset in - %@", [_time_format stringFromDate:_current_time]];
        [_itemTwo setTarget:self];
        [_itemTwo setHidden:false];
        
        _itemThree.title = _userCode;
        _itemThree.action = @selector(copyCode);
        _itemThree.keyEquivalent = @"c";
        [_itemThree setHidden:false];
        [_itemThree setTarget:self];
        [_itemThree setEnabled:true];
        
        //_itemFour
        if([self isPhonetic]){
            //small font
            NSFont *systemFont = [NSFont systemFontOfSize:9.0f];
            NSDictionary * fontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:systemFont, NSFontAttributeName, nil];
            NSMutableAttributedString *libTitle = [[NSMutableAttributedString alloc] initWithString:_phoneticUser attributes:fontAttributes];
            [_itemFour setAttributedTitle:libTitle];
            [_itemFour setHidden:false];
            [_itemFour setEnabled:false];
        }
        
        //_itemFive
        //send file
        NSFont *systemFont = [NSFont boldSystemFontOfSize:14.0f];
        NSDictionary * fontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:systemFont, NSFontAttributeName, nil];
        NSMutableAttributedString *libTitle = [[NSMutableAttributedString alloc] initWithString:@"Send File" attributes:fontAttributes];
        
        _itemFive.action = @selector(chooseFile);
        [_itemFive setAttributedTitle:libTitle];
        [_itemFive setHidden:false];
        [_itemFive setTarget:self];
        [_itemFive setEnabled:true];
        
        //_itemSix
        //options menu
        [_itemSix setSubmenu: [self options]];
        _itemSix.title = @"Settings...";
        [_itemSix setHidden:false];
        [_itemSix setEnabled:true];
    }
}

-(void)setdownloadMenu:(int)fileRef{
    [self killMenu];
    [self iconAnimation];
    
    // seperators
    [_seperator2 setHidden:false];
    
    NSString *fileName = [self overflowString:[[self getValueFromArray:fileRef array:_files] lastPathComponent] size:20];
    
    _itemOne.title = [NSString stringWithFormat:@"Downloading: %@", fileName];
    _itemOne.action = nil;
    [_itemOne setHidden:false];
    
    [_itemTwo setHidden:false];
    
    _itemThree.title = @"Cancel Download";
    _itemThree.action = @selector(cancelDownloadUpload);
    [_itemThree setEnabled:true];
    [_itemThree setHidden:false];
}

-(void)setUploadMenu:(NSString*)fileName{
    fileName = [self overflowString:fileName size:20];
    
    [self killMenu];
    [self iconAnimation];
    
    //deal with seperators
    [_seperator2 setHidden:false];
    
    _itemOne.title = [NSString stringWithFormat:@"Uploading: %@", fileName];
    [_itemOne setHidden:false];
    
    _itemTwo.title = @"Compressing File...";
    [_itemTwo setHidden:false];
    
    _itemThree.title = @"Cancel Upload";
    _itemThree.action = @selector(cancelDownloadUpload);
    [_itemThree setEnabled:true];
    [_itemThree setHidden:false];
}

-(void)setNoInternetMenu{
    [self setNoInternetMenu:@"Network Error!"]; //Default error message
}

-(void)setNoInternetMenu:(NSString*)title{
    [self killMenu];
    
    statusItemView.image = [NSImage imageNamed:@"alert.png"];
    _itemOne.title = title;
    [_itemOne setHidden:false];
}

-(void)setRequestingCodeMenu{
    [self killMenu];
    [self iconAnimation];
    
    _itemOne.title = @"Requesting Your Unique Code From Server...";
    [_itemOne setHidden:false];
    _itemTwo.title = @"";
    [_itemTwo setHidden:false];
}

- (NSMenu *)options {
    NSMenu *menu = [[NSMenu alloc] init];
    
    //CODE STUFF
    NSMenuItem* codeItem = [[NSMenuItem alloc] initWithTitle:@"Code" action:nil keyEquivalent:@""];
    [codeItem setEnabled:false];
    [menu addItem:codeItem];
    
    NSMenuItem* phoneticOptionItem = [[NSMenuItem alloc] initWithTitle:@"Show phonetics" action:@selector(showPhonetic) keyEquivalent:@""];
    [phoneticOptionItem setTarget:self];
    if([self isPhonetic]){
        [phoneticOptionItem setState:NSOnState];
    }
    [menu addItem:phoneticOptionItem];
    
    NSMenuItem* createNewCode = [[NSMenuItem alloc] initWithTitle:@"Create a new code for..." action:nil keyEquivalent:@""];
    [createNewCode setSubmenu: [self timeIntervals]];
    [menu addItem:createNewCode];
    
    [menu addItem:[NSMenuItem separatorItem]];
    //DOWNLOAD STUFF
    
    NSMenuItem* saveItem = [[NSMenuItem alloc] initWithTitle:@"Saving Incoming Files" action:nil keyEquivalent:@""];
    [saveItem setEnabled:false];
    [menu addItem:saveItem];
    
    NSMenuItem* saveLocation = [[NSMenuItem alloc] initWithTitle:@"Set a default save location" action:@selector(setSaveLocation) keyEquivalent:@""];
    [saveLocation setTarget:self];
    if([self saveLocation] != nil){
        [saveLocation setState:NSOnState];
    }
    [menu addItem:saveLocation];
    
    NSMenuItem* downloadAutomatically = [[NSMenuItem alloc] initWithTitle:@"Automatically download incoming files" action:@selector(setDownloadAuto) keyEquivalent:@""];
    [downloadAutomatically setTarget:self];
    if([self shouldAutoDownload]){
        [downloadAutomatically setState:NSOnState];
    }
    [menu addItem:downloadAutomatically];
    
    
    //PRO STUFF
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSString*bandwidthLeftStr = [NSByteCountFormatter stringFromByteCount:_bandwidthLeft countStyle:NSByteCountFormatterCountStyleFile];
    
    NSMenuItem* accountType  = [[NSMenuItem alloc] init];
    [accountType setTarget:self];
    [accountType setEnabled:NO];
    [menu addItem:accountType];
    accountType.title = [NSString stringWithFormat:@"Credit | %@ - Upload Bandwidth", bandwidthLeftStr];
    
    NSMenuItem* addCredit = [[NSMenuItem alloc] initWithTitle:@"Purchase Upload Credit" action:@selector(goPro) keyEquivalent:@""];
    [addCredit setTarget:self];
    [menu addItem:addCredit];
    
    NSMenuItem* regKey = [[NSMenuItem alloc] initWithTitle:@"Enter credit key" action:@selector(enterProDetesView) keyEquivalent:@""];
    [regKey setTarget:self];
    [menu addItem:regKey];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    
    _showOnStartupItem = [[NSMenuItem alloc] initWithTitle:@"Start Transfer Me It at login" action:@selector(openOnStartup) keyEquivalent:@""];
    [_showOnStartupItem setTarget:self];
    
    if([self loginItemExistsWithLoginItemReference]){
        [_showOnStartupItem setState:NSOnState];
    }else{
        [_showOnStartupItem setState:NSOffState];
    }
    [menu addItem:_showOnStartupItem];
    
    NSMenuItem* update = [[NSMenuItem alloc] initWithTitle:@"Check for updates..." action:@selector(checkForUpdate:) keyEquivalent:@""];
    [update setTarget:self];
    [menu addItem:update];
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    return menu;
}

#pragma mark - auto download

-(void)setDownloadAuto{
    if([self shouldAutoDownload]){
        //remove autodownload option
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"autoDownload"];
    }else{
        if([self saveLocation] == NULL){
            [self setSaveLocation];
        }
        
        //check again incase user pressed cancel on choosing location
        if([self saveLocation] != NULL){
            //set auto download
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"autoDownload"];
        }
    }
    
    [self setDefaultMenu];
}

-(BOOL)shouldAutoDownload{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"autoDownload"];
}

#pragma mark - saved location

-(void)setSaveLocation{
    if([self saveLocation] != NULL){
        //remove save location
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"saveLocation"];
        if([self shouldAutoDownload]){
            [self setDownloadAuto];
        }
    }else{
        //set save location
        NSString* path = [self adDIR:@"Choose where you would like your files to automatically be saved" buttonTitle:@"Select" dirBool:true fileBool:false];
        [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"saveLocation"];
    }
    
    [self setDefaultMenu];
}

-(NSString*)saveLocation{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveLocation"];
}

- (NSMenu *)timeIntervals {
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSMutableArray *myIntegers = [NSMutableArray array];
    
    //array numbers
    [myIntegers addObject:@"5"];
    [myIntegers addObject:@"10"];
    if([_maxTime intValue] > 10){
        [myIntegers addObject:@"15"];
        if([_maxTime intValue] > 15){
            [myIntegers addObject:@"20"];
            if([_maxTime intValue] > 20){
                [myIntegers addObject:@"30"];
                if([_maxTime intValue] > 30){
                    [myIntegers addObject:@"45"];
                    if([_maxTime intValue] > 45){
                        [myIntegers addObject:@"60"];
                    }
                }
            }
        }
    }
    
    for (NSNumber *n in myIntegers) {
        int x = [n intValue];
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%d Minutes",x] action:@selector(setTime:) keyEquivalent:@""];
        [item setRepresentedObject:n];
        [item setTarget:self];
        
        //tick if selected
        if(x == [_wantedTime intValue]){
            [item setState:NSOnState];
        }
        
        [menu addItem:item];
    }
    
    if(_userTier > 1){
        [menu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem* permUserItem = [[NSMenuItem alloc] initWithTitle:@"Ever" action:@selector(setPerm) keyEquivalent:@""];
        [permUserItem setTarget:self];
        if([self hasPermUser]){
            [permUserItem setState:NSOnState];
        }
        [menu addItem:permUserItem];
    }
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    return menu;
}

-(void)setTime:(NSMenuItem*)sender{
    _wantedTime = sender.representedObject;
    [self createNewUser];
}

#pragma mark - create user
-(void)createNewUser{
    if (!_isCreatingUser && !(!_authedSocket && _connectedToSocket)) {
        _isCreatingUser = true;
        _userCode = nil;
        
        DDLogVerbose(@"creating a new user");
        
        if(_successfulNewUser){
            [self setRequestingCodeMenu];
        }
        
        NSString* permUser = @"";
        if([self hasPermUser]){
            permUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user"];
        }
        
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/addNewUser.php"];
        r.timeoutSeconds = 3;
        
        r.POSTDictionary = @{ @"UUID":_uuid, @"UUIDKey": [self getKey:@"UUIDKey"], @"mins":[self cleanUpString:_wantedTime], @"perm_user":permUser, @"pub_key": [self getKey:@"publicKey"]};
        
        r.completionBlock = ^(NSDictionary *headers, NSString *body) {
            NSString* user_code = [self jsonToVal:body key:@"user_code"];
            if(![user_code isEqual: @""]){
                _successfulNewUser = true;
                [self closeSocket];
                
                NSString* UUIDkey = [self jsonToVal:body key:@"UUID_key"];
                if([UUIDkey length] == 100){
                    //receiving the key
                    if(![self storeKey:@"UUIDKey" withPassword:UUIDkey]){
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert setMessageText:@"Major Key Error"];
                        [alert setInformativeText:@"Problem storing key in keychain. Please contact hello@transferme.it"];
                        [alert addButtonWithTitle:@"Okay"];
                        [alert runModal];
                    }
                }
                
                _userCode       = user_code;
                _phoneticUser   = [self stringToPhonetic:_userCode];
                _bandwidthLeft  = [[self jsonToVal:body key:@"bandwidth_left"] integerValue] / 8; //bits
                _maxTime        = [self jsonToVal:body key:@"mins_allowed"];
                _userTier       = [[self jsonToVal:body key:@"user_tier"] intValue];
                
                [[NSUserDefaults standardUserDefaults] setObject:_wantedTime forKey:@"setTime"];
                
                [self openSocket];
            }else{
                NSString* status = [self jsonToVal:body key:@"status"];
                if([status isEqual: @"brute"]){
                    //made too many new user requests return old data
                    [self setDefaultMenu];
                }else if([status isEqual: @"socket_down"]){
                    _successfulNewUser = false;
                    [self setNoInternetMenu:@"Server Socket Down!"];
                    DDLogError(@"socket down");
                }else{
                    [self desktopAlert:@"Error creating user!" message:status button1:@"" button2:@""];
                }
            }
            
            _isCreatingUser = false;
        };
        
        r.errorBlock = ^(NSError *error) {
            DDLogError(@"USER ERROR: %@",[error localizedDescription]);
            _successfulNewUser = false;
            _isCreatingUser = false;
            [self setNoInternetMenu];
            _userCode = false;
        };
        
        [r startAsynchronous];
    }
}

-(BOOL)storeKey:(NSString*)service withPassword:(NSString*)pass{
    NSError* error = nil;
    
    _keychainQuery.service = service;
    [_keychainQuery setPassword:pass];
    [_keychainQuery save:&error];
    
    if(!error) return TRUE;
    DDLogError(@"KEYCHAIN ERROR: %@", error);
    return FALSE;
}

-(NSString*)getKey:(NSString*)service{
    NSError* error;
    
    _keychainQuery.service = service;
    [_keychainQuery fetch:&error];
    
    if(error){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error fetching your Key!"];
        [alert setInformativeText:[NSString stringWithFormat:@"There was an error fetching your key. Please contact hello@notifi.it.\r %@",error]];
        [alert addButtonWithTitle:@"Ok"];
        return @" ";
    }
    
    return [_keychainQuery password];
}

#pragma mark - socket

//message from socket
-(void)receivedMessage:(NSString*)json{
    NSString* type = [self jsonToVal:json key:@"type"];
    
    if([type  isEqual: @"download"]){
        NSString* path = [self jsonToVal:json key:@"path"];
        NSString* friendUUID = [self jsonToVal:json key:@"UUID"];
        NSString* ref = [self jsonToVal:json key:@"ref"];
        
        [self storeValueInArray:_files val:path ref:[ref intValue]];
        
        if([self shouldAutoDownload]){
            [self downloadFile:[self saveLocation] friendUUID:friendUUID ref:[ref intValue]];
        }else{
            [self desktopAlert:@"File Received"
                       message:[NSString stringWithFormat:@"Would you like to download: %@?",[path lastPathComponent]]
                       button1:@"Yes"
                       button2:@"No"
                     variables:@{@"ref":ref, @"friendUUID":friendUUID}];
        }
        
        _hasRequestedDownload = true;
    }else if([type  isEqual: @"time"]){
        NSString* time = [self jsonToVal:json key:@"time"];
        
        if([time  isEqual: @"-"]){
            [self createNewUser];
        }else{
            _current_time = [_time_format dateFromString:time];
            second_count = 0;
        }
        
        if(!_authedSocket){
            _authedSocket = true;
            [self setDefaultMenu];
        }
    }else if([type isEqual: @"downloaded"]){
        NSString* message = [self jsonToVal:json key:@"title"];
        NSString* path = [self jsonToVal:json key:@"message"];
        
        //Your friend succesfully downloaded the file!
        [self desktopAlert:message
                   message:[NSString stringWithFormat:@"%@",[path lastPathComponent]]
                   button1:@""
                   button2:@""];
    }else if(![type isEqual: @"Error"]){ //don't need to alert user of this
        NSString* message = [self jsonToVal:json key:@"message"];
        DDLogError(@"incoming socket error: %@",message);
    }
}

//check whether time has changed
-(void)checkTimeChange{
    //current time
    NSString* currentTime = _itemThree.title;
    if ([_itemFive.title  isEqual: @"Settings..."]) {
        //correct menu
        if (currentTime == _theTime5) {
            DDLogError(@"ERROR:time hasn't changed in 5 seconds!!");
            [self createNewUser];
        }
    }
}


#pragma mark - download new file
-(void)downloadFile:(NSString*)savedPath friendUUID:(NSString*)friendUUID ref:(int)ref{
    if(!_isDownloading){
        _isDownloading = true;
        [self createNewUser];
        [self setdownloadMenu:ref];
        NSString* downloadPath = [self getValueFromArray:ref array:_files];
        
        _downloadReq = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/download.php"];
        _downloadReq.POSTDictionary = @{ @"UUID":_uuid, @"UUIDKey":[self getKey:@"UUIDKey"], @"path":downloadPath};
        
        _downloadingPath = downloadPath; //used for keep alive
        _downloadReq.completionDataBlock = ^(NSDictionary *headers, NSData *downloadedData) {
            if([downloadedData length] > 1){
                [_itemTwo setTitle:@"Decrypting File..."];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString* downloadedError = nil;
                    
                    //fetch encrypted string of friend which has password of file
                    NSString* fileHash = [self hash:downloadedData];
                    NSString* encrypted_pass = [self finishedDownload:downloadPath friendUUID:friendUUID ref:ref newuser:true hash:fileHash];
                    
                    if ([downloadedData length] > 0 && [encrypted_pass length] > 10) { // 10 is arbiturary
                        //fetch my private key
                        id<MIHPrivateKey> privateKey = [self string64ToKey:[self getKey:@"privateKey"]];
                        NSString* pass = [self decryptWithKey:encrypted_pass privKey:privateKey]; //decrypt password encrypted with your public key by friend
                        
                        if(![pass isEqual: @""]){
                            NSData* file = [self decryptFile:downloadedData password:pass];
                            
                            if([file isGzippedData]){
                                //uncompress file
                                file = [file gunzippedData];
                            }
                            
                            if(file != nil){
                                NSString* destinationPath = [NSString stringWithFormat:@"%@/%@", savedPath, [downloadPath lastPathComponent]];
                                
                                //rename if file already at path.
                                int x = 0;
                                NSString* ext = [destinationPath pathExtension];
                                NSString* filepath = [destinationPath stringByDeletingPathExtension];
                                while ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]){
                                    x++;
                                    if(![ext isEqual: @""]){
                                        destinationPath = [NSString stringWithFormat:@"%@ (%d).%@", filepath, x, ext];
                                    }else{
                                        destinationPath = [NSString stringWithFormat:@"%@ (%d)", filepath, x];
                                    }
                                }
                                
                                [file writeToFile:destinationPath atomically:YES];
                                
                                [self desktopAlert:@"Successful download!" message:@"The file has been downloaded and decrypted." button1:@"Show" button2:@"Close" variables:@{@"file_path":destinationPath}];
                            }else{
                                downloadedError = @"Unable to decrypt file";
                            }
                        }else{
                            downloadedError = @"Unable to decrypt encrypted string.";
                            DDLogError(@"encrypted_pass: %@", encrypted_pass);
                        }
                    }else{
                        downloadedError = @"Downloaded file is not as it should be.";
                    }
                    
                    if(downloadedError.length > 0){
                        [self desktopAlert:@"Error Downloading File!" message:downloadedError button1:@"" button2:@"Close"];
                        DDLogError(@"Download Error: %@",downloadedError);
                    }
                    
                    _isDownloading = false;
                    [self createNewUser];
                });
            }else{
                [self desktopAlert:@"Error Downloading File!" message:[[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding] button1:@"" button2:@"Close"];
            }
        };
        
        _downloadReq.errorBlock = ^(NSError *error) {
            NSString* error_message = [error localizedDescription] ;
            if(![error_message isEqual: @"Connection was cancelled."]){
                [self finishedDownload:downloadPath friendUUID:friendUUID ref:ref newuser:true];
                [self desktopAlert:@"Network error while Downloading!" message:@"Please check your network and ask user to upload again." button1:@"" button2:@"Close"];
            }
            
            [self createNewUser];
        };
        
        _downloadReq.downloadProgressBlock = ^(NSData *data, int64_t totalBytesReceived, int64_t totalBytesExpectedToReceive) {
            unsigned long long totalBytes = totalBytesExpectedToReceive;
            float downloadPercent = ([@(totalBytesReceived) floatValue] / [@(totalBytesExpectedToReceive) floatValue]) * 100;
            _itemTwo.title = [NSString stringWithFormat:@"%.1f%% of %@", downloadPercent, [NSByteCountFormatter stringFromByteCount:totalBytes countStyle:NSByteCountFormatterCountStyleFile]];
        };
        
        [_downloadReq startAsynchronous];
    }else{
        DDLogError(@"Already downloading!");
    }
}

-(id)getValueFromArray:(int)x array:(NSMutableArray*)array{
    NSString* val = @"";
    for(NSString* str in array){
        NSArray *explode = [str componentsSeparatedByString:@"|"];
        if(explode.count > 0 && [explode[1] intValue] == x){
            val = explode[0];
        }
    }
    
    return val;
}

-(void)storeValueInArray:(id)array val:(NSString*)val ref:(int)ref{
    [array insertObject:[NSString stringWithFormat:@"%@|%d", val, ref] atIndex:0];
}

-(NSString*)finishedDownload:(NSString*)path friendUUID:(NSString*)friendUUID ref:(int)ref newuser:(bool)newuser{
    return [self finishedDownload:path friendUUID:friendUUID ref:ref newuser:newuser hash:@""];
}

//returns key if it isn't a failed download | returns 1 if failed but deleted succesfully
-(NSString*)finishedDownload:(NSString*)path friendUUID:(NSString*)friendUUID ref:(int)ref newuser:(bool)newuser hash:(NSString*)hash{
    _downloadingPath = nil;
    _hasRequestedDownload = false;
    [_files removeObject:[self getValueFromArray:ref array:_files]];
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/finishedDownload.php"];
    r.POSTDictionary = @{ @"path":path, @"friendUUID": friendUUID, @"UUID":_uuid, @"UUIDKey":[self getKey:@"UUIDKey"], @"hash":hash, @"ref":[NSString stringWithFormat:@"%d",ref]};
    
    NSError *error = nil;
    NSString *body = [r startSynchronousWithError:&error];
    
    if(error != nil){
        DDLogError(@"Error finishing download: %@",[error localizedDescription]);
        [self desktopAlert:@"E R R O R" message:@"Unable to delete file from server. It will be deleted within the hour." button1:@"" button2:@"Close"];
        return @"";
    }
    
    return body;
}

#pragma mark - upload/send file

-(void)chooseFile{
    _uploadFilePath = [self adDIR:@"Choose the file you want to send!" buttonTitle:@"Choose" dirBool:NO fileBool:YES];
    if(_uploadFilePath){
        [self chooseFriend];
    }
}

-(void)chooseFriend{
    [self sendToFriendView];
    _inputCode.stringValue = @"";
    [self showView];
}

int userLength = 7;
-(void)uploadFile{
    [submitButton setEnabled:false];
    NSString* path = _uploadFilePath; //used
    
    NSData* file = [NSData dataWithContentsOfFile:path];
    NSString* file_name = [path lastPathComponent];
    
    unsigned long fileSize = (unsigned long long)[file length];
    
    if(fileSize > 0){
        NSString* friendCode = [self cleanUpString:[_inputCode stringValue]];
        unsigned long encryptedFileSize = [self bytesToEncrypted:fileSize];
        
        if ([friendCode length] == 0) {
            [self sendError:@"You must enter your friends code!"];
        }else if ([friendCode length] != userLength) {
            [self sendError:@"Your friend does not exist!"];
        }else if(_userCode == friendCode){
            [self sendError:@"You can't send files to yourself..."];
        }else if(![self fileIsPath:path]){
            //TODO zip if not already.
            [self sendError:@"You must Compress/zip folders!"];
        }else if(!_isUploading){
            STHTTPRequest* r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/initUpload.php"];
            
            r.POSTDictionary = @{ @"user":_userCode, @"friend":friendCode, @"UUID":_uuid, @"UUIDKey":[self getKey:@"UUIDKey"], @"filesize":[NSString stringWithFormat:@"%lu", encryptedFileSize]};
            
            NSError *error = nil;
            NSString *body = [r startSynchronousWithError:&error];
            NSString* key = [self jsonToVal:body key:@"pub_key"]; // friends public key
            
            if(![key isEqual: @""]){
                //generate a password to encrypt the file with
                NSString* pass = [self randomString:FILE_PASS_SIZE];
                
                _isUploading = true;
                
                [self setUploadMenu:file_name];
                [self animatePlane];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSDate *methodStart = [NSDate date]; // start log compression time
                    
                    // attempt to compress file
                    NSData* compressedFile = [file gzippedDataWithCompressionLevel:0.7];
                    NSData* fileToEncrypt = nil;
                    if([compressedFile length] < fileSize){
                        //compression made the file smaller
                        fileToEncrypt = compressedFile;
                    }else{
                        fileToEncrypt = file;
                    }
                    
                    //print compression time
                    DDLogVerbose(@"original size %lu, compressed size %lu", fileSize, (unsigned long)[compressedFile length]);
                    NSDate *methodFinish = [NSDate date];
                    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
                    DDLogVerbose(@"Compression took %f", executionTime);
                    
                    //encrypt the password with friends public key
                    id<MIHPublicKey> friendKey = [self string64ToKey:key];
                    NSString* encrypted_pass = [self encryptWithKey:pass publicKey:friendKey];
                    NSLog(@"encrypted pass:%@", encrypted_pass);
                    //ENCRYPT THE FILE
                    _itemTwo.title = @"Encrypting File...";
                    NSData* encryptedFile = [self encryptFile:fileToEncrypt password:pass];
                    
                    //UPLOAD FILE
                    _uploadReq = nil;
                    _uploadReq = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/upload.php"];
                    _uploadReq.POSTDictionary = @{ @"user":_userCode, @"friend":friendCode, @"UUID":_uuid, @"UUIDKey":[self getKey:@"UUIDKey"], @"pass": encrypted_pass};
                    [_uploadReq addDataToUpload:encryptedFile parameterName:@"fileUpload" mimeType:@"application/octet-stream" fileName:[path lastPathComponent]];
                    
                    _uploadReq.completionBlock = ^(NSDictionary *headers, NSString *body) {
                        _isUploading = false;
                        if(![body  isEqual: @"1"]){
                            NSString* err_message = [NSString stringWithFormat:@"Error code: %@. Contact hello@transferme.it",body];
                            [self desktopAlert:@"Major Error Uploading!" message:err_message button1:@"" button2:@""];
                            DDLogError(@"Upload Error (1):%@",err_message);
                        }
                        
                        [self setDefaultMenu];
                    };
                    
                    _uploadReq.errorBlock = ^(NSError *error) {
                        _isUploading = false;
                        if ([[error localizedDescription] rangeOfString:@"cancelled"].location == NSNotFound) {
                            DDLogError(@"Upload Error (2): %@",[error localizedDescription]);
                            [self desktopAlert:@"Network error while uploading!" message:@"Please check your network and try uploading again." button1:@"" button2:@"Close"];
                            
                            [self setDefaultMenu];
                        }
                    };
                    
                    _uploadReq.uploadProgressBlock = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
                        float uploadPercent = ([@(totalBytesWritten) floatValue] / [@(totalBytesExpectedToWrite) floatValue]) * 100;
                        unsigned long long  totalUploadBytes = (int)totalBytesExpectedToWrite;
                        _itemTwo.title = [NSString stringWithFormat:@"%.1f%% of %@", uploadPercent, [NSByteCountFormatter stringFromByteCount:totalUploadBytes countStyle:NSByteCountFormatterCountStyleFile]];
                    };
                    
                    
                    [_uploadReq startAsynchronous];
                });
            }else{
                
                if ([body rangeOfString:@"upload limit"].location != NSNotFound) {
                    [self desktopAlert:@"File Upload Too Big!" message:@"Would you like to purchase some upload credit?" button1:@"Yes" button2:@"No"];
                }else{
                    [self sendError:body];
                }
            }
        }
    }else{
        [self sendError:@"Please compress/zip folders!"];
    }
}

-(void)cancelDownloadUpload{
    if (_downloadReq) {
        DDLogVerbose(@"canceled download");
        [_downloadReq cancel];
        _downloadReq = nil;
        _isDownloading = false;
    }
    
    if (_uploadReq) {
        DDLogVerbose(@"canceled upload");
        [_uploadReq cancel];
        _uploadReq = nil;
        _isUploading = false;
    }
    
    [self createNewUser];
}

int view_change_height = 10;
-(void)sendError:(NSString*)message{
    [submitButton setEnabled:true];
    
//    int height = _view.frame.size.height;
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        context.duration = 1;
//        [_view setFrame:NSMakeRect(_view.frame.origin.x, _view.frame.origin.y, _view.frame.size.width, height)];
//    } completionHandler:^{
//        [_view setFrame:NSMakeRect(_view.frame.origin.x, _view.frame.origin.y, _view.frame.size.width, height - view_change_height)];
//    }];
    
    //return to normal opacity
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeOutAnimation.duration = 0.3;
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    [_errorMessage.layer addAnimation:fadeOutAnimation forKey:nil];
    
    _errorMessage.stringValue = message;
    [self shakeLayer:submitButton.layer];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutErrorText) object:@""];
    [self performSelector:@selector(fadeOutErrorText) withObject:@"" afterDelay:4];
}

-(void)fadeOutErrorText{
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0];
    fadeOutAnimation.duration = 0.4;
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    [_errorMessage.layer addAnimation:fadeOutAnimation forKey:nil];
    //_errorMessage.stringValue = @"";
}

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

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
    [rotate setToValue:[NSNumber numberWithFloat:DEGREES_RADIANS(15)]];
    [rotate setBeginTime:0.3];
    [rotate setDuration:0.7];
    rotate.timingFunction = easing;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:0.7];
    [group setAnimations:[NSArray arrayWithObjects:xAnimation, yAnimation, rotate, nil]];
    
    [submitButton.layer addAnimation:group forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //fade in
        _window.alphaValue = 1.0;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.3;
            _window.animator.alphaValue = 0.0f;
        }
        completionHandler:^{
            _window.alphaValue = 0.0f;
            
            //close window
            [_window orderOut:self];
            [_window close];
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

//Called when there has been an error downloading the file or the user does not want the file.
-(bool)deleteFileFromServer:(NSString*)friendCode userCode:(NSString*)userCode path:(NSString*)path{
    if(_userCode){
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/deleteFile.php"];
        r.POSTDictionary = @{ @"path":path, @"user":userCode, @"friend": friendCode, @"UUID":_uuid, @"UUIDKey":[self getKey:@"UUIDKey"]};
        
        NSError *error = nil;
        NSString *body = [r startSynchronousWithError:&error];
        
        if(error != nil){
            DDLogError(@"Failed to delete file from server (1): %@", [error localizedDescription]);
            [self desktopAlert:@"E R R O R" message:@"Unable to delete file from server. It will be deleted within the hour anyway." button1:@"" button2:@"Close"];
        }else{
            NSString* firstLetter = [body substringToIndex:1];
            body = [body substringFromIndex:1];
            if([firstLetter isEqual: @"0"]){
                return true;
            }else{
                DDLogError(@"Failed to delete file from server (2): %@",body);
            }
        }
    }
    return false;
}

#pragma mark - encrypt/decrypt file
-(NSData*)encryptFile:(NSData*)data password:(NSString*)password{
    NSError *error = nil;
    NSData *encrypted_data = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:&error];
    if (error != nil) {
        DDLogError(@"RNEncryptor error:%@", error);
        return nil;
    }else{
        return encrypted_data;
    }
}

-(NSData*)decryptFile:(NSData*)data password:(NSString*)password{
    NSError *error = nil;
    NSData *decrypted_data = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:password error:&error];
    if (error != nil) {
        DDLogError(@"Decryption ERROR:%@", error);
        return nil;
    }else{
        return decrypted_data;
    }
}

#pragma mark - Send to friend code
-(void)sendToFriendView{
    [self createDefaultWindow];
    
    //change labels
    [_label setStringValue:@"E N T E R  F R I E N D S  C O D E"];
    [_labelShaddow setStringValue:_label.stringValue];
    
    int button_width = 50;
    [submitButton setFrame:CGRectMake((window_width/2) - (button_width/2), (window_height/2)-65, button_width, 30)];
    [submitButton updateTrackingAreas];
    [submitButton setEnabled:true];
    [submitButton setAction:@selector(uploadFile)];
    [submitButton setImage:[NSImage imageNamed:@"send.png"]];
    submitButton.alternateImage = [NSImage imageNamed:@"send_hover.png"];
    [submitButton setImageScaling:NSImageScaleProportionallyDown];
    [submitButton setButtonType:NSMomentaryChangeButton];
    [submitButton setBordered:NO];
    
    _inputCode.stringValue = @"";
    
    [_view addSubview:_errorMessage];
    
    [self showView];
}

#pragma mark - Choose custom code
-(void)enterPermCodeView{
    [self createDefaultWindow];
    
    //change labels
    [_label setStringValue:@"E N T E R  C U S T O M  C O D E"];
    [_labelShaddow setStringValue:_label.stringValue];
    [submitButton setTitle:@"Submit"];
    [submitButton setAction:@selector(setPermCode:)];
    _inputCode.stringValue = @"";
    
    [self showView];
}

-(void)setPerm{
    _inputCode.stringValue = @"";
    
    if(![self hasPermUser]){
        //stop being static
        if(_userTier == 3){
            [self enterPermCodeView];
        }else{
            [self setPermCode:true];
        }
    }else{
        [self setPermCode:false];
    }
}

-(void)setPermCode:(bool)setPerm{
    _settingPermUser = true;
    [self setRequestingCodeMenu];
    
    NSString* customCode = @""; //user wants to remove perm code when customCode is empty
    if(setPerm || [_inputCode.stringValue length] > 0){
        if([_inputCode.stringValue length] > 0){
            customCode = [self cleanUpString:_inputCode.stringValue];
        }
        [_window close];
    }
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/setPermenantUser.php"];
    
    r.POSTDictionary = @{ @"customCode":customCode, @"UUID":_uuid, @"UUIDKey":[self getKey:@"UUIDKey"]};
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        _settingPermUser = false;
        
        if([body length] > 0){
            NSString* code = [self jsonToVal:body key:@"code"];
            if(code.length > 0){
                [self desktopAlert:@"Success!" message:[NSString stringWithFormat:@"You now have the permenant code %@", code] button1:@"" button2:@""];
                [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"perm_user"];
            }
            
            NSString* status = [self jsonToVal:body key:@"status"];
            if([status  isEqual: @"0"]){
                [self desktopAlert:@"Removed permenant code!" message:@"Your code will now change" button1:@"" button2:@""];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"perm_user"];
            }else{
                [self desktopAlert:@"Error!" message:status button1:@"" button2:@""];
            }
            
            [self createNewUser];
        }
    };
    
    r.errorBlock = ^(NSError *error) {
        _settingPermUser = false;
        DDLogError(@"Error setting perm user: %@",error);
    };
    
    [r startAsynchronous];
}

-(bool)hasPermUser{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user"] != nil){
        return true;
    }else{
        return false;
    }
}


#pragma mark - Enter Pro code
-(void)enterProDetesView{
    [self createDefaultWindow];
    
    //change labels
    [_label setStringValue:@"E N T E R  R E G I S T R A T I O N  K E Y "];
    [_labelShaddow setStringValue:_label.stringValue];
    
    [submitButton setAction:@selector(checkPro)];
    _inputCode.stringValue = @"";
    
    [self showView];
}

-(void)checkPro{
    NSString* proCode = [_inputCode.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([proCode length] != 100){
        [self desktopAlert:@"Registration Key Invalid!" message:@"Make sure codes are case sensitive." button1:@"" button2:@"Close"];
    }else if(!_isGettingRegistrationCode){
        [_window close];
        
        _isGettingRegistrationCode = true;
        
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/regCredit.php"];
        
        r.POSTDictionary = @{ @"UUID":_uuid, @"UUIDKey":[self getKey:@"UUIDKey"], @"code":[self cleanUpString:proCode] };
        
        r.completionBlock = ^(NSDictionary *headers, NSString *body) {
            _isGettingRegistrationCode = false;
            if ([body  isEqual: @"0"]) {
                [self desktopAlert:@"Success!" message:@"You now have a pro account" button1:@"" button2:@"Close"];
                
                [self createNewUser];
            }else if ([body  isEqual: @"2"]) {
                [self desktopAlert:@"Registration Key does not exist!" message:@"Make sure codes are case sensitive." button1:@"" button2:@"Close"];
            }else{
                DDLogError(@"key body: %@",body);
                [self desktopAlert:@"Incorrect key!" message:@"This key has either already been used or is incorrect." button1:@"" button2:@"Close"];
            }
        };
        
        r.errorBlock = ^(NSError *error) {
            DDLogError(@"Error registering credit: %@",error);
        };
        
        [r startAsynchronous];
    }
}

#pragma mark - icon animation
-(void)iconAnimation{
    if(_animateTimer){
        [_animateTimer invalidate];
        _animateTimer = nil;
    }
    
    
    if(_isDownloading || _isUploading){
        _animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                         target:self selector:@selector(animateArrow) userInfo:nil
                                                        repeats:YES];
    }else{
        //creating new user animation
        opacityCnt = 0;
        _lastAnimate = 1;
        _animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                         target:self selector:@selector(animateLoadUser) userInfo:nil
                                                        repeats:YES];
    }
    
    NSRunLoop * rl = [NSRunLoop mainRunLoop];
    [rl addTimer:_animateTimer forMode:NSRunLoopCommonModes];
}

int opacityCnt;
-(void)animateLoadUser{
    int x = 0;
    
    opacityCnt++;
    if(opacityCnt > 20){
        opacityCnt = 0;
    }
    
    if(opacityCnt > 10){
        x = 10 - (opacityCnt - 10);
    }else{
        x = opacityCnt;
    }
    
    NSImage *image = [NSImage imageNamed:@"loading.png"];
    NSImage *opacitatedImage = [[NSImage alloc] initWithSize:[image size]];
    
    [opacitatedImage lockFocus];
    [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.1 * x];
    [opacitatedImage unlockFocus];
    
    statusItemView.image = opacitatedImage;
}

int animateY;
-(void)animateArrow{
    animateY++;
    
    int x = animateY;
    if(x > 19){
        animateY = 0;
    }
    
    NSImage *image2;
    if(_isUploading){
        _lastAnimate = 2;
        image2 = [NSImage imageNamed:@"upload.png"];
        x = (2 * animateY) - 25;
    }else{
        _lastAnimate = 3;
        image2 = [NSImage imageNamed:@"download.png"];
        x = 25 - (2 * animateY);
    }
    
    NSImage *image = [NSImage imageNamed:@"icon.png"];
    NSImage *arrowImage = [[NSImage alloc] initWithSize:[image size]];
    
    [arrowImage lockFocus];
    [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [image2 drawAtPoint:NSMakePoint(0,x) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [arrowImage unlockFocus];
    
    statusItemView.image = arrowImage;
}

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

#pragma mark - phonetic stuff

-(void)showPhonetic{
    if([self isPhonetic]){
        DDLogError(@"mark as false");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"phonetic"];
    }else{
        DDLogVerbose(@"mark as true");
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"phonetic"];
    }
    
    [self setDefaultMenu];
}

-(BOOL)isPhonetic{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"phonetic"];
}

-(NSString*)stringToPhonetic:(NSString*)string{
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

-(NSString*)letterToPhonetic:(char)letter{
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

#pragma mark - socketRocket

- (void)checkSocket{
    if(!_authedSocket && _connectedToSocket){
        [_webSocket send:[self dicToJsonString:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    @"connect", @"type",
                                                    _uuid, @"UUID",
                                                    [self getKey:@"UUIDKey"], @"key",
                                                nil]
                          ]];
    }else if(!_userCode){
        [self createNewUser];
    }
}

- (void)openSocket{
    DDLogVerbose(@"Openning socket");
    _connectedToSocket = false;
    _authedSocket = false;
    
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://s.transferme.it"]];
    _webSocket.delegate = (id)self;
    
    [_webSocket open];
}

-(void)closeSocket{
    DDLogVerbose(@"closed socket");
    _connectedToSocket = false;
    _authedSocket = false;
    _userCode = nil;
}

bool receivedPong = false;
- (void)sendPing{
    if(_connectedToSocket){
        receivedPong = false;
        [_webSocket sendPing:nil];
        
        //check for pong in 1 second
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [NSThread sleepForTimeInterval:1.0f];
            if(!receivedPong){
                DDLogError(@"Did not receive pong");
                [self closeSocket];
            }
        });
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    _connectedToSocket = true;
    [self askForRealTime];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    DDLogError(@"The websocket handshake/connection failed with an error: %@", error);
    [self closeSocket];
}


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(nonnull NSString *)string{
    [self receivedMessage:string];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    DDLogVerbose(@"WebSocket closed because: %@",reason);
    [self closeSocket];
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    receivedPong = true;
}

#pragma mark - open on startup

- (BOOL)loginItemExistsWithLoginItemReference{
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

- (void)enableLoginItemWithURL
{
    if(![self loginItemExistsWithLoginItemReference]){
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
        [_showOnStartupItem setState:NSOnState];
    }
}

- (void)removeLoginItemWithURL
{
    if([self loginItemExistsWithLoginItemReference]){
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
        [_showOnStartupItem setState:NSOffState];
    }
}

-(void)openOnStartup{
    if(![self loginItemExistsWithLoginItemReference]){
        [self enableLoginItemWithURL];
    }else{
        [self removeLoginItemWithURL];
    }
}


#pragma mark - major error dealer
- (void)handleError:(NSString*)body location:(NSString*)location{
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/error.php"];
    
    r.POSTDictionary = @{ @"body":body, @"location": location};
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
    };
    
    r.errorBlock = ^(NSError *error) {
        //ironic error
    };
    
    [r startAsynchronous];
}

- (NSString *)hash:(NSData *)data{
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

-(NSString*)jsonToVal:(NSString*)json key:(NSString*)key{
    NSMutableDictionary* dic = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    if([dic objectForKey:key]) return [dic objectForKey:key];
    return @"";
}

-(NSString*)dicToJsonString:(NSDictionary*)dic{
    NSError* error;
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) return @"";
    return [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
}

-(NSString*)overflowString:(NSString*)string size:(int)size{
    if([string length] > size){
        string = [NSString stringWithFormat:@"%@...", [string substringToIndex:size]];
    }
    return string;
}

-(NSString *)randomString:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint_fast32_t)[letters length])]];
    }
    
    return randomString;
}

#pragma mark - quit app
-(void)quitApp{
    [NSApp terminate:self];
}

#pragma mark - logging
NSString *log_file_path;
-(void)setupLogging{
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:fileLogger];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    log_file_path = [[fileLogger currentLogFileInfo] filePath];
}

-(void)showLoggingFile{
    [[NSWorkspace sharedWorkspace] openFile:log_file_path];
}

#pragma mark - RSA keys

-(void)generateKeys{
    DDLogVerbose(@"creating new RSA Keys");
    //create pub and private key
    MIHRSAKeyFactory *factory = [[MIHRSAKeyFactory alloc] init];
    factory.preferedKeySize = MIHRSAKey4096;
    MIHKeyPair *keyPair       = [factory generateKeyPair];
    
    id<MIHPublicKey> publicKey = keyPair.public;
    id<MIHPrivateKey> privateKey = keyPair.private;
    
    //store priv key in keychain
    [self storeKey:@"privateKey" withPassword:[self keyTo64String:privateKey]];
    [self storeKey:@"publicKey" withPassword:[self keyTo64String:publicKey]];
    
    NSLog(@"pk:%@",[self keyTo64String:publicKey]);
}

-(NSString*)keyTo64String:(id)key{
    NSData *key_data = [NSKeyedArchiver archivedDataWithRootObject:key];
    return [key_data base64EncodedStringWithOptions:0];
}

-(id)string64ToKey:(NSString*)key{
    NSData* priv_actual_data = [[NSData alloc] initWithBase64EncodedString:key options:0];
    return [NSKeyedUnarchiver unarchiveObjectWithData:priv_actual_data];
}

-(NSString*)encryptWithKey:(NSString*)string publicKey:(id<MIHPublicKey>)pk{
    NSData* string_data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData* encr_data = [pk encrypt:string_data error:nil];
    return [encr_data base64EncodedStringWithOptions:0];
}

-(NSString*)decryptWithKey:(NSString*)string privKey:(id<MIHPrivateKey>)pk{
    string = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //decode ascii charachters
    NSData* encr_actual_data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    NSData *decryptedData = [pk decrypt:encr_actual_data error:nil];
    return [NSString stringWithUTF8String:decryptedData.bytes];
}


@end
