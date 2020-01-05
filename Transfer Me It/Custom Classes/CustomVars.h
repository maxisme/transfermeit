//
//  Colours.h
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2020 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface CustomVars: NSObject
+(NSColor *)black;
+(NSColor *)white;
+(NSColor *)red;
+(NSColor *)grey;
+(NSColor *)boarder;
+(NSColor *)offwhite;

+(int)windowWidth;
+(int)windowHeight;

+(int)userCodeLength;
+(NSDictionary*)iconAnimations;
@end
