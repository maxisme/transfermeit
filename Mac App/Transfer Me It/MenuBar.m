//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import "MenuBar.h"

#import "CustomVars.h"
#import "CustomFunctions.h"

#import "PopUpWindow.h"
#import "AppDelegate.h"

@implementation MenuBar

- (void)setMenu:(NSMenu *)menu {
    [menu setDelegate:self];
    [super setMenu:menu];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //TODO: test if works without NSURLPboardType
        NSArray *dragTypes = @[NSURLPboardType, NSFileContentsPboardType, NSFilenamesPboardType];
        [self registerForDraggedTypes:dragTypes];
    }
    
    return self;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem window:(PopUpWindow*)w{
    _w = w;
    
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [self initWithFrame:itemRect];
    
    if (self != nil)
    {
        _statusItem = statusItem;
        _statusItem.view = self;
        [self setImage:[NSImage imageNamed:@"loading.png"]];
        [self createMenu];
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [_statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
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
    if(![_w.viewName isEqual: @"dlv"]){
        [_w closeWindow];
        NSMenu *menu = [super menu];
        [_statusItem popUpStatusItemMenu:menu];
        [NSApp sendAction:self.action to:self.target from:self];
    }
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
    if(self.image == [NSImage imageNamed:@"icon.png"]){ // no menu failure
        [self setImage:[NSImage imageNamed:@"drag.png"]];
        
        if ([[sender draggingPasteboard] availableTypeFromArray:@[NSFilenamesPboardType]]) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    [self setImage:[NSImage imageNamed:@"icon.png"]];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    //return to original icon image
    [self setImage:[NSImage imageNamed:@"icon.png"]];
    
    // get file path from drag to menu icon operation
    NSPasteboard *pb = [sender draggingPasteboard];
    if([[pb pasteboardItems] count] != 1) return NO;
    NSURL *url = [NSURL URLFromPasteboard:pb];
    NSString* filePath = url.path;
    
    if(filePath){
        [_w setSendToFriendView:[[self valueForKey:@"window"] frame] filePath:filePath];
    }
    
    return NO;
}

- (void)createMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    
    _itemOne = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemOne];
    
    _seperator1 = [NSMenuItem separatorItem];
    [menu addItem:_seperator1];
    
    _itemTwo = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemTwo];
    
    _seperator2 = [NSMenuItem separatorItem];
    [menu addItem:_seperator2];
    
    _itemThree = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemThree];
    
    _seperator3 = [NSMenuItem separatorItem];
    [menu addItem:_seperator3];
    
    _itemFour = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemFour];
    
    _seperator4 = [NSMenuItem separatorItem];
    [menu addItem:_seperator4];
    
    _itemFive = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemFive];
    
    _seperator5 = [NSMenuItem separatorItem];
    [menu addItem:_seperator5];
    
    _itemSix = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [menu addItem:_itemSix];
    
    
    // ----- CONSTANT IN ALL MENUS -----
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* quit = [[NSMenuItem alloc] initWithTitle:@"Quit Transfer Me It" action:@selector(quitApp) keyEquivalent:@""];
    [quit setTarget:self];
    [menu addItem:quit];
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    
    [self setMenu:menu];
}

