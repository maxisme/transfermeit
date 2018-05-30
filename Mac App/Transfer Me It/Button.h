//
//  NSButton+Popup.h
//  Transfer Me It
//
//  Created by Max Mitchell on 09/02/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class KeyWindow;
@interface Button : NSButton
@property bool shouldNotOpacitate;
@property NSString* message;
@property KeyWindow* win;
@property (strong) NSTrackingArea* trackingArea;
@end
