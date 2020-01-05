//
//  HoverButton.h
//  Transfer Me It
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2020 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SubmitButton : NSButton
@property (nonatomic) NSString* uploadFilePath;
@property (nonatomic, strong) NSTrackingArea* trackingArea;
@property (strong) NSCursor *cursor;
-(void)animateHover;
@end
