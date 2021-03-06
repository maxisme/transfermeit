//
//  keys.h
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2020 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SAMKeychain/SAMKeychain.h>

@interface Keys : SAMKeychainQuery
-(BOOL)setKey:(NSString*)service withPassword:(NSString*)pass;
-(NSString*)getKey:(NSString*)service;
-(void)deleteKey:(NSString*)service;
@end
