//
//  NSButton+Popup.h
//  Transfer Me It
//
//  Created by Max Mitchell on 09/02/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Button : NSButton
@property NSString* message;
@property (strong) NSTrackingArea* trackingArea;
@end
