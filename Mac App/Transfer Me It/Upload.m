//
//  Upload.m
//  Transfer Me It
//
//  Created by Maximilian Mitchell on 31/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import "Upload.h"

#import <STHTTPRequest/STHTTPRequest.h>
#import <GZIP/GZIP.h>

#import "Keys.h"
#import "CustomVars.h"
#import "CustomFunctions.h"
#import "DesktopNotification.h"
#import "RSAClass.h"
#import "PopUpWindow.h"
#import "MenuBar.h"
#import "FileCrypter.h"

#define FILE_PASS_SIZE 128
#define COMPRESSION_LEVEL 0.7

@implementation Upload

-(id)initWithWindow:(PopUpWindow*)window menuBar:(MenuBar*)mb{
    if (self != [super init]) return nil;
    
    _mb = mb;
    _window = window;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finish) name:@"cancel-upload" object:nil];
    
    return self;
}

-(void)uploadFile:(NSString*)path friend:(NSString*)friendCode keys:(Keys*)keys{
    NSData* file = [NSData dataWithContentsOfFile:path];
    unsigned long long fileSize = (unsigned long long)[file length];
    if(fileSize > 0){ // is a valid file
        friendCode = [CustomFunctions cleanUpString:friendCode];
        
        // TODO locally verify fileSize is less than allowed.
        if ([friendCode length] == 0) {
            [_window inputError:@"You must enter your friends code!"];
        }else if ([friendCode length] != [CustomVars userCodeLength]) {
            [_window inputError:@"Your friend does not exist!"];
        }else if(![CustomFunctions fileIsPath:path]){
            //TODO zip if not already.
            [_window inputError:@"You must Compress/zip folders!"];
        }else{
            /////////////////////////////////
            // initial upload verification so as to not have to upload file
            // before finding an iregularity.
            // returns `pubKey` (friends public key that is uploaded when creating new code)
            // of the friend, the client is uploading to, so they can encrypt the `pass` and only
            // the friend will be able to decrypt.
            /////////////////////////////////
            unsigned long long encryptedFileSize = [CustomFunctions bytesToEncrypted:fileSize];
            
            STHTTPRequest* r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/initUpload.php"];
            
            r.POSTDictionary = @{ @"friend":friendCode,
                                  @"UUID":[CustomFunctions getSystemUUID],
                                  @"UUIDKey":[keys getKey:@"UUID Key"],
                                  @"filesize":[NSString stringWithFormat:@"%llu", encryptedFileSize]};
            NSError *error = nil;
            NSString *body = [r startSynchronousWithError:&error];
            NSString* pubKey = [CustomFunctions jsonToVal:body key:@"pub_key"]; // given friends pub_key
            
            /////////////////////////////////
            
            if(![pubKey isEqual: @""]){
                // generate a password to encrypt the file with
                NSString* pass = [CustomFunctions randomString:FILE_PASS_SIZE];
                
                [_window animatePlane];
                
                [_mb setUploadMenu:[path lastPathComponent]];
                
                // COMPRESSING FILE
                [_mb setProgressInfo:@"Compressing File"];
                NSData* compressedFile = [file gzippedDataWithCompressionLevel:COMPRESSION_LEVEL];
                
                NSData* fileToEncrypt = nil;
                
                if([compressedFile length] < fileSize){
                    //if compression made the file smaller
                    fileToEncrypt = compressedFile;
                }else{
                    NSLog(@"File already @ max compression");
                    fileToEncrypt = file;
                }
                
                // encrypt the `pass` (password that the file is going to be encrypted with) with friends public key
                id friendPubKey = [RSAClass string64ToKey:pubKey isPublic:YES];
                NSString* encrypted_pass = [RSAClass encryptStringWithKey:pass pubKey:friendPubKey];
                
                // ENCRYPT THE FILE with unencrypted password
                [_mb setProgressInfo:@"Encrypting File..."];
                NSData* encryptedFile = [FileCrypter encryptFile:fileToEncrypt password:pass];
                
                // UPLOAD ENCRYPTED FILE along with encrypted password of file.
                _ul = nil;
                _ul = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/upload.php"];
                _ul.POSTDictionary = @{ @"friend":friendCode, @"UUID":[CustomFunctions getSystemUUID], @"UUIDKey":[keys getKey:@"UUID Key"], @"pass": encrypted_pass};
                
                [_ul addDataToUpload:encryptedFile parameterName:@"fileUpload" mimeType:@"application/octet-stream" fileName:[path lastPathComponent]];
                
                _ul.completionBlock = ^(NSDictionary *headers, NSString *body) {
                    if(![body isEqual: @"1"]){
                        [DesktopNotification send:@"Major Error Uploading!" message:[NSString stringWithFormat:@"Error code: %@. Contact hello@transferme.it", body]];
                    }else{
                        [DesktopNotification send:@"Uploaded File!" message:@"Your friend can now download the file."];
                    }
                    [self finish];
                };
                
                _ul.errorBlock = ^(NSError *error) {
                    if (![[error localizedDescription] isEqual: @"Connection was cancelled."]) {// ignore when manually cancelled
                        NSLog(@"Upload Error (2): %@",[error localizedDescription]);
                        [DesktopNotification send:@"Network Error During Upload!" message:@"Please check your network and try uploading the file again."];
                        [self finish];
                    }
                };
                
                _ul.uploadProgressBlock = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
                    // make sure always showing upload menu when uploading
                    if(![_mb.menuName isEqual: @"upload"]) [_mb setUploadMenu:[path lastPathComponent]];
                    
                    float uploadPercent = ([@(totalBytesWritten) floatValue] / [@(totalBytesExpectedToWrite) floatValue]) * 100;
                    unsigned long long totalUploadBytes = (unsigned long long)totalBytesExpectedToWrite;
                    [_mb setProgressInfo:[NSString stringWithFormat:@"%.1f%% of %@", uploadPercent, [NSByteCountFormatter stringFromByteCount:totalUploadBytes countStyle:NSByteCountFormatterCountStyleFile]]];
                };
                
                
                [_ul startAsynchronous];
            }else{
                // error with init upload
                NSString *error_message = [CustomFunctions jsonToVal:body key:@"message"];
                if ([[error localizedDescription] isEqual: @"Connection was cancelled."]) {
                    [DesktopNotification send:error_message message:@"Would you like to purchase upload credit?" activate:@"Yes" close:@"No"];
                }
                NSLog(@"upload error body: %@",body);
                [_window inputError:error_message];
            }
        }
    }else{
        [_window inputError:@"You have not chosen a file. Compress folders!"];
    }
}

-(void)finish{
    NSLog(@"finished upload");
    [_ul cancel];
    _ul = nil;
    [_window closeWindow];
    [_mb setDMenu];
}


@end
