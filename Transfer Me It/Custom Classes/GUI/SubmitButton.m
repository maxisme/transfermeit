//
//  HoverButton.m
//  Transfer Me It
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import "SubmitButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation SubmitButton
 
-(void)mouseEntered:(NSEvent *)theEvent {
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
    [self animateHover];
}

-(void)mouseExited:(NSEvent *)theEvent {
    [super resetCursorRects];
}

-(void)updateTrackingAreas{
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

-(void)animateHover{
    float grad = 0.06;
    CAMediaTimingFunction*easing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *down = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [down setFromValue:[NSNumber numberWithFloat:10]];
    [down setToValue:[NSNumber numberWithFloat:0]];
    [down setBeginTime:0.2];
    [down setDuration:0.4];
    down.timingFunction = easing;
    
    CABasicAnimation *r3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [r3 setFromValue:[NSNumber numberWithFloat:-grad * M_PI]];
    [r3 setToValue:[NSNumber numberWithFloat:0]];
    [r3 setBeginTime:0.3];
    [r3 setDuration:0.3];
    r3.timingFunction = easing;
    
    CABasicAnimation *r2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [r2 setFromValue:[NSNumber numberWithFloat:grad * M_PI]];
    [r2 setToValue:[NSNumber numberWithFloat:-grad * M_PI]];
    [r2 setBeginTime:0.1];
    [r2 setDuration:0.2];
    r2.timingFunction = easing;
    
    CABasicAnimation *up = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [up setFromValue:[NSNumber numberWithFloat:0]];
    [up setToValue:[NSNumber numberWithFloat:10]];
    [up setBeginTime:0.05];
    [up setDuration:0.2 - 0.05];
    up.timingFunction = easing;
    
    CABasicAnimation *r1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [r1 setFromValue:[NSNumber numberWithFloat:0]];
    [r1 setToValue:[NSNumber numberWithFloat:grad * M_PI]];
    [r1 setBeginTime:0];
    [r1 setDuration:0.1];
    r1.timingFunction = easing;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.duration = 0.6;
    [group setAnimations:[NSArray arrayWithObjects:up,down,r1, r2, r3, nil]];
    
    [self.layer addAnimation:group forKey:nil];
}
@end
