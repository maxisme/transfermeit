//
//  NSButton+Popup.m
//  Transfer Me It
//
//  Created by Max Mitchell on 09/02/2018.
//  Copyright © 2020 Maximilian Mitchell. All rights reserved.
//

#import "Button.h"
#import <QuartzCore/QuartzCore.h>

@implementation Button

-(void)mouseEntered:(NSEvent *)theEvent {
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
    
    if(!self.shouldNotOpacitate){
        CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
        flash.fromValue = [NSNumber numberWithFloat:1];
        flash.toValue = [NSNumber numberWithFloat:0.6];
        flash.duration = 0.2;
        [flash setFillMode:kCAFillModeForwards];
        [flash setRemovedOnCompletion:NO];
        flash.repeatCount = 1;
        [self.layer addAnimation:flash forKey:@"flashAnimation"];
    }
}

-(void)mouseExited:(NSEvent *)theEvent{
    [super resetCursorRects];
    
    if(!self.shouldNotOpacitate){
        CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
        flash.fromValue = [NSNumber numberWithFloat:0.6];
        flash.toValue = [NSNumber numberWithFloat:1];
        flash.duration = 0.2;
        [flash setFillMode:kCAFillModeForwards];
        [flash setRemovedOnCompletion:NO];
        flash.repeatCount = 1;
        [self.layer addAnimation:flash forKey:@"flashAnimation"];
    }
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
@end
