//
//  Upload.h
//  Transfer Me It
//
//  Created by Maximilian Mitchell on 31/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class STHTTPRequest;
@class MenuBar;
@class PopUpWindow;
@class Keys;

@interface Upload : NSObject

@property STHTTPRequest *ul;
@property (weak) MenuBar *mb;
@property (weak) PopUpWindow *window;

-(id)initWithWindow:(PopUpWindow*)window menuBar:(MenuBar*)mb;
-(void)uploadFile:(NSString*)path friend:(NSString*)friendCode keys:(Keys*)keys;
@end
