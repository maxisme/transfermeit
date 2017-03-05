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

//-----StatusItemView
@interface StatusItemView : NSView <NSMenuDelegate> {
@private
    NSImage *_image;
    NSStatusItem *_statusItem;
    BOOL _isHighlighted;
    SEL _action;
    id __unsafe_unretained _target;
***REMOVED***

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
***REMOVED***


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //register for drags
        NSArray *dragTypes = @[NSURLPboardType, NSFileContentsPboardType, NSFilenamesPboardType];
        [self registerForDraggedTypes:dragTypes];
    ***REMOVED***
    
    return self;
***REMOVED***

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
    ***REMOVED***
    return self;
***REMOVED***

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
***REMOVED***

- (void)mouseDown:(NSEvent *)theEvent
{
    NSMenu *menu = [super menu];
    [_statusItem popUpStatusItemMenu:menu];
    [NSApp sendAction:self.action to:self.target from:self];
***REMOVED***


- (void)menuWillOpen:(NSMenu *)menu {
    [self setHighlighted:YES];
    [self setNeedsDisplay:YES];
***REMOVED***

- (void)menuDidClose:(NSMenu *)menu {
    [self setHighlighted:NO];
    [self setNeedsDisplay:YES];
***REMOVED***

- (void)setImage:(NSImage *)newImage
{
    _image = newImage;
    [self setNeedsDisplay:YES];
***REMOVED***

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:@[NSFilenamesPboardType]]) {
        return NSDragOperationCopy;
    ***REMOVED***
    return NSDragOperationNone;
***REMOVED***

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pb = [sender draggingPasteboard];
    if([[pb pasteboardItems] count] != 1){
        return NO;
    ***REMOVED***
    
    NSURL *url = [NSURL URLFromPasteboard:pb];
    _thisapp.uploadFilePath = url.path;
    NSLog(@"path:%@",url.path);
    [_thisapp chooseFriend];
    
    return NO;
***REMOVED***

@end


//-----MyWindow

@interface MyWindow: NSWindow
{
***REMOVED***
- (BOOL) canBecomeKeyWindow;
@end

@implementation MyWindow
- (BOOL) canBecomeKeyWindow
{
    return YES;
***REMOVED***
@end


//-----MyButton

@interface MyButton: NSButton
@property (nonatomic, strong) NSTrackingArea* trackingArea;
@property (nonatomic, strong) NSImage *imageTmp;
@property (strong) NSCursor *cursor;
@end

@implementation MyButton

-(void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    [self updateImages];
    self.image = self.alternateImage;
***REMOVED***

-(void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    self.image = self.imageTmp;
***REMOVED***

- (void)updateImages {
    self.imageTmp = self.image;
***REMOVED***

-(void)updateTrackingAreas
{
    if(self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    ***REMOVED***
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    
    [self addTrackingArea:self.trackingArea];
***REMOVED***

- (void)resetCursorRects
{
    if (self.cursor) {
        [self addCursorRect:[self bounds] cursor: self.cursor];
    ***REMOVED*** else {
        [super resetCursorRects];
    ***REMOVED***
***REMOVED***
@end


@interface AppDelegate ()
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self onlyOneInstanceOfApp];
    
    //    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hasShownStartUp"] == 1) {
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            [self enableLoginItemWithURL];
    //            [self startUpWindow];
    //            [self showView];
    //        ***REMOVED***);
    //    ***REMOVED***
    NSData* file = [NSData dataWithContentsOfFile:[self adDIR:@"Choose the file you want to send!" buttonTitle:@"Choose" dirBool:NO fileBool:YES]];
    NSLog(@"hash: %@", [self hash:file]);
    
    //set colours
    pink = [NSColor colorWithRed:0.973 green:0.482 blue:0.529 alpha:1];
    blue = [NSColor colorWithRed:0.36 green:0.40 blue:0.52 alpha:1.0];
    offWhite = [NSColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1];
    
    //initiate time_format
    _time_format = [[NSDateFormatter alloc] init];
    [_time_format setDateFormat:@"mm:ss"];
    
    //initiate UUID
    _uuid = [self getSystemUUID];
    
    //initiate keychain access
    _keychainQuery = [[SAMKeychainQuery alloc] init];
    //_keychainQuery.service = @"uuid_key";
    _keychainQuery.account = @"transferme.it";
    
    //default status variables
    _isMonitoring = false;
    _isCreatingUser = false;
    _hasInternet = true;
    
    //initiate file locations and decryption keys
    _files = [[NSMutableArray alloc] init];
    _keys = [[NSMutableArray alloc] init];
    
    //get default user time
    _wantedTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"setTime"];
    if(!_wantedTime){
        _wantedTime = @"10";
    ***REMOVED***
    
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
    //[self checkForUpdate:1];
    
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
//        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"testencryptedfile.dat"];
//        
//        // Save it into file system
//        [encrypted_data writeToFile:dataPath atomically:YES];
//        
//        NSLog(@"decrypt size: %d", (int)[[self decryptFile:encrypted_data password:@"7xuSq6FwfxdGemqXhrizbFnbPqwdBK"] length]);
//    ***REMOVED***);
    
    //DECRYPT AT PATH
//    NSData* file = [NSData dataWithContentsOfFile:@"/Users/maxmitch/Downloads/testencryptedfile_test.dat"];
//    NSLog(@"decrypt size: %d", (int)[[self decryptFile:file password:@"7xuSq6FwfxdGemqXhrizbFnbPqwdBK"] length]);
    
    //$ mv /Users/maxmitch/Library/Caches/testencryptedfile.dat ~/Documents/transfermeit/transferme.it/
***REMOVED***

-(void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [_window setContentView:_view];           // Hook the view up to the window
***REMOVED***

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    //[self deleteUser:0];
***REMOVED***

#pragma mark - view

int window_width = 300;
int window_height = 160;

NSColor *pink;
NSColor *blue;
NSColor *offWhite;
bool isDefaultWindow = false;
MyButton* submitButton;

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
        NSImageView *upView = [[NSImageView alloc] initWithFrame:NSMakeRect(window_width/2 - 10, window_height-20, 20, 20)];
        [upView setImage:up];
        [_view addSubview:upView];
        
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
    ***REMOVED***
***REMOVED***

//for friend code
NSString* string_before;
- (void)controlTextDidChange:(NSNotification *)notification {
    if(![_label.stringValue  isEqual: @"E N T E R  R E G I S T R A T I O N  K E Y "]){
        NSTextField *textField = [notification object];
        NSString* string = textField.stringValue;
        //make upper
        string = [string uppercaseString];
        //make sure user is less than userLength
        if([string length] > userLength){
            string = string_before;
        ***REMOVED***else{
            string_before = string;
        ***REMOVED***
        
        [textField setStringValue:[string uppercaseString]];
    ***REMOVED***
***REMOVED***

-(void)startUpWindow{
    
    NSRect frame = [[_statusItem valueForKey:@"window"] frame];
    
    NSRect contentSize = NSMakeRect(frame.origin.x - 400/2 + frame.size.width/2, frame.origin.y - 250, 400, 250);
    //NSUInteger windowStyleMask = NSResizableWindowMask;
    
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
    NSImageView *upView = [[NSImageView alloc] initWithFrame:NSMakeRect(window_width/2 - 10, window_height-20, 20, 20)];
    [upView setImage:up];
    [_view addSubview:upView];
    
    //LABELS
    NSTextField* thankyou = [[NSTextField alloc] initWithFrame:CGRectMake(0, window_height -90, window_width, 50)];
    thankyou.backgroundColor = [NSColor clearColor];
    [thankyou setAlignment:NSTextAlignmentCenter];
    [thankyou setFont:[NSFont fontWithName:@"Montserrat" size:12]];
    [thankyou setTextColor:offWhite];
    thankyou.editable = false;
    thankyou.bordered =false;
    [thankyou setStringValue:@"T h a n k   y o u   f o r   d o w n l o a d i n g"];
    [_view addSubview:thankyou];
    
    NSTextField* tmi = [[NSTextField alloc] initWithFrame:CGRectMake(0, window_height -160, window_width, 100)];
    tmi.backgroundColor = [NSColor clearColor];
    [tmi setAlignment:NSTextAlignmentCenter];
    [tmi setFont:[NSFont fontWithName:@"Montserrat" size:28]];
    [tmi setTextColor:offWhite];
    tmi.editable = false;
    tmi.bordered =false;
    [tmi setStringValue:@"T R A N S F E R  M E  I T"];
    [_view addSubview:tmi];
    
    NSTextField* clickIcon = [[NSTextField alloc] initWithFrame:CGRectMake(0, -75, window_width, 100)];
    clickIcon.backgroundColor = [NSColor clearColor];
    [clickIcon setAlignment:NSTextAlignmentCenter];
    [clickIcon setFont:[NSFont fontWithName:@"Montserrat" size:8]];
    [clickIcon setTextColor:offWhite];
    clickIcon.editable = false;
    clickIcon.bordered =false;
    [clickIcon setStringValue:@"Click the menu bar icon to close!"];
    [_view addSubview:clickIcon];
    
    NSImage *myImage = [NSImage imageNamed:@"mainicon.png"];
    NSImageView *imView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, -5, 400, 180)];
    [imView setImage:myImage];
    [_view addSubview:imView];
***REMOVED***

- (void)menuWillOpen:(NSMenu *)menu
{
    if([_window isVisible]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[_statusItem popUpStatusItemMenu:[self statusBarMenu]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //[self killMenu];
                //[self setDefaultMenu];
            ***REMOVED***);
        ***REMOVED***);
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self finishStartUpView];
        ***REMOVED***);
        [_window orderOut:self];
        [_window close];
    ***REMOVED***
***REMOVED***

-(void)showView{
    //create view controller
    [NSApp activateIgnoringOtherApps:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_window makeKeyAndOrderFront:_view];
    ***REMOVED***);
***REMOVED***

#pragma mark - NSUserNotification

-(void)desktopAlert:(NSString*)title message:(NSString*)message button1:(NSString*)button1 button2:(NSString*)button2{
    [self desktopAlert:title message:message button1:button1 button2:button2 variables:nil];
***REMOVED***

-(void)desktopAlert:(NSString*)title message:(NSString*)message button1:(NSString*)button1 button2:(NSString*)button2 variables:(NSDictionary*)variables{
    if(!_hasRequestedDownload && !_isDownloading && !_isUploading){
        if([title isEqualToString: _previousDesktopTitle] /*&& ![title  isEqual: @"Incoming File!"]*/){
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        ***REMOVED***
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = title;
        notification.userInfo = variables;
        notification.informativeText = message;
        notification.identifier = [NSString stringWithFormat:@"%d", _notificationCount++];
        if(![button1 isEqual: @""]){
            notification.actionButtonTitle = button1;
        ***REMOVED***else{
            [notification setHasActionButton:NO];
        ***REMOVED***
        if(![button2 isEqual: @""]){
            notification.otherButtonTitle = button2;
        ***REMOVED***else{
            [notification setHasReplyButton:NO];
        ***REMOVED***
        
        if([title  isEqual: @"Incoming File!"]){
            notification.soundName = @"alert.wav";
        ***REMOVED***
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        _previousDesktopTitle = title;
    ***REMOVED***else{
        if(_isDownloading){
            NSLog(@"can't notify %@ as downloading", title);
        ***REMOVED***else if(_isUploading){
            NSLog(@"can't notify %@ as downloading", title);
        ***REMOVED***else{
            NSLog(@"already requested a download");
        ***REMOVED***
    ***REMOVED***
***REMOVED***

//action button for NSUserNotification
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification{
    int ref = [notification.userInfo[@"ref"] intValue];
    NSString* friendUUID = notification.userInfo[@"friendUUID"];
    if([notification.title  isEqual: @"Would you like to download this file?"]){
        NSString* downloadLocation = [self saveLocation];
        if(downloadLocation == nil){
            downloadLocation = [self adDIR:@"Choose where your file should be saved" buttonTitle:@"Save" dirBool:true fileBool:false];
        ***REMOVED***
        [self downloadFile:downloadLocation friendUUID:friendUUID ref:ref];
    ***REMOVED***else if([notification.title  isEqual: @"File Too Big!"]){
        [self goPro];
    ***REMOVED***else if([notification.title  isEqual: @"Success Downloading File!"]){
        [self openFilePath:_savedFileLocation file:[_savedFileLocation lastPathComponent]];
        _savedFileLocation = nil;
    ***REMOVED***
***REMOVED***

//send notification even at forefront
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
***REMOVED***

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    if([notification.title  isEqual: @"Would you like to download this file?"]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           BOOL notificationStillPresent;
                           do {
                               notificationStillPresent = NO;
                               for (NSUserNotification *note in [[NSUserNotificationCenter defaultUserNotificationCenter]deliveredNotifications]) {
                                   if ([note.identifier isEqualToString:notification.identifier]){
                                       notificationStillPresent = YES;
                                   ***REMOVED***
                               ***REMOVED***
                               if (notificationStillPresent){
                                   [NSThread sleepForTimeInterval:0.20f];
                               ***REMOVED***
                           ***REMOVED*** while (notificationStillPresent);
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               //called when closed
                               if(!_isDownloading){
                                   NSLog(@"PRESSED NO");
                                   int ref = [notification.userInfo[@"ref"] intValue];
                                   NSString* friendUUID = notification.userInfo[@"friendUUID"];
                                   [self finishedDownload:[self getValueFromArray:ref array:_files] friendUUID:friendUUID ref:ref newuser:false];
                               ***REMOVED***
                           ***REMOVED***);
                       ***REMOVED***);
    ***REMOVED***else{
        //close notification after 8 seconds
        if(!([notification.title  isEqual: @"Registration Key Has Expired!"])){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                for (NSUserNotification *note in [[NSUserNotificationCenter defaultUserNotificationCenter] deliveredNotifications]) {
                    if ([note.identifier isEqualToString:notification.identifier]){
                        [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:note];
                    ***REMOVED***
                ***REMOVED***
            ***REMOVED***);
        ***REMOVED***
    ***REMOVED***
***REMOVED***

#pragma mark - stuff

-(int)bytesToMega:(int)bytes{
    return bytes / 1048576;
***REMOVED***

-(int)bytesToEncrypted:(int)bytes{
    int overhead = 66;
    
    if (bytes == 0) {
        return 16 + overhead;
    ***REMOVED***
    
    int remainder = bytes % 16;
    if (remainder == 0) {
        return bytes + 16 + overhead;
    ***REMOVED***
    
    return bytes + 16 - remainder + overhead;
***REMOVED***

int second_count;
bool dnd_was_on = false;
-(void) everySecond{
    second_count++;
    
    if([self dndIsOn]){
        [self setNoInternetMenu];
        _itemOne.title = @"Please turn off 'Do Not Disturb'!";
        dnd_was_on = true;
    ***REMOVED***else if(dnd_was_on){
        dnd_was_on = false;
        [self setDefaultMenu];
    ***REMOVED***
    
    if(second_count % 2 == 0){
        [self checkSocket];
    ***REMOVED***
    
    if(second_count % 15 == 0){
        [self askForRealTime];
    ***REMOVED***
    
    if(second_count % 30 == 0){
        [self sendPing];
        
        if(_isUploading || _isDownloading){
            [self sendKeepActive];
        ***REMOVED***
    ***REMOVED***
    
    // update time in icon menu
    if ([_itemSix.title  isEqual: @"Settings..."]) {
        NSDate* deducted_date = [_current_time dateByAddingTimeInterval:-second_count];
        NSString *time_left = [_time_format stringFromDate:deducted_date];
        if([time_left  isEqual: @"00:00"]){
            [self askForRealTime];
        ***REMOVED***
        
        [_itemTwo setTitle:[NSString stringWithFormat:@"Code will reset in - %@",time_left]];
    ***REMOVED***
***REMOVED***

-(void)sendKeepActive{
    if(_connectedToSocket){
        [_webSocket send:[NSString stringWithFormat:@"keep|%@|%@|%@",_uuid,_userCode,_downloadingPath]];
    ***REMOVED***
***REMOVED***

-(void)askForRealTime{
    if(_connectedToSocket){
        [_webSocket send:[NSString stringWithFormat:@"time|%@|%@", _userCode, _uuid]];
    ***REMOVED***
***REMOVED***

- (BOOL) fileIsPath: (NSString*) path {
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            NSLog(@"%@ is a directory", path);
            return false;
        ***REMOVED*** else {
            NSLog(@"%@ is a path", path);
            return true;
        ***REMOVED***
    ***REMOVED***
    return false;
***REMOVED***

-(void)checkForUpdate:(int)x{
    SUUpdater* suupdater;
    suupdater = [SUUpdater sharedUpdater];
    if(x != 1){
        [suupdater checkForUpdates:self];
    ***REMOVED***else{
        [suupdater checkForUpdatesInBackground];
    ***REMOVED***
***REMOVED***

- (void)updaterDidNotFindUpdate:(SUUpdater *)update
{
    NSLog(@"Sparkle: Updater Did Not Find Update");
***REMOVED***

-(BOOL)dndIsOn{ //do not disturb
    NSString* path =  [[NSString stringWithFormat:@"~/Library/Preferences/ByHost/com.apple.notificationcenterui.%@.plist",_uuid] stringByExpandingTildeInPath];
    
    return [[NSDictionary dictionaryWithContentsOfFile:path][@"doNotDisturb"] boolValue];
***REMOVED***

-(void)finishStartUpView{
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"hasShownStartUp"];
    
    //close popup
    [[NSApplication sharedApplication] hide:nil];
***REMOVED***

-(void)windowClosed{
    _inputCode.stringValue = @"";
***REMOVED***

-(void)windowDidResignKey:(NSNotification *)note {
    [_window orderOut:self];
    [_window close];
***REMOVED***

-(NSString*)adDIR:(NSString*)title buttonTitle:(NSString*)buttonTitle dirBool:(BOOL)dir fileBool:(BOOL)file
{
    
    //bring app to focus
    [NSApp activateIgnoringOtherApps:YES];
    
    // Display the dialog. If the OK button was pressed,
    // process the files.
    _openPanel = [[NSOpenPanel alloc] init];
    
    [_openPanel setLevel:NSFloatingWindowLevel];
    
    // Can create new folder
    [_openPanel setCanCreateDirectories:dir];
    
    // Multiple files not allowed
    [_openPanel setAllowsMultipleSelection:NO];
    
    // Can select a directory
    [_openPanel setCanChooseDirectories:dir];
    
    // Enable the selection of files in the dialog.
    [_openPanel setCanChooseFiles:file];
    
    [_openPanel setMessage:title];
    
    [_openPanel setPrompt:buttonTitle];
    
    NSString* fileName;
    if ([_openPanel runModal] == NSModalResponseOK)
    {
        for( NSURL* URL in [_openPanel URLs] )
        {
            fileName = [URL path];
            return fileName;
        ***REMOVED***
    ***REMOVED***
    return fileName;
***REMOVED***

-(void)pasteToFriendCode{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    NSString* pasteString = [pasteBoard stringForType:NSPasteboardTypeString];
    _inputCode.stringValue = [pasteString uppercaseString];
***REMOVED***

-(void)selectFriendCode{
    [_inputCode selectText:self];
***REMOVED***

-(void)enter{
    [submitButton performClick:self];
***REMOVED***

-(void)copyCode{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString: _userCode forType:NSStringPboardType];
***REMOVED***

- (void)onlyOneInstanceOfApp {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
        NSLog(@"instance of app already open");
        [NSApp terminate:self];
    ***REMOVED***
***REMOVED***

- (NSString *)getSystemUUID {
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    if (!platformExpert)
        return nil;
    
    CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,CFSTR(kIOPlatformUUIDKey),kCFAllocatorDefault, 0);
    IOObjectRelease(platformExpert);
    if (!serialNumberAsCFString)
        return nil;
    
    return (__bridge NSString *)(serialNumberAsCFString);;
***REMOVED***

-(void)goPro{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://transferme.it/#credit"]];
***REMOVED***

-(NSString*)cleanUpString:(NSString*)unfilteredString{
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@£$%^&*()_+-={***REMOVED***[]:|;\\<>?,.`~"] invertedSet];
    return [[unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
***REMOVED***

#pragma mark - menu bar
StatusItemView *statusItemView;
- (void)createStatusBarItem {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    statusItemView = [[StatusItemView alloc] initWithStatusItem:_statusItem];
    [statusItemView setImage:[NSImage imageNamed:@"loading.png"]];
    [statusItemView setMenu:[self statusBarMenu]];
    statusItemView.thisapp = self;
***REMOVED***

- (NSMenu *)statusBarMenu {
    
    //deal with seperators
    _seperator1 = [NSMenuItem separatorItem];
    //[_seperator1 setHidden:true];
    _seperator2 = [NSMenuItem separatorItem];
    //[_seperator2 setHidden:true];
    _seperator3 = [NSMenuItem separatorItem];
    //[_seperator3 setHidden:true];
    _seperator4 = [NSMenuItem separatorItem];
    //[_seperator4 setHidden:true];
    _seperator5 = [NSMenuItem separatorItem];
    //[_seperator5 setHidden:true];
    
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    _itemOne = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    //[_itemOne setTarget:self];
    //[_itemOne setHidden:false];
    [menu addItem:_itemOne];
    
    [menu addItem:_seperator1];
    
    _itemTwo = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    //[_itemTwo setTarget:self];
    //[_itemTwo setHidden:true];
    [menu addItem:_itemTwo];
    
    [menu addItem:_seperator2];
    
    _itemThree = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    //[_itemThree setTarget:self];
    //[_itemThree setHidden:true];
    [menu addItem:_itemThree];
    
    [menu addItem:_seperator3];
    
    _itemFour = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    //[_itemFour setTarget:self];
    //[_itemFour setHidden:true];
    [menu addItem:_itemFour];
    
    [menu addItem:_seperator4];
    
    //options menu
    _itemFive = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    //[_itemFive setTarget:self];
    //[_itemFive setHidden:true];
    [menu addItem:_itemFive];
    
    [menu addItem:_seperator5];
    
    _itemSix = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    //[_itemSix setTarget:self];
    //[_itemSix setHidden:true];
    [menu addItem:_itemSix];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* quit = [[NSMenuItem alloc] initWithTitle:@"Quit Transfer Me It" action:@selector(quitApp) keyEquivalent:@""];
    [quit setTarget:self];
    [menu addItem:quit];
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    return menu;
***REMOVED***

-(void)killMenu{
    //deal with seperators
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
***REMOVED***

-(void)setDefaultMenu{
    if(_userCode){
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
        
        _itemTwo.title = [NSString stringWithFormat:@"Code will reset in - %@", _timeLeft];
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
        ***REMOVED***
        
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
    ***REMOVED***
***REMOVED***

-(void)setdownloadMenu:(int)ref{
    [self killMenu];
    
    if(!_animateTimer || _lastAnimate != 3){
        [self iconAnimation];
    ***REMOVED***
    
    //deal with seperators
    [_seperator2 setHidden:false];
    
    _itemOne.title = [NSString stringWithFormat:@"Downloading '%@'",[[self getValueFromArray:ref array:_files] lastPathComponent]];
    _itemOne.action = nil;
    [_itemOne setHidden:false];
    
    _itemTwo.title = [NSString stringWithFormat:@"%.1f%% of %@", _downloadPercent, [NSByteCountFormatter stringFromByteCount:_totalBytes countStyle:NSByteCountFormatterCountStyleFile]];
    _itemTwo.action = nil;
    [_itemTwo setHidden:false];
    
    _itemThree.title = @"Cancel Download";
    _itemThree.action = @selector(createNewUser);
    [_itemThree setEnabled:true];
    [_itemThree setHidden:false];
***REMOVED***

-(void)setUploadMenu{
    [self killMenu];
    
    if(!_animateTimer || _lastAnimate != 2){
        [self iconAnimation];
    ***REMOVED***
    
    //deal with seperators
    [_seperator2 setHidden:false];
    
    _itemOne.title = @"Uploading File";
    [_itemOne setHidden:false];
    
    _itemTwo.title = [NSString stringWithFormat:@"%.1f%%", _uploadPercent];
    [_itemTwo setHidden:false];
    
    _itemThree.title = @"Cancel Upload";
    _itemThree.action = @selector(createNewUser);
    [_itemThree setEnabled:true];
    [_itemThree setHidden:false];
***REMOVED***

-(void)setNoInternetMenu{
    [self killMenu];
    
    if(_animateTimer){
        [_animateTimer invalidate];
        _animateTimer = nil;
    ***REMOVED***
    
    statusItemView.image = [NSImage imageNamed:@"alert.png"];
    _itemOne.title = @"Network Error!";
    [_itemOne setHidden:false];
***REMOVED***

-(void)setRequestingCodeMenu{
    [self killMenu];
    
    if(!_animateTimer || _lastAnimate != 1){
        [self iconAnimation];
    ***REMOVED***
    
    _itemFive.title = @"Requesting Code From Server...";
    [_itemFive setHidden:false];
***REMOVED***

-(void)setGettingRegMenu{
    [self killMenu];
    
    if(!_animateTimer){
        [self iconAnimation];
    ***REMOVED***
    
    _itemFive.title = @"Checking Registration Code...";
    [_itemFive setHidden:false];
***REMOVED***

- (NSMenu *)options {
    NSMenu *menu = [[NSMenu alloc] init];
    float bandwidthLeftGB = [self bytesToMega:_bandwidthLeft] * 0.001;
    NSLog(@"gb left: %f",bandwidthLeftGB);
    
    //CODE STUFF
    
    NSMenuItem* codeItem = [[NSMenuItem alloc] initWithTitle:@"Code" action:nil keyEquivalent:@""];
    [codeItem setEnabled:false];
    [menu addItem:codeItem];
    
    NSMenuItem* phoneticOptionItem = [[NSMenuItem alloc] initWithTitle:@"Show phonetics" action:@selector(showPhonetic) keyEquivalent:@""];
    [phoneticOptionItem setTarget:self];
    if([self isPhonetic]){
        [phoneticOptionItem setState:NSOnState];
    ***REMOVED***
    [menu addItem:phoneticOptionItem];
    
    NSMenuItem* createNewCode = [[NSMenuItem alloc] initWithTitle:@"Create a new code for..." action:nil keyEquivalent:@""];
    [createNewCode setSubmenu: [self timeIntervals]];
    [menu addItem:createNewCode];
    
    NSMenuItem* extraSecureAccount = [[NSMenuItem alloc] initWithTitle:@"Add extra security with keychain" action:@selector(createNewUser:) keyEquivalent:@""];
    [extraSecureAccount setTarget:self];
    if([[self getUUIDKey] isEqualToString:@" "]){
        [extraSecureAccount setState:NSOnState];
        [extraSecureAccount setEnabled:false];
    ***REMOVED***
    [menu addItem:extraSecureAccount];
    
    if([self hasProCode]){
        NSMenuItem* permUserItem = [[NSMenuItem alloc] initWithTitle:@"Set permanent code" action:@selector(setPerm) keyEquivalent:@""];
        [permUserItem setTarget:self];
        if([self hasPermUser]){
            [permUserItem setState:NSOnState];
        ***REMOVED***
        [menu addItem:permUserItem];
    ***REMOVED***
    
    [menu addItem:[NSMenuItem separatorItem]];
    //DOWNLOAD STUFF
    
    NSMenuItem* saveItem = [[NSMenuItem alloc] initWithTitle:@"Save Location" action:nil keyEquivalent:@""];
    [saveItem setEnabled:false];
    [menu addItem:saveItem];
    
    NSMenuItem* saveLocation = [[NSMenuItem alloc] initWithTitle:@"Default save location" action:@selector(setSaveLocation) keyEquivalent:@""];
    [saveLocation setTarget:self];
    if([self saveLocation] != nil){
        [saveLocation setState:NSOnState];
    ***REMOVED***
    [menu addItem:saveLocation];
    
    NSMenuItem* downloadAutomatically = [[NSMenuItem alloc] initWithTitle:@"Automatically accept incoming files" action:@selector(setDownloadAuto) keyEquivalent:@""];
    [downloadAutomatically setTarget:self];
    if([self shouldAutoDownload]){
        [downloadAutomatically setState:NSOnState];
    ***REMOVED***
    [menu addItem:downloadAutomatically];
    
    
    //PRO STUFF
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* accountType  = [[NSMenuItem alloc] init];
    [accountType setTarget:self];
    [accountType setEnabled:NO];
    [menu addItem:accountType];
    
    accountType.title = [NSString stringWithFormat:@"You have %.3fGB/%@min credit",bandwidthLeftGB,_maxTime];
    
    NSMenuItem* addCredit = [[NSMenuItem alloc] initWithTitle:@"Upgrade PRO account" action:@selector(goPro) keyEquivalent:@""];
    [addCredit setTarget:self];
    [menu addItem:addCredit];
    
    NSMenuItem* regKey = [[NSMenuItem alloc] initWithTitle:@"Enter PRO registration key" action:@selector(enterProDetesView) keyEquivalent:@""];
    [regKey setTarget:self];
    [menu addItem:regKey];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    
    _showOnStartupItem = [[NSMenuItem alloc] initWithTitle:@"Start Transfer Me It at login" action:@selector(openOnStartup) keyEquivalent:@""];
    [_showOnStartupItem setTarget:self];
    
    if([self loginItemExistsWithLoginItemReference]){
        [_showOnStartupItem setState:NSOnState];
    ***REMOVED***else{
        [_showOnStartupItem setState:NSOffState];
    ***REMOVED***
    [menu addItem:_showOnStartupItem];
    
    NSMenuItem* update = [[NSMenuItem alloc] initWithTitle:@"Check for update" action:@selector(checkForUpdate:) keyEquivalent:@""];
    [update setTarget:self];
    [menu addItem:update];
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    return menu;
***REMOVED***

#pragma mark - auto download

-(void)setDownloadAuto{
    if([self shouldAutoDownload]){
        //remove autodownload option
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"autoDownload"];
    ***REMOVED***else{
        if([self saveLocation] == NULL){
            [self setSaveLocation];
        ***REMOVED***
        
        //check again incase user pressed cancel on choosing location
        if([self saveLocation] != NULL){
            //set auto download
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"autoDownload"];
        ***REMOVED***
    ***REMOVED***
    
    [self setDefaultMenu];
***REMOVED***

-(BOOL)shouldAutoDownload{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"autoDownload"];
***REMOVED***

#pragma mark - saved location

-(void)setSaveLocation{
    if([self saveLocation] != NULL){
        //remove save location
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"saveLocation"];
        if([self shouldAutoDownload]){
            [self setDownloadAuto];
        ***REMOVED***
    ***REMOVED***else{
        //set save location
        NSString* path = [self adDIR:@"Choose where you would like your files to automatically be saved" buttonTitle:@"Select" dirBool:true fileBool:false];
        [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"saveLocation"];
    ***REMOVED***
    
    [self setDefaultMenu];
***REMOVED***

-(NSString*)saveLocation{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveLocation"];
***REMOVED***

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
                    ***REMOVED***
                ***REMOVED***
            ***REMOVED***
        ***REMOVED***
    ***REMOVED***
    
    for (NSNumber *n in myIntegers) {
        int x = [n intValue];
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%d Minutes",x] action:@selector(setTime:) keyEquivalent:@""];
        [item setRepresentedObject:n];
        [item setTarget:self];
        
        //tick if selected
        if(x == [_wantedTime intValue]){
            [item setState:NSOnState];
        ***REMOVED***
        
        [menu addItem:item];
    ***REMOVED***
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    return menu;
***REMOVED***

-(void)setTime:(NSMenuItem*)sender{
    _wantedTime = sender.representedObject;
    [self createNewUser];
***REMOVED***

#pragma mark - initialise user
-(void)createNewUser{
    [self createNewUser:0];
***REMOVED***

-(void)createNewUser:(int)secure{
    if(secure != 0){
        secure = 1;
        //making sure the user actually wants to make the account secure.
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Are you sure you want to create a secure key?"];
        [alert setInformativeText:@"This is absolutely unchangable and requires that you click 'Allow' to Keychain. On loosing this key stored in the keychain Transfer Me It will not work anymore and you will have to get in touch with us to reset your account."];
        [alert addButtonWithTitle:@"Ok"];
        [alert addButtonWithTitle:@"Cancel"];
        
        NSInteger button = [alert runModal];
        if (button != NSAlertFirstButtonReturn) {
            //user denied alert
            secure = 0;
        ***REMOVED***
    ***REMOVED***
    
    if (!_isCreatingUser) {
        NSLog(@"creating a new user");
        [self closeSocket:false];
        
        if (_downloadReq) {
            NSLog(@"canceled download");
            [_downloadReq cancel];
            _downloadReq = nil;
            _isDownloading = false;
        ***REMOVED***
        
        if (_uploadReq) {
            NSLog(@"canceled upload");
            [_uploadReq cancel];
            _uploadReq = nil;
            _isUploading = false;
        ***REMOVED***
        
        _userCode = nil;
        _isCreatingUser = true;
        
        if(_hasInternet){
            [self setRequestingCodeMenu];
        ***REMOVED***
        
        NSString* proCode = @"";
        NSString* permUser = @"";
        if([self hasProCode]){
            proCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"pro_code"];
            if([self hasPermUser]){
                permUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user"];
            ***REMOVED***
        ***REMOVED***
        
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/addNewUser.php"];
        
        r.POSTDictionary = @{ @"UUID":_uuid, @"mins":[self cleanUpString:_wantedTime], @"pro_code":proCode, @"security":[NSString stringWithFormat:@"%d",secure], @"perm_user":permUser***REMOVED***;
        
        r.completionBlock = ^(NSDictionary *headers, NSString *body) {
            _hasInternet = true;
            if([body length] > 0){
                NSString* firstLetter = [body substringToIndex:1];
                body = [body substringFromIndex:1];
                
                NSArray *bodySplit = [body componentsSeparatedByString:@","]; //[0] = UUID, [1] = MB, [2] = time [3] = perm [4] = path
                
                if ([firstLetter  isEqual: @"2"]) {
                    //expired user
                    [self desktopAlert:@"Registration Key Has Expired!" message:@"Buy again from transferme.it" button1:@"" button2:@"Close"];
                    
                    //reset regCode
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"pro_code"];
                ***REMOVED***
                
                if ([firstLetter isEqual: @"1"] || [firstLetter isEqual: @"2"]) {
                    if([[self getUUIDKey] isEqualToString:@" "] && [bodySplit count] > 4){
                        //Receiving UUID KEY
                        NSString* UUIDkey = bodySplit[4];
                    
                        if([UUIDkey length] == 50){
                            //receiving the key
                            if(![self setUUIDKey:UUIDkey]){
                                NSAlert *alert = [[NSAlert alloc] init];
                                [alert setMessageText:@"Major Key Error"];
                                [alert setInformativeText:@"Please contact hello@transferme.it"];
                                [alert addButtonWithTitle:@"Okay"];
                                [alert runModal];
                            ***REMOVED***
                        ***REMOVED***
                    ***REMOVED***
                    
                    _userCode       = bodySplit[0];
                    _phoneticUser   = [self stringToPhonetic:_userCode];
                    _bandwidthLeft  = [bodySplit[1] intValue]; //bytes
                    NSLog(@"bl:%d",_bandwidthLeft);
                    _maxTime        = bodySplit[2];
                    
                    [self openSocket];
                ***REMOVED***else{
                    NSLog(@"major error new user: %@",body);
                    _isCreatingUser = false;
                ***REMOVED***
            ***REMOVED***
        ***REMOVED***;
        
        r.errorBlock = ^(NSError *error) {
            NSLog(@"ERROR: %@",error);
            _hasInternet = false;
            _isCreatingUser = false;
            [self setNoInternetMenu];
        ***REMOVED***;
        
        [r startAsynchronous];
    ***REMOVED***
    [[NSUserDefaults standardUserDefaults] setObject:_wantedTime forKey:@"setTime"];
***REMOVED***

-(BOOL)setUUIDKey:(NSString*)pass{
    NSError* error = nil;
    
    _keychainQuery.service = @"UUIDKey";
    [_keychainQuery setPassword:pass];
    [_keychainQuery save:&error];
    if(!error){
        return TRUE;
    ***REMOVED***
    return FALSE;
***REMOVED***

-(NSString*)getUUIDKey{
    NSError* error;
    
    _keychainQuery.service = @"UUIDKey";
    [_keychainQuery fetch:&error];
    if(!error){
        return [_keychainQuery password];
    ***REMOVED***
    return @" ";
***REMOVED***

#pragma mark - socket

//message from socket
-(void)receivedMessage:(NSString*)message{
    NSString* mes, *friendUUID;
    int ref = 0;
    
    NSArray *explode = [message componentsSeparatedByString:@"|"];
    NSString* type = explode[0];
    if([explode count] > 1){
        mes = explode[1];
        if([explode count] > 2){
            ref = [explode[2] intValue];
        ***REMOVED***
        if([explode count] > 3){
            friendUUID = explode[3];
        ***REMOVED***
    ***REMOVED***
    
    if([type  isEqual: @"file"]){
        NSLog(@"received file: %@ from %@", mes, friendUUID);
        [_files insertObject:[NSString stringWithFormat:@"%@|%d", mes, ref] atIndex:0];
        
        if([self shouldAutoDownload]){
            [self downloadFile:[self saveLocation] friendUUID:friendUUID ref:ref];
        ***REMOVED***else{
            [self desktopAlert:@"Would you like to download this file?"
                       message:[NSString stringWithFormat:@"%@?",[mes lastPathComponent]]
                       button1:@"Yes"
                       button2:@"No"
                     variables:@{@"ref":[NSString stringWithFormat:@"%d",ref], @"friendUUID":friendUUID***REMOVED***];
        ***REMOVED***
        
        _hasRequestedDownload = true;
    ***REMOVED***else if([type  isEqual: @"key"]){
        NSLog(@"received encryption key: %@", mes);
        [_keys insertObject:[NSString stringWithFormat:@"%@|%d", mes, ref] atIndex:0];
    ***REMOVED***else if([type  isEqual: @"time"]){
        if(!_authedSocket){
            _authedSocket = true;
            [self setDefaultMenu];
            NSLog(@"Authenticated socket");
        ***REMOVED***
        
        if([mes  isEqual: @"00:00"]){
            [self createNewUser];
        ***REMOVED***else{
            _current_time = [_time_format dateFromString:mes];
            second_count = 0;
        ***REMOVED***
    ***REMOVED***else if([message isEqual: @"downloaded"]){
        [self desktopAlert:@"Friend succesfully downloaded file!"
                   message:[NSString stringWithFormat:@"%@",[mes lastPathComponent]]
                   button1:@""
                   button2:@""];
    ***REMOVED***else if([message isEqual: @"0"]){
        [self createNewUser];
    ***REMOVED***else{
        [self desktopAlert:@"Socket Error!" message:message button1:@"" button2:@"Close"];
        NSLog(@"incoming socket error: %@",message);
    ***REMOVED***
***REMOVED***

//check whether time has changed
-(void)checkTimeChange{
    //current time
    NSString* currentTime = _itemThree.title;
    if ([_itemFive.title  isEqual: @"Settings..."]) {
        //correct menu
        if (currentTime == _theTime5) {
            NSLog(@"ERROR:time hasn't changed in 5 seconds!!");
            [self createNewUser];
        ***REMOVED***
    ***REMOVED***
***REMOVED***


#pragma mark - download new file
-(void)downloadFile:(NSString*)savedPath friendUUID:(NSString*)friendUUID ref:(int)ref{
    if(!_isDownloading){
        NSString* filePath = [self getValueFromArray:ref array:_files];
        NSString* key1 = [self getValueFromArray:ref array:_keys];
        
        NSLog(@"started download of: %@",filePath);
        
        _isDownloading = true;
        _savedFileLocation = savedPath;
        
        _downloadReq = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/download.php"];
        _downloadReq.POSTDictionary = @{ @"user":_userCode, @"UUID":_uuid, @"path":filePath***REMOVED***;
        
        _downloadingPath = filePath;
        
        _downloadReq.completionDataBlock = ^(NSDictionary *headers, NSData *downloadedData) {
            NSString* fileHash = [self hash:downloadedData];
            NSLog(@"file hash: %@",fileHash);
            NSString* key2 = [self finishedDownload:filePath friendUUID:friendUUID ref:ref newuser:true hash:fileHash];
            
            if ([downloadedData length] > 0) {
                NSLog(@"Called completionDataBlock data: %lu",(unsigned long)[downloadedData length]);
                //start unencrypting file
                [_itemTwo setTitle:@"Decrypting File..."];
                
                NSData* decryptedFile = [self decryptFile:downloadedData password:[NSString stringWithFormat:@"%@%@", key1,key2]];
                
                if(decryptedFile == nil){
                    [self desktopAlert:@"Error Decrypting File!" message:@"Please ask your friend to send the file again!" button1:@"" button2:@"Close"];
                ***REMOVED***else{
                    NSString* destinationPath = [NSString stringWithFormat:@"%@/%@", savedPath, [filePath lastPathComponent]];
                    
                    //rename if file already at path.
                    int x = 0;
                    while ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]){
                        x = 1;
                        NSString* ext = [destinationPath pathExtension];
                        destinationPath = [NSString stringWithFormat:@"%@ copy.%@", [destinationPath stringByDeletingPathExtension], ext];
                    ***REMOVED***
                    
                    [decryptedFile writeToFile:destinationPath atomically:YES];
                    
                    if (x == 1) {
                        [self desktopAlert:@"A copy of the file has been made!" message:@"The file already existed." button1:@"" button2:@"Close"];
                    ***REMOVED***
                    
                    [self desktopAlert:@"Success Downloading File!" message:@"The file has been downloaded and decrypted." button1:@"View" button2:@"Close"];
                ***REMOVED***
            ***REMOVED***
        ***REMOVED***;
        
        _downloadReq.errorBlock = ^(NSError *error) {
            NSString* error_message = [error localizedDescription] ;
            if(![error_message isEqual: @"Connection was cancelled."]){
                NSLog(@"Called errorBlock");
                [self finishedDownload:filePath friendUUID:friendUUID ref:ref newuser:true];
                NSLog(@"DOWNLOAD ERROR: %@", [error localizedDescription]);
                [self desktopAlert:@"Error Downloading File" message:error_message button1:@"" button2:@"Close"];
            ***REMOVED***
        ***REMOVED***;
        
        _downloadReq.downloadProgressBlock = ^(NSData *data, int64_t totalBytesReceived, int64_t totalBytesExpectedToReceive) {
            _totalBytes = totalBytesExpectedToReceive;
            _downloadPercent = ([@(totalBytesReceived) floatValue] / [@(totalBytesExpectedToReceive) floatValue]) * 100;
            NSLog(@"download_percent:%.1f%% of %lu",_downloadPercent, (unsigned long)_totalBytes);
        ***REMOVED***;
        
        [_downloadReq startAsynchronous];
    ***REMOVED***
***REMOVED***

-(id)getValueFromArray:(int)x array:(NSMutableArray*)array{
    NSString* val = @"";
    for(NSString* str in array){
        NSArray *explode = [str componentsSeparatedByString:@"|"];
        if([explode[1] intValue] == x){
            val = explode[0];
        ***REMOVED***
    ***REMOVED***
    
    return val;
***REMOVED***

-(void)finishedDownload:(NSString*)path friendUUID:(NSString*)friendUUID ref:(int)ref newuser:(bool)newuser{
    [self finishedDownload:path friendUUID:friendUUID ref:ref newuser:newuser hash:@""];
***REMOVED***

//returns key if it isn't a failed download
-(NSString*)finishedDownload:(NSString*)path friendUUID:(NSString*)friendUUID ref:(int)ref newuser:(bool)newuser hash:(NSString*)hash{
    
    NSLog(@"finished download");
    _downloadingPath = nil;
    _hasRequestedDownload = false;
    _isDownloading = false;
    [_files removeObject:[self getValueFromArray:ref array:_files]];
    [_keys removeObject:[self getValueFromArray:ref array:_keys]];
    
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/finishedDownload.php"];
    r.POSTDictionary = @{ @"path":path, @"user":_userCode, @"friendUUID": friendUUID, @"UUID":_uuid, @"hash":hash***REMOVED***;
    
    NSError *error = nil;
    NSString *body = [r startSynchronousWithError:&error];
    
    if(error != nil){
        NSLog(@"Error deleting file: %@",error);
        [self desktopAlert:@"E R R O R" message:@"Unable to delete file from server. It will be deleted within the hour anyway." button1:@"" button2:@"Close"];
    ***REMOVED***else{
        if([body length] == 1024){ //received key
            return body;
        ***REMOVED***else if(![body  isEqual: @"0"]){
            NSLog(@"failed to delete file:%@",body);
            [self desktopAlert:@"E R R O R" message:body button1:@"" button2:@"Close"];
        ***REMOVED***
    ***REMOVED***
    return @"";
***REMOVED***

#pragma mark - upload/send file

-(void)chooseFile{
    _uploadFilePath = [self adDIR:@"Choose the file you want to send!" buttonTitle:@"Choose" dirBool:NO fileBool:YES];
    if(_uploadFilePath){
        [self chooseFriend];
    ***REMOVED***
***REMOVED***

-(void)chooseFriend{
    [self sendToFriendView];
    _inputCode.stringValue = @"";
    [self showView];
***REMOVED***

int userLength = 7;
-(void)uploadFile{
    [submitButton setEnabled:false];
    NSString* path = _uploadFilePath;
    NSString* friendCode = [self cleanUpString:[_inputCode stringValue]];
    NSData* file = [NSData dataWithContentsOfFile:path];
    int fileSize = (int)[file length];
    float encryptedFileSize = [self bytesToEncrypted:fileSize];
    
    if ([friendCode length] == 0) {
        [self shakeLayer:_inputCode.layer];
        [self sendError:@"You need to enter your friends code!"];
    ***REMOVED***else if ([friendCode length] != userLength) {
        [self sendError:@"Your friend does not exist!"];
    ***REMOVED***else if(_userCode == friendCode){
        [self sendError:@"You can't send files to yourself..."];
    ***REMOVED***else if(![self fileIsPath:path]){
        //TODO zip if not already.
        [self sendError:@"Please Compress/zip folders!"];
    ***REMOVED***else if(!_isUploading){
        NSString* pass = nil;
        
        STHTTPRequest* r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/initUpload.php"];
        
        r.POSTDictionary = @{ @"user":_userCode, @"friend":friendCode, @"UUID":_uuid, @"filesize":[NSString stringWithFormat:@"%f",encryptedFileSize]***REMOVED***;
        
        NSError *error = nil;
        NSString *body = [r startSynchronousWithError:&error];
        NSString* firstLetter = [body substringToIndex:1];
        
        if([body length] == 2048){ //2048 char key to use to encrypt the file
            pass = body;
        ***REMOVED***else if([firstLetter  isEqual: @"1"]){
            [self sendError:@"ERROR (1): Please try create a new user."];
            [self desktopAlert:@"UUID is not registered!" message:@"Please create new user!" button1:@"" button2:@"Close"];
        ***REMOVED***else if([firstLetter  isEqual: @"2"]){
            [self sendError:@"ERROR (2): Please try create a new user."];
            [self desktopAlert:@"Code is not registered!" message:@"Please create new user!" button1:@"" button2:@"Close"];
        ***REMOVED***else if([firstLetter  isEqual: @"3"]){
            [self sendError:@"Your friend does not exist!"];
        ***REMOVED***else if([firstLetter  isEqual: @"4"]){
            [self sendError:[NSString stringWithFormat:@"The file is out of your %dMB limit! Click \"Add Credit\"",[self bytesToMega:(int)[body substringFromIndex:1]]]];
        ***REMOVED***else if([body  isEqual: @"5"]){
            [self sendError:@"You are already uploading a file to this user."];
        ***REMOVED***else{
            NSLog(@"error: %@ body: %@", error, body);
        ***REMOVED***
        
        if(pass != nil){
            NSData* encryptedFile = [self encryptFile:file password:pass];
            [self animatePlane];
            
            _isUploading = true;
            _uploadReq = nil;
            
            _uploadReq = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/upload.php"];
            
            _uploadReq.POSTDictionary = @{ @"user":_userCode, @"friend":friendCode, @"UUID":_uuid***REMOVED***;
            
            [_uploadReq addDataToUpload:encryptedFile parameterName:@"fileUpload" mimeType:@"application/octet-stream" fileName:[path lastPathComponent]];
            
            
            _uploadReq.completionBlock = ^(NSDictionary *headers, NSString *body) {
                if([body length] > 0){
                    NSString* firstLetter = [body substringToIndex:1];
                    body = [body substringFromIndex:1];
                    
                    NSLog(@"major error uploading file:%@ body:%@",firstLetter , body);
                    
                    if([firstLetter  isEqual: @"1"]){
                        [self completedUpload];
                        [self desktopAlert:@"Success!" message:@"File has been sent and encrypted!" button1:@"" button2:@"Close"];
                    ***REMOVED***else{
                        [self completedUpload];
                        if([firstLetter  isEqual: @"2"]){
                            [self desktopAlert:@"File Too Big!" message:[NSString stringWithFormat:@"The file is out of your %@MB limit! Would you like to upgrade?",body] button1:@"Yes" button2:@"No"];
                        ***REMOVED***else if([firstLetter  isEqual: @"3"]){
                            [self desktopAlert:@"Major Unknown Code!" message:@"I am sorry but your friend does not exist!" button1:@"" button2:@"Close"];
                        ***REMOVED***else if([firstLetter  isEqual: @"4"]){
                            [self desktopAlert:@"File already uploaded!" message:@"That same file name has already been sent to your friend!" button1:@"" button2:@"Close"];
                        ***REMOVED***else if([firstLetter  isEqual: @"5"]){
                            [self desktopAlert:@"No file uploaded!" message:@"Please try again!" button1:@"" button2:@"Close"];
                        ***REMOVED***else if([firstLetter  isEqual: @"6"]){
                            [self desktopAlert:@"Error Uploading File!" message:@"This is probably due to expired friend. Please try again!" button1:@"" button2:@"Close"];
                        ***REMOVED***else if([firstLetter  isEqual: @"7"]){
                            [self desktopAlert:@"Friend already has a file!" message:@"Your friend has to download their other pending file first." button1:@"" button2:@"Close"];
                        ***REMOVED***else{
                            NSLog(@"major error uploading file:%@%@",firstLetter , body);
                        ***REMOVED***
                    ***REMOVED***
                ***REMOVED***
            ***REMOVED***;
            
            _uploadReq.errorBlock = ^(NSError *error) {
                [self completedUpload];
                //when the request isn't a manual cancel.
                if ([[NSString stringWithFormat:@"%@",error] rangeOfString:@"STHTTPRequest Code=1 \"Connection"].location == NSNotFound) {
                    NSLog(@"Error: %@",error);
                    [self desktopAlert:@"Network error!" message:@"Please check your internet and try again." button1:@"" button2:@"Close"];
                ***REMOVED***
            ***REMOVED***;
            
            _uploadReq.uploadProgressBlock = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
                _uploadPercent = ([@(totalBytesWritten) floatValue] / [@(totalBytesExpectedToWrite) floatValue]) * 100;
                _totalUploadBytes = (int)totalBytesExpectedToWrite;
                //NSLog(@"upload: %f",_uploadPercent);
            ***REMOVED***;
            
            
            [_uploadReq startAsynchronous];
        ***REMOVED***
    ***REMOVED***
***REMOVED***

-(void)completedUpload{
    _uploadFilePath = nil;
    _uploadPercent = 0;
    _totalUploadBytes = 0;
    _isUploading = false;
***REMOVED***

-(void)sendError:(NSString*)message{
    [submitButton setEnabled:true];
    
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
***REMOVED***

-(void)fadeOutErrorText{
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0];
    fadeOutAnimation.duration = 0.4;
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    [_errorMessage.layer addAnimation:fadeOutAnimation forKey:nil];
    //_errorMessage.stringValue = @"";
***REMOVED***

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

-(void)animatePlane{
    CABasicAnimation *rightAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    [rightAnimation setToValue:[NSNumber numberWithFloat:230]];
    [rightAnimation setBeginTime:0.0];
    [rightAnimation setDuration:0.6];
    
    
    CABasicAnimation *fall = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [fall setToValue:[NSNumber numberWithFloat:20]];
    [fall setBeginTime:0.1];
    [fall setDuration:0.6];
    
    //DOESN'T WORK
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotate setToValue:[NSNumber numberWithFloat:DEGREES_RADIANS(20)]];
    NSLog(@"%f",DEGREES_RADIANS(5));
    [rotate setBeginTime:0.1];
    [rotate setDuration:0.6];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setDuration:0.6];
    [group setAnimations:[NSArray arrayWithObjects:rightAnimation, fall, rotate, nil]];
    
    [submitButton.layer addAnimation:group forKey:nil];
***REMOVED***

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
        ***REMOVED***);
    ***REMOVED***
***REMOVED***

//Called when there has been an error downloading the file or the user does not want the file.
-(bool)deleteFileFromServer:(NSString*)friendCode userCode:(NSString*)userCode path:(NSString*)path{
    if(_userCode){
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/deleteFile.php"];
        r.POSTDictionary = @{ @"path":path, @"user":userCode, @"friend": friendCode, @"UUID":_uuid***REMOVED***;
        
        NSError *error = nil;
        NSString *body = [r startSynchronousWithError:&error];
        
        if(error != nil){
            NSLog(@"Error deleting file: %@",error);
            [self desktopAlert:@"E R R O R" message:@"Unable to delete file from server. It will be deleted within the hour anyway." button1:@"" button2:@"Close"];
        ***REMOVED***else{
            NSString* firstLetter = [body substringToIndex:1];
            body = [body substringFromIndex:1];
            if([firstLetter  isEqual: @"0"]){
                return true;
            ***REMOVED***else{
                NSLog(@"failed to delete file:%@",body);
            ***REMOVED***
        ***REMOVED***
    ***REMOVED***
    return false;
***REMOVED***

#pragma mark - encrypt/decrypt file
-(NSData*)encryptFile:(NSData*)data password:(NSString*)password{
    NSError *error = nil;
    NSData *encrypted_data = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:&error];
    if (error != nil) {
        NSLog(@"Encryption ERROR:%@", error);
        return nil;
    ***REMOVED***else{
        return encrypted_data;
    ***REMOVED***
***REMOVED***

-(NSData*)decryptFile:(NSData*)data password:(NSString*)password{
    NSError *error = nil;
    NSData *decrypted_data = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:password error:&error];
    if (error != nil) {
        NSLog(@"Decryption ERROR:%@", error);
        return nil;
    ***REMOVED***else{
        return decrypted_data;
    ***REMOVED***
***REMOVED***

#pragma mark - Send to friend code
-(void)sendToFriendView{
    [self createDefaultWindow];
    
    //change labels
    [_label setStringValue:@"E N T E R  F R I E N D S  C O D E"];
    [_labelShaddow setStringValue:_label.stringValue];
    
    int button_width = 50;
    [submitButton setFrame:CGRectMake((window_width/2) - (button_width/2), (window_height/2)-65, button_width, 30)];
    submitButton.cursor = [NSCursor pointingHandCursor];
    [submitButton setEnabled:true];
    [submitButton setAction:@selector(uploadFile)];
    [submitButton setImage:[NSImage imageNamed:@"send.png"]];
    submitButton.alternateImage = [NSImage imageNamed:@"send_hover.png"];
    [submitButton setImageScaling:NSImageScaleProportionallyDown];
    [submitButton setButtonType:NSMomentaryChangeButton];
    [submitButton setBordered:NO];
    [submitButton updateTrackingAreas];
    
    _inputCode.stringValue = @"";
    
    [_view addSubview:_errorMessage];
    
    [self showView];
***REMOVED***

#pragma mark - Choose custom code
-(void)enterPermCodeView{
    [self createDefaultWindow];
    
    //change labels
    [_label setStringValue:@"E N T E R  C U S T O M  C O D E"];
    [_labelShaddow setStringValue:_label.stringValue];
    [submitButton setTitle:@"Submit"];
    [submitButton setAction:@selector(setPermCode)];
    _inputCode.stringValue = @"";
    
    [self showView];
***REMOVED***

-(void)setPerm{
    _inputCode.stringValue = @"";
    
    if(![self hasPermUser]){
        //stop being static
        if([self bytesToMega:_bandwidthLeft] == 5000){
            [self enterPermCodeView];
        ***REMOVED***else{
            [self setPermCode:true];
        ***REMOVED***
    ***REMOVED***else{
        [self setPermCode:false];
    ***REMOVED***
***REMOVED***

-(void)setPermCode:(bool)setPerm{
    
    _isSettingStatic = true;
    [self setRequestingCodeMenu];
    
    NSString* customCode = @"";
    if(setPerm){
        if([_inputCode.stringValue length] > 0){
            customCode = [self cleanUpString:_inputCode.stringValue];
        ***REMOVED***else{
            customCode = @"0"; //remove perm code
        ***REMOVED***
        [_window close];
    ***REMOVED***else{
        customCode = @"0"; //remove perm code
    ***REMOVED***
    
    NSString* proCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"pro_code"];
    
    //add static ID
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/setPermenantUser.php"];
    
    r.POSTDictionary = @{ @"customCode":customCode, @"UUID":_uuid, @"pro_code":proCode***REMOVED***;
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        _isSettingStatic = false;
        NSLog(@"permenantUserID.php body:%@",body);
        if([body length] > 0){
            NSString* firstLetter = [body substringToIndex:1];
            body = [body substringFromIndex:1];
            if([firstLetter  isEqual: @"0"]){
                [self desktopAlert:@"Success!" message:[NSString stringWithFormat:@"You now have the permenant code: %@", body] button1:@"" button2:@"close"];
                [[NSUserDefaults standardUserDefaults] setObject:body forKey:@"perm_user"];
            ***REMOVED***else if([firstLetter  isEqual: @"1"]){
                [self desktopAlert:@"Success!" message:@"You codes will now go back to being dynamic" button1:@"" button2:@"close"];
            ***REMOVED***else if([firstLetter  isEqual: @"6"]){
                [self desktopAlert:@"Error!" message:[NSString stringWithFormat:@"Custom code '%@' might already be in use.", body] button1:@"" button2:@"close"];
            ***REMOVED***else if([firstLetter  isEqual: @"2"]){
                NSLog(@"error");
                [self desktopAlert:@"Error!" message:@"Custom code must be 7 characters and only contain letters and numbers." button1:@"" button2:@"close"];
            ***REMOVED***
            
            [self createNewUser];
        ***REMOVED***
    ***REMOVED***;
    
    r.errorBlock = ^(NSError *error) {
        _isSettingStatic = false;
        NSLog(@"Error: %@",error);
    ***REMOVED***;
    
    [r startAsynchronous];
***REMOVED***

-(bool)hasPermUser{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user"] != nil){
        return true;
    ***REMOVED***else{
        return false;
    ***REMOVED***
***REMOVED***


#pragma mark - Enter Pro code
-(void)enterProDetesView{
    [self createDefaultWindow];
    
    //change labels
    [_label setStringValue:@"E N T E R  R E G I S T R A T I O N  K E Y "];
    [_labelShaddow setStringValue:_label.stringValue];
    
    [submitButton setAction:@selector(checkPro)];
    _inputCode.stringValue = @"";
    
    [self showView];
***REMOVED***

-(void)checkPro{
    NSString* proCode = [_inputCode.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([proCode length] != 100){
        [self desktopAlert:@"Registration Key Invalid!" message:@"Make sure codes are case sensitive." button1:@"" button2:@"Close"];
    ***REMOVED***else if(!_isGettingRegistrationCode){
        [_window close];
        
        _isGettingRegistrationCode = true;
        
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/regPro.php"];
        
        r.POSTDictionary = @{ @"UUID":_uuid, @"user":_userCode, @"pro_code":[self cleanUpString:proCode] ***REMOVED***;
        
        r.completionBlock = ^(NSDictionary *headers, NSString *body) {
            _isGettingRegistrationCode = false;
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"pro_code"];
            if ([body  isEqual: @"0"]) {
                [self desktopAlert:@"Success!" message:@"You now have a pro account" button1:@"" button2:@"Close"];
                
                //store reg code
                [[NSUserDefaults standardUserDefaults] setObject:proCode forKey:@"pro_code"];
                
                [self createNewUser];
            ***REMOVED***else if ([body  isEqual: @"2"]) {
                [self desktopAlert:@"Registration Key does not exist!" message:@"Make sure codes are case sensitive." button1:@"" button2:@"Close"];
            ***REMOVED***else{
                NSLog(@"key body: %@",body);
                [self desktopAlert:@"Incorrect key!" message:@"This key has either expired, already been used or is incorrect." button1:@"" button2:@"Close"];
            ***REMOVED***
        ***REMOVED***;
        
        r.errorBlock = ^(NSError *error) {
            NSLog(@"Error: %@",error);
        ***REMOVED***;
        
        [r startAsynchronous];
    ***REMOVED***
***REMOVED***

-(bool)hasProCode{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"pro_code"] length] == 100){
        return true;
    ***REMOVED***
    return false;
***REMOVED***

-(void)openFilePath:(NSString*)path file:(NSString*)file{
    NSString* fullPath = [NSString stringWithFormat:@"%@/%@", path, file];
    [[NSWorkspace sharedWorkspace] selectFile:fullPath inFileViewerRootedAtPath:fullPath];
    
***REMOVED***

#pragma mark - icon animation

-(void)iconAnimation{
    if(_animateTimer){
        [_animateTimer invalidate];
        _animateTimer = nil;
    ***REMOVED***
    
    
    if(_isDownloading || _isUploading){
        _animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                         target:self selector:@selector(animateUploadOrDownload) userInfo:nil
                                                        repeats:YES];
    ***REMOVED***else{
        opacityCnt = 0;
        _lastAnimate = 1;
        _animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                         target:self selector:@selector(animateLoadUser) userInfo:nil
                                                        repeats:YES];
    ***REMOVED***
    
    NSRunLoop * rl = [NSRunLoop mainRunLoop];
    [rl addTimer:_animateTimer forMode:NSRunLoopCommonModes];
***REMOVED***

int opacityCnt;
-(void)animateLoadUser{
    int x = 0;
    
    opacityCnt++;
    if(opacityCnt > 20){
        opacityCnt = 0;
    ***REMOVED***
    
    if(opacityCnt > 10){
        x = 10 - (opacityCnt - 10);
    ***REMOVED***else{
        x = opacityCnt;
    ***REMOVED***
    
    NSImage *image = [NSImage imageNamed:@"loading.png"];
    NSImage *opacitatedImage = [[NSImage alloc] initWithSize:[image size]];
    
    [opacitatedImage lockFocus];
    [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.1 * x];
    [opacitatedImage unlockFocus];
    
    statusItemView.image = opacitatedImage;
***REMOVED***

int animateY;
-(void)animateUploadOrDownload{
    animateY++;
    
    int x = animateY;
    if(x > 19){
        animateY = 0;
    ***REMOVED***
    
    NSImage *image2;
    if(_isUploading){
        _lastAnimate = 2;
        image2 = [NSImage imageNamed:@"upload.png"];
        x = (2 * animateY) - 25;
    ***REMOVED***else{
        _lastAnimate = 3;
        image2 = [NSImage imageNamed:@"download.png"];
        x = 25 - (2 * animateY);
    ***REMOVED***
    
    NSImage *image = [NSImage imageNamed:@"icon.png"];
    NSImage *arrowImage = [[NSImage alloc] initWithSize:[image size]];
    
    [arrowImage lockFocus];
    [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [image2 drawAtPoint:NSMakePoint(0,x) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [arrowImage unlockFocus];
    
    statusItemView.image = arrowImage;
***REMOVED***

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
***REMOVED***

#pragma mark - phonetic stuff

-(void)showPhonetic{
    if([self isPhonetic]){
        NSLog(@"mark as false");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"phonetic"];
    ***REMOVED***else{
        NSLog(@"mark as true");
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"phonetic"];
    ***REMOVED***
    
    [self setDefaultMenu];
***REMOVED***

-(BOOL)isPhonetic{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"phonetic"];
***REMOVED***

-(NSString*)stringToPhonetic:(NSString*)string{
    NSString* phonetic = @"";
    unsigned int len = (int)[string length];
    unsigned short buffer[len];
    
    [string getCharacters:buffer range:NSMakeRange(0, len)];
    
    for(int i = 0; i < len; ++i) {
        char current = buffer[i];
        phonetic = [NSString stringWithFormat:@"%@ %@",phonetic, [self letterToPhonetic:current]];
    ***REMOVED***
    return [phonetic stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
***REMOVED***

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
    ***REMOVED***
***REMOVED***

#pragma mark - socketRocket

- (void)checkSocket{
    if(!_authedSocket && _connectedToSocket){
        [_webSocket send:_uuid];
    ***REMOVED***else if(!_userCode){
        [self createNewUser];
    ***REMOVED***
***REMOVED***

- (void)openSocket
{
    _isCreatingUser = false;
    
    _connectedToSocket = false;
    _authedSocket = false;
    
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://s.transferme.it"]];
    _webSocket.delegate = (id)self;
    
    [_webSocket open];
***REMOVED***

-(void)closeSocket{
    [self closeSocket:true];
***REMOVED***

-(void)closeSocket:(bool)showNoInternetMenu{
    NSLog(@"closed socket");
    _connectedToSocket = false;
    _authedSocket = false;
    _hasInternet = false;
    _userCode = nil;
    if(showNoInternetMenu){
        [self setNoInternetMenu];
    ***REMOVED***
***REMOVED***

bool receivedPong = false;
- (void)sendPing{
    if(_connectedToSocket){
        receivedPong = false;
        [_webSocket sendPing:nil];
        
        //check for pong in 1 second
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [NSThread sleepForTimeInterval:1.0f];
            if(!receivedPong){
                NSLog(@"Did not receive pong");
                [self closeSocket];
            ***REMOVED***
        ***REMOVED***);
    ***REMOVED***
***REMOVED***

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    _connectedToSocket = true;
    [_webSocket send:[NSString stringWithFormat:@"%@|%@", _uuid, [self getUUIDKey]]];
***REMOVED***

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"The websocket handshake/connection failed with an error: %@", error);
    [self closeSocket];
***REMOVED***


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(nonnull NSString *)string
{
    [self receivedMessage:string];
***REMOVED***

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed because: %@",reason);
    [self closeSocket];
    _webSocket = nil;
***REMOVED***

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    receivedPong = true;
***REMOVED***

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
            ***REMOVED***
            // Docs for LSSharedFileListItemResolve say we're responsible
            // for releasing the CFURLRef that is returned
            if (thePath != NULL) CFRelease(thePath);
        ***REMOVED***
    ***REMOVED***
    if (loginItemsArray != NULL) CFRelease(loginItemsArray);
    
    return found;
***REMOVED***

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
            ***REMOVED***
            CFRelease(loginListRef);
        ***REMOVED***
        [_showOnStartupItem setState:NSOnState];
    ***REMOVED***
***REMOVED***

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
    ***REMOVED***
***REMOVED***

-(void)openOnStartup{
    if(![self loginItemExistsWithLoginItemReference]){
        [self enableLoginItemWithURL];
    ***REMOVED***else{
        [self removeLoginItemWithURL];
    ***REMOVED***
***REMOVED***


#pragma mark - major error dealer
- (void)handleError:(NSString*)body location:(NSString*)location{
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/error.php"];
    
    r.POSTDictionary = @{ @"body":body, @"location": location***REMOVED***;
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
    ***REMOVED***;
    
    r.errorBlock = ^(NSError *error) {
        //ironic error
    ***REMOVED***;
    
    [r startAsynchronous];
***REMOVED***

- (NSString *)hash:(NSData *)data{
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    ***REMOVED***
    
    return output;
***REMOVED***

#pragma mark - quit app
-(void)quitApp{
    [NSApp terminate:self];
***REMOVED***
@end
