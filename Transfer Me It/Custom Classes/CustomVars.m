//
//  Colours.m
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2020 max mitchell. All rights reserved.
//

#import "CustomVars.h"

@implementation CustomVars
+(NSColor *)black{
    return [NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
}

+(NSColor *)white{
    return [NSColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
}

+(NSColor *)red{
    return [NSColor colorWithRed:0.74 green:0.13 blue:0.13 alpha:1.0];
}

+(NSColor *)grey{
    return [NSColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1.0];
}

+(NSColor *)boarder{
    return [NSColor colorWithRed:0.92 green:0.91 blue:0.91 alpha:1.0];
}

+(NSColor *)offwhite{
    return [NSColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
}

+(int)windowWidth{
    return 300;
}

+(int)windowHeight{
    return 160;
}

+(int)userCodeLength{
    return 7;
}

+(NSDictionary*)iconAnimations{
    static NSDictionary *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @{
                 @"loading": @1,
                 @"uploading": @2,
                 @"downloading": @3
                 };
    });
    return inst;
}
@end
