//
//  RSA.m
//  Transfer Me It
//
//  Created by Max Mitchell on 28/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import "RSAClass.h"

#import "Keys.h"

#import <MIHCrypto/MIHPublicKey.h>
#import <MIHCrypto/MIHPrivateKey.h>
#import <MIHCrypto/MIHRSAKeyFactory.h>
#import <MIHCrypto/MIHKeyPair.h>
#import <MIHCrypto/MIHRSAPublicKey.h>
#import <MIHCrypto/MIHRSAPrivateKey.h>


@implementation RSAClass
-(id)initWithKeys:(Keys*)keys{
    if (self != [super init]) return nil;
    
    _keychain = keys;
    if(![self validKeys]) [self generatePair];
    
    return self;
}

-(NSString*)getPub{
    return [_keychain getKey:@"Public Key"];
}

-(NSString*)getPriv{
    return [_keychain getKey:@"Private Key"];
}

-(void)generatePair{
    //create pub and private key
    MIHKeyPair *keyPair = [[[MIHRSAKeyFactory alloc] init] generateKeyPair];
    
    id<MIHPublicKey> publicKey = keyPair.public;
    id<MIHPrivateKey> privateKey = keyPair.private;
    
    //store priv key in keychain
    [_keychain setKey:@"Private Key" withPassword:[RSAClass keyTo64String:privateKey]];
    [_keychain setKey:@"Public Key" withPassword:[RSAClass keyTo64String:publicKey]];
}

// used to make sure stored keys are not tampered with and work correctly.
-(bool)validKeys{
    NSString* test_str = @"Lorem Ipsum";
    
    // make sure there are actually keys stored
    if(![self getPub] || ![self getPriv]) return false;
    
    //get stored user keys
    id<MIHPublicKey> pubKey = [RSAClass string64ToKey:[self getPub] isPublic:YES ];
    id<MIHPrivateKey> privKey = [RSAClass string64ToKey:[self getPriv] isPublic:NO];
    
    //encrypt string with public key
    NSString* encrypted_str = [RSAClass encryptStringWithKey:test_str pubKey:pubKey];
    
    //decrypt string with private key
    NSString* decrypted_str = [RSAClass decryptStringWithKey:encrypted_str privKey:privKey];
    
    //check the strings match
    return [test_str isEqualToString:decrypted_str];
}

+(NSString*)keyTo64String:(id)key{
    NSData* keyData = [key dataValue];
    return [keyData base64EncodedStringWithOptions:0];
}

+(id)string64ToKey:(NSString*)key isPublic:(BOOL)isPublic{
    NSData* keyData = [[NSData alloc] initWithBase64EncodedString:key options:0];
    if(isPublic) return [[MIHRSAPublicKey alloc] initWithData:keyData];
    return [[MIHRSAPrivateKey alloc] initWithData:keyData];
}

+(NSString*)encryptStringWithKey:(NSString*)string pubKey:(id)pk{
    NSData* string_data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData* encr_data = [pk encrypt:string_data error:nil];
    return [encr_data base64EncodedStringWithOptions:0];
}

+(NSString*)decryptStringWithKey:(NSString*)string privKey:(id)pk{
    string = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //decode ascii charachters
    NSData* encr_actual_data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    NSData *decryptedData = [pk decrypt:encr_actual_data error:nil];
    return [NSString stringWithUTF8String:decryptedData.bytes];
}

@end
