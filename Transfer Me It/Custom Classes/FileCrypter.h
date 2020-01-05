//
//  FileCrypter.h
//  Transfer Me It
//
//  Created by Max Mitchell on 06/02/2018.
//  Copyright © 2020 Maximilian Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCrypter : NSObject
+(NSData*)encryptFile:(NSData*)data password:(NSString*)password;
+(NSData*)decryptFile:(NSData*)data password:(NSString*)password;

@end