-(void)resetMenu{
    if(_animationTimer){
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
    
    [_itemOne setHidden:true];
    _itemOne.action = nil;
    [_itemOne setEnabled:false];
    [_seperator1 setHidden:true];
    
    [_itemTwo setHidden:true];
    _itemTwo.action = nil;
    [_itemTwo setEnabled:false];
    _itemTwo.keyEquivalent = @"";
    [_seperator2 setHidden:true];
    
    [_itemThree setHidden:true];
    _itemThree.action = nil;
    _itemThree.keyEquivalent = @"";
    [_itemThree setEnabled:false];
    [_seperator3 setHidden:true];
    
    [_itemFour setHidden:true];
    _itemFour.action = nil;
    [_itemFour setEnabled:false];
    [_seperator4 setHidden:true];
    
    [_itemFive setHidden:true];
    _itemFive.action = nil;
    [_itemFive setEnabled:false];
    [_itemFive setSubmenu:nil];
    [_seperator5 setHidden:true];
    
    [_itemSix setHidden:true];
    _itemSix.action = nil;
    [_itemSix setEnabled:false];
    [_itemSix setSubmenu:nil];
}

#pragma mark - menus

-(void)setdownloadMenu:(NSString*)fileName{
    _menuName = @"download";
    [self resetMenu];
    [self iconAnimation:@"downloading"];
    
    
    _itemOne.title = [NSString stringWithFormat:@"Downloading: %@", [CustomFunctions overflowString:fileName size:20]];
    [_itemOne setHidden:false];
    
    [_itemTwo setHidden:false];
    [_seperator2 setHidden:false];
    
    _itemThree.title = @"Cancel Download";
    _itemThree.action = @selector(cancelDownload);
    [_itemThree setEnabled:true];
    [_itemThree setHidden:false];
}

-(void)setUploadMenu:(NSString*)fileName{
    _menuName = @"upload";
    [self resetMenu];
    [self iconAnimation:@"uploading"];
    
    
    _itemOne.title = [NSString stringWithFormat:@"Uploading: %@", [CustomFunctions overflowString:fileName size:20]];
    [_itemOne setHidden:false];
    
    [_itemTwo setHidden:false];
    [_seperator2 setHidden:false];
    
    _itemThree.title = @"Cancel Upload";
    _itemThree.action = @selector(cancelUpload);
    [_itemThree setEnabled:true];
    [_itemThree setHidden:false];
}

-(void)setErrorMenu:(NSString*)title{
    _menuName = @"error";
    [self resetMenu];
    
    [self setImage:[NSImage imageNamed:@"alert.png"]];
    _itemOne.title = title;
    [_itemOne setHidden:false];
}

-(void)setRequestingCodeMenu{
    _menuName = @"requesting";
    [self resetMenu];
    [self iconAnimation:@"loading"];
    
    _itemOne.title = @"Requesting Unique Code...";
    [_itemOne setHidden:false];
}

-(void)setDefaultMenu:(NSString*)userCode bandwidthLeft:(unsigned long long)bandwidthLeft maxFileUpload:(unsigned long long)maxFileUpload maxTime:(int)maxTime wantedTime:(int)wantedTime userTier:(int)userTier timeLeft:(NSDate*)timeLeft{
    _menuName = @"default";
    [self resetMenu];
    
    [_animationTimer invalidate];
    _animationTimer = nil;
    
    [self setImage:[NSImage imageNamed:@"icon.png"]];
    
    //handle seperators
    [_seperator4 setHidden:false];
    [_seperator5 setHidden:false];
    
    //allow for do not disturb to be shown if it is turned off
    _itemOne.title = @"Please turn off 'Do Not Disturb'!";
    [_itemOne setTarget:self];
    
    //get time left
    [_itemTwo setTarget:self];
    [_itemTwo setHidden:false];
    
    _itemThree.title = userCode;
    _itemThree.action = @selector(copyCode);
    _itemThree.keyEquivalent = @"c";
    [_itemThree setHidden:false];
    [_itemThree setTarget:self];
    [_itemThree setEnabled:true];
    
    //_itemFour
    if([CustomFunctions getStoredBool:@"phonetic"]){
        //small font
        NSFont *systemFont = [NSFont systemFontOfSize:9.0f];
        NSDictionary * fontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:systemFont, NSFontAttributeName, nil];
        NSMutableAttributedString *libTitle = [[NSMutableAttributedString alloc] initWithString:[CustomFunctions stringToPhonetic:userCode] attributes:fontAttributes];
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
    if(bandwidthLeft > 0) [_itemFive setEnabled:true];
    
    //_itemSix
    //options menu
    [_itemSix setSubmenu: [self optionsWithBandwidthLeft:bandwidthLeft maxFileUpload:maxFileUpload maxTime:maxTime wantedTime:wantedTime userTier:userTier]];
    _itemSix.title = @"Settings...";
    [_itemSix setHidden:false];
    [_itemSix setEnabled:true];
}

- (NSMenu *)optionsWithBandwidthLeft:(unsigned long long)bandwidthLeft maxFileUpload:(unsigned long long)maxFileUpload maxTime:(int)maxTime wantedTime:(int)wantedTime userTier:(int)userTier{
    NSMenu *menu = [[NSMenu alloc] init];
    
    //CODE STUFF
    NSMenuItem* codeItem = [[NSMenuItem alloc] initWithTitle:@"Code" action:nil keyEquivalent:@""];
    [codeItem setAttributedTitle:[self stringToCentre:codeItem.title]];
    [codeItem setEnabled:false];
    [menu addItem:codeItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* phoneticOptionItem = [[NSMenuItem alloc] initWithTitle:@"Show phonetics" action:@selector(showPhonetic) keyEquivalent:@""];
    [phoneticOptionItem setTarget:self];
    if([CustomFunctions getStoredBool:@"phonetic"]){
        [phoneticOptionItem setState:NSOnState];
    }
    [menu addItem:phoneticOptionItem];
    
    NSMenuItem* createNewCode = [[NSMenuItem alloc] initWithTitle:@"Create a new code for..." action:nil keyEquivalent:@""];
    [createNewCode setSubmenu: [self timeIntervalsWithMaxTime:maxTime wantedTime:wantedTime userTier:userTier]];
    [menu addItem:createNewCode];
    
    [menu addItem:[NSMenuItem separatorItem]];
    //DOWNLOAD STUFF
    
    NSMenuItem* saveItem = [[NSMenuItem alloc] initWithTitle:@"Saving Incoming Files" action:nil keyEquivalent:@""];
    [saveItem setAttributedTitle:[self stringToCentre:saveItem.title]];
    [saveItem setEnabled:false];
    [menu addItem:saveItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* saveLocation = [[NSMenuItem alloc] initWithTitle:@"Set a Default Download Location" action:@selector(setAutoSaveLocation) keyEquivalent:@""];
    [saveLocation setTarget:self];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"saveLocation"] != nil){
        [saveLocation setState:NSOnState];
    }
    [menu addItem:saveLocation];
    
    NSMenuItem* downloadAutomatically = [[NSMenuItem alloc] initWithTitle:@"Automatically Download Incoming Files" action:@selector(setDownloadAuto) keyEquivalent:@""];
    [downloadAutomatically setTarget:self];
    if([CustomFunctions getStoredBool:@"autoDownload"]){
        [downloadAutomatically setState:NSOnState];
    }
    [menu addItem:downloadAutomatically];
    
    
    //PRO STUFF
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* accntItem = [[NSMenuItem alloc] initWithTitle:@"Account" action:nil keyEquivalent:@""];
    [accntItem setAttributedTitle:[self stringToCentre:accntItem.title]];
    [accntItem setEnabled:false];
    [menu addItem:accntItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSString*bandwidthLeftStr = [NSByteCountFormatter stringFromByteCount:bandwidthLeft countStyle:NSByteCountFormatterCountStyleFile];
    NSMenuItem* bw = [[NSMenuItem alloc] init];
    [bw setTarget:self];
    [bw setEnabled:NO];
    if(userTier > 0){
        [bw setTitle:[NSString stringWithFormat:@"Bandwidth: %@", bandwidthLeftStr]];
    }else{
        [bw setTitle:[NSString stringWithFormat:@"Todays Bandwidth: %@", bandwidthLeftStr]];
    }
    [menu addItem:bw];
    
    NSString*maxFileUploadStr = [NSByteCountFormatter stringFromByteCount:maxFileUpload countStyle:NSByteCountFormatterCountStyleFile];
    NSMenuItem* fs = [[NSMenuItem alloc] init];
    [fs setTarget:self];
    [fs setEnabled:NO];
    [fs setTitle:[NSString stringWithFormat:@"Max File Upload Size: %@", maxFileUploadStr]];
    [menu addItem:fs];
    
    NSMenuItem* addCredit = [[NSMenuItem alloc] initWithTitle:@"Purchase Upload Credit" action:@selector(goPro) keyEquivalent:@""];
    [addCredit setTarget:self];
    [menu addItem:addCredit];
    
    NSMenuItem* regKey = [[NSMenuItem alloc] initWithTitle:@"Enter Credit Key" action:@selector(enterProDetesView) keyEquivalent:@""];
    [regKey setTarget:self];
    [menu addItem:regKey];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    
    NSMenuItem* extraItem = [[NSMenuItem alloc] initWithTitle:@"Extras" action:nil keyEquivalent:@""];
    [extraItem setAttributedTitle:[self stringToCentre:extraItem.title]];
    [extraItem setEnabled:false];
    [menu addItem:extraItem];
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* showOnStartupItem = [[NSMenuItem alloc] initWithTitle:@"Start Transfer Me It at login" action:@selector(openOnStartup) keyEquivalent:@""];
    [showOnStartupItem setTarget:self];
    
    if([CustomFunctions doesOpenOnStartup]){
        [showOnStartupItem setState:NSOnState];
    }else{
        [showOnStartupItem setState:NSOffState];
    }
    [menu addItem:showOnStartupItem];
    
    NSMenuItem* update = [[NSMenuItem alloc] initWithTitle:@"Check for updates..." action:@selector(checkForUpdate) keyEquivalent:@""];
    [update setTarget:self];
    [menu addItem:update];
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    return menu;
}

-(NSAttributedString*)stringToCentre:(NSString*)string{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    return attributedString;
}

- (NSMenu *)timeIntervalsWithMaxTime:(int)maxTime wantedTime:(int)wantedTime userTier:(int)userTier {
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSMutableArray *times = [NSMutableArray array];
    
    //array numbers
    for(int time = 1; time <= 60; time++){
        time += 4;
        if(maxTime >= time) [times addObject:[NSString stringWithFormat:@"%d", time]];
    }

    for (NSNumber *n in times) {
        int x = [n intValue];
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%d Minutes",x] action:@selector(setTime:) keyEquivalent:@""];
        [item setRepresentedObject:n];
        [item setTarget:self];
        
        //tick if selected
        if(x == wantedTime){
            [item setState:NSOnState];
        }
        
        [menu addItem:item];
    }
    
    // allow user to choose for code that will last forever (not an acount [file will be purged at end of time])
    if(userTier > 1){
        [menu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem* permUserItem = [[NSMenuItem alloc] initWithTitle:@"Ever" action:@selector(setPerm:) keyEquivalent:@""];
        [permUserItem setRepresentedObject:[NSString stringWithFormat:@"%d", userTier]];
        [permUserItem setTarget:self];
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user_code"] != nil){
            [permUserItem setState:NSOnState];
        }
        [menu addItem:permUserItem];
    }
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    return menu;
}

-(void)cancelUpload{
    [CustomFunctions sendNotificationCenter:nil name:@"cancel-upload"];
}
-(void)cancelDownload{
    [CustomFunctions sendNotificationCenter:nil name:@"cancel-download"];
}

-(void)setProgressInfo:(NSString*)message{
    [_itemTwo setTitle:message];
}

// asks the User class to re initiate default menu using update variables
-(void)setDMenu{
    [CustomFunctions sendNotificationCenter:nil name:@"set-default-menu"];
}

-(void)setTime:(NSMenuItem*)sender{
    [CustomFunctions sendNotificationCenter:sender.representedObject name:@"create-user-menu"];
}

-(void)setMenuTime:(NSDate*)time{
    NSString* time_left = [[CustomVars dateFormat] stringFromDate:time];
    if([time_left isEqual: @"00:00"]){
        NSLog(@"create a new user!");
        [CustomFunctions sendNotificationCenter:nil name:@"create-user"];
    }
    _itemTwo.title = time_left;
}

-(void)setTurnOffDND:(bool)DNDIson{
    if(DNDIson){
        [_itemOne setHidden:false];
    }else{
        [_itemOne setHidden:true];
    }
}

#pragma mark - menu actions
- (void)goPro{
    [CustomFunctions goPro];
}

-(void)chooseFile{
    NSString* filePath = [CustomFunctions choosePathWindow:@"Choose the file you want to send!" buttonTitle:@"Choose" allowDir:NO allowFile:YES];
    if(filePath){
        [_w setSendToFriendView:[[self valueForKey:@"window"] frame] filePath:filePath];
    }else{
        NSLog(@"No path was selected!");
    }
}

-(void)quitApp{
    [CustomFunctions quit];
}

-(void)enterProDetesView{
    [_w setEnterRegistrationKeyView:[[self valueForKey:@"window"] frame]];
}

-(void)setPerm:(id)sender{
    int tier = [[sender representedObject] intValue];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"perm_user_code"] == nil && tier == 3){
        [_w setEnterPermCodeView:[[self valueForKey:@"window"] frame]];
    }else{
        // should remove perm user or add random one
        [_w togglePermenantUser];
    }
}

