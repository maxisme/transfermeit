//
//  Constants.m
//  Transfer Me It
//
//  Created by Maximilian Mitchell on 04/01/2019.
//  Copyright © 2020 Maximilian Mitchell. All rights reserved.
//

#import "Constants.h"

#ifdef DEBUG
    NSString* const BackendURL = @"http://127.0.0.1:8080";

    NSString* const PubKeyRef = @"Public Key DEBUG";
    NSString* const PrivKeyRef = @"Private Key DEBUG";
    NSString* const UUIDKeyRef = @"UUID Key DEBUG";
#else
    NSString* const BackendURL = @"https://sock.transferme.it";

    NSString* const PubKeyRef = @"Public Key";
    NSString* const PrivKeyRef = @"Private Key";
    NSString* const UUIDKeyRef = @"UUID Key";
#endif
