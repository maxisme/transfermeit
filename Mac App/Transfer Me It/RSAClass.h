//
//  RSA.h
//  Transfer Me It
//
//  Created by Max Mitchell on 28/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Keys;
@class MIHPublicKey;

@interface RSAClass : NSObject
@property (weak, nonatomic) Keys* keychain;

-(id)initWithKeys:(Keys*)keys;
-(void)generatePair;
-(NSString*)getPub;
-(NSString*)getPriv;

+(NSString*)keyTo64String:(id)key;
+(id)string64ToKey:(NSString*)key isPublic:(BOOL)isPublic;
+(NSString*)encryptStringWithKey:(NSString*)string pubKey:(id)pk;
+(NSString*)decryptStringWithKey:(NSString*)string privKey:(id)pk;
@end