-(void)checkForUpdate{
    NSLog(@"");
    [CustomFunctions checkForUpdate:true];
}

-(void)copyCode{
    [CustomFunctions copyText:_itemThree.title];
}

-(void)setAutoSaveLocation{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"saveLocation"] != NULL){
        // toggle remove save location
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"saveLocation"];
        // remove should auto download
        if([CustomFunctions getStoredBool:@"autoDownload"]) [CustomFunctions setStoredBool:@"autoDownload" b:false];
    }else{
        //set save location
        NSString* path = [CustomFunctions choosePathWindow:@"Choose where you would like your files to automatically be saved" buttonTitle:@"Select" allowDir:true allowFile:false];
        [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"saveLocation"];
    }
    
    // reset menu showing new changes
    [self setDMenu];
}

-(void)setDownloadAuto{
    if([CustomFunctions getStoredBool:@"autoDownload"]){
        // toggle remove autodownload option
        [CustomFunctions setStoredBool:@"autoDownload" b:false];
    }else{
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"saveLocation"] == NULL) [self setAutoSaveLocation];
        
        //check again incase user pressed cancel on choosing location
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"saveLocation"] != NULL){
            //set auto download
            [CustomFunctions setStoredBool:@"autoDownload" b:true];
        }
    }
    
    // reset menu with showing new changes
    [self setDMenu];
}

