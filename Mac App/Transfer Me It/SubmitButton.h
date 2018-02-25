//
//  HoverButton.h
//  Transfer Me It
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SubmitButton : NSButton
@property (nonatomic) NSString* uploadFilePath;
@property (nonatomic, strong) NSTrackingArea* trackingArea;
@property (nonatomic, strong) NSImage *hover_image;
@property (strong) NSCursor *cursor;
@end
