//
//  Download.h
//  Transfer Me It
//
//  Created by Maximilian Mitchell on 31/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class STHTTPRequest;
@class Keys;
@class MenuBar;

@interface Download : NSObject

@property (weak) Keys* keychain;
@property (weak) MenuBar *mb;

@property STHTTPRequest *dl;
@property NSMutableData *downloadData;
@property NSUInteger receivedBytes;
@property unsigned long long responseExpectedContentLength;
@property (nonatomic, strong, readonly) NSMutableData *responseData;
@property NSURLConnection * connection;
@property NSString* tempStoreIncomingPath;
@property NSString* dlStartTime;

-(id)initWithKeychain:(Keys*)keys menuBar:(MenuBar*)mb;
-(void)downloadTo:(NSString*)savedPath downloadPath:(NSString*)path;
-(NSString*)finishedDownload:(NSString*)path hash:(NSString*)hash;
@end
