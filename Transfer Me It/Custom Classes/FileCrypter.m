//
//  FileCrypter.m
//  Transfer Me It
//
//  Created by Max Mitchell on 06/02/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import "FileCrypter.h"
#import "RNDecryptor.h"
#import "RNEncryptor.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation FileCrypter

+(NSData*)encryptFile:(NSData*)data password:(NSString*)password{
    NSError *error = nil;
    NSData *encrypted_data = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:&error];
    if (error != nil) {
        DDLogDebug(@"RNEncryptor error:%@", error);
        return nil;
    }else{
        return encrypted_data;
    }
}

+(NSData*)decryptFile:(NSData*)data password:(NSString*)password{
    NSError *error = nil;
    NSData *decrypted_data = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:password error:&error];
    if (error != nil) {
        DDLogDebug(@"Decryption ERROR:%@", error);
        return nil;
    }else{
        return decrypted_data;
    }
}
@end