- (void)showPhonetic{
    [CustomFunctions setStoredBool:@"phonetic" b:![CustomFunctions getStoredBool:@"phonetic"]];
    
    // reset menu showing new changes
    [self setDMenu];
}



#pragma mark - icon animations
-(void)iconAnimation:(NSString*)type{
    if(_animationTimer){
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
    
    if([[[CustomVars iconAnimations] objectForKey:type] isEqual: @1]){
        //creating new user animation
        opacityCnt = 0;
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                           target:self selector:@selector(animateLoading) userInfo:nil
                                                          repeats:YES];
    }else{
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                           target:self selector:@selector(animateArrow:) userInfo:type
                                                          repeats:YES];
    }
    
    NSRunLoop * rl = [NSRunLoop mainRunLoop];
    [rl addTimer:_animationTimer forMode:NSRunLoopCommonModes];
}

int opacityCnt;
-(void)animateLoading{
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
    [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 - (0.1 * x)];
    [opacitatedImage unlockFocus];
    
    [self setImage:opacitatedImage];
}

int arrowY;
-(void)animateArrow:(NSNotification*)obj{
    arrowY++;
    
    int x = arrowY;
    if(x > 19){
        arrowY = 0;
    }
    
    NSImage *image2;
    if([[[CustomVars iconAnimations] objectForKey:obj.userInfo] isEqual: @2]){
        image2 = [NSImage imageNamed:@"upload.png"];
        x = (2 * arrowY) - 25;
    }else if([[[CustomVars iconAnimations] objectForKey:obj.userInfo] isEqual: @3]){
        image2 = [NSImage imageNamed:@"download.png"];
        x = 25 - (2 * arrowY);
    }
    
    if(image2 != nil){
        NSImage *image = [NSImage imageNamed:@"icon.png"];
        NSImage *arrowImage = [[NSImage alloc] initWithSize:[image size]];

        // add arrow on top of icon
        [arrowImage lockFocus];
        [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        [image2 drawAtPoint:NSMakePoint(0,x) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        [arrowImage unlockFocus];

        [self setImage:arrowImage];
    }
}
@end
