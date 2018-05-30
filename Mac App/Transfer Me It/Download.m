//
//  Download.m
//  Transfer Me It
//
//  Created by Maximilian Mitchell on 31/01/2018.
//  Copyright © 2018 Maximilian Mitchell. All rights reserved.
//

#import "Download.h"

#import <STHTTPRequest/STHTTPRequest.h>
#import <GZIP/GZIP.h>

#import "CustomFunctions.h"
#import "DesktopNotification.h"
#import "RSAClass.h"
#import "Keys.h"
#import "FileCrypter.h"

#import "MenuBar.h"

@implementation Download

-(id)initWithKeychain:(Keys*)keys menuBar:(MenuBar*)mb{
    if (self != [super init]) return nil;
    
    _mb = mb;
    _keychain = keys;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finish) name:@"cancel-download" object:nil];
    
    return self;
}

-(void)downloadTo:(NSString*)savedPath friendUUID:(NSString*)friendUUID downloadPath:(NSString*)path downloadRef:(unsigned long long)ref{
    [_mb setdownloadMenu:[path lastPathComponent]];
    
    _dl = nil;
    _dl = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/download.php"];
    _dl.POSTDictionary = @{ @"UUID":[CustomFunctions getSystemUUID], @"UUIDKey":[_keychain getKey:@"UUID Key"], @"path":path};
    
    // start keep alive (tell server not to delete a file still downloading)
    [NSTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(keepAlive:) userInfo:@{@"path": path} repeats:YES];
    
    _dl.completionDataBlock = ^(NSDictionary *headers, NSData *downloadedData) {
        if([downloadedData length] > 1){ // sometimes called incorrectly so need to check there is actually data
            NSString* downloadedError = nil;
            
            // get the hash of the ENCRYPTED file you have downloaded to confirm against the server that it is the same file that was uploaded
            // helps against MITM attacks.
            [_mb setProgressInfo:@"Fetching File Hash..."];
            NSString* fileHash = [CustomFunctions hash:downloadedData];
            NSLog(@"after hash");
            
            //get the encrypted (by friend with your PubKey) password for the file from server by confirming hash and download path
            NSString* encrypted_pass = [self finishedDownload:path friendUUID:friendUUID downloadRef:ref hash:fileHash];
            
            if ([downloadedData length] > 0 && [encrypted_pass length] > 10) { // 10 is arbitrary
                
                // decrypt `encrypted_pass` with your PrivKey
                id privateKey = [RSAClass string64ToKey:[[[RSAClass alloc] initWithKeys:_keychain] getPriv] isPublic:NO];
                NSString* pass = [RSAClass decryptStringWithKey:encrypted_pass privKey:privateKey];
                
                if(![pass isEqual: @""]){
                    // decrypt file with `pass`
                    [_mb setProgressInfo:@"Decrypting File..."];
                    NSData* file = [FileCrypter decryptFile:downloadedData password:pass];
                    
                    if([file isGzippedData]){
                        //uncompress file
                        [_mb setProgressInfo:@"Uncompressing File..."];
                        file = [file gunzippedData];
                    }
                    
                    if(file != nil){
                        NSString* destinationPath = [NSString stringWithFormat:@"%@/%@", savedPath, [path lastPathComponent]];
                        
                        // make sure file path is not already occopied and if it is add count extension [a.txt, a 1.txt, a 2.txt]
                        int x = 0;
                        NSString* ext = [destinationPath pathExtension];
                        NSString* filepath = [destinationPath stringByDeletingPathExtension];
                        while ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]){
                            x++;
                            if(![ext isEqual: @""]){
                                destinationPath = [NSString stringWithFormat:@"%@ %d.%@", filepath, x, ext];
                            }else{
                                destinationPath = [NSString stringWithFormat:@"%@ %d", filepath, x];
                            }
                        }
                        
                        if([CustomFunctions writeDataToFile:file destinationPath:destinationPath]){
                            [DesktopNotification send:@"Successful Download!" message:@"The file has been downloaded and decrypted." activate:@"Show" close:@"Close" variables:@{@"type":@"download", @"file_path": destinationPath}];
                        }else{
                            [DesktopNotification send:@"Error Writing File!" message:@"The file was not able to be writen to the path."];
                        }
                    }else{
                        downloadedError = @"Unable to decrypt file";
                    }
                }else{
                    downloadedError = @"Unable to decrypt encrypted string.";
                    NSLog(@"encrypted_pass: %@", encrypted_pass);
                }
            }else{
                downloadedError = [NSString stringWithFormat:@"Downloaded file is not as it should be. '%@'", encrypted_pass];
            }
            
            if(downloadedError.length > 0){
                [DesktopNotification send:@"Error Downloading File!" message:downloadedError activate:@"" close:@"Close"];
                NSLog(@"Download Error: %@",downloadedError);
            }
        }else{
            NSString* errorMsg = [[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding];
            if([errorMsg isEqual: @"2"]){
                [DesktopNotification send:@"Expired File!" message:@"You did not download the file in time. It has been deleted." activate:@"" close:@"Close"];
            }else{
                [DesktopNotification send:@"Error Downloading File!" message:errorMsg activate:@"" close:@"Close"];
            }
        }
        
        [self finish];
    };
    
    _dl.errorBlock = ^(NSError *error) {
        if (![[error localizedDescription] isEqual: @"Connection was cancelled."]) { // ignore when manually cancelled
            [self finishedDownload:path friendUUID:friendUUID downloadRef:ref hash:@""];
            [DesktopNotification send:@"Network Error During Download!" message:@"Please check your network and ask friend to upload again." activate:@"" close:@"Close"];
            [self finish];
        }
    };
    
    _dl.downloadProgressBlock = ^(NSData *data, int64_t totalBytesReceived, int64_t totalBytesExpectedToReceive) {
        // make sure always showing download menu when downloading
        if(![_mb.menuName isEqual: @"download"]) [_mb setdownloadMenu:[path lastPathComponent]];
        
        unsigned long long totalBytes = totalBytesExpectedToReceive;
        float downloadPercent = ([@(totalBytesReceived) floatValue] / [@(totalBytesExpectedToReceive) floatValue]) * 100;
        [_mb setProgressInfo:[NSString stringWithFormat:@"%.1f%% of %@", downloadPercent, [NSByteCountFormatter stringFromByteCount:totalBytes countStyle:NSByteCountFormatterCountStyleFile]]];
    };
    
    [_dl startAsynchronous];
}

// retrieve the encrypted password stored by the server.
// if the hash is empty (as is the case with unwanted downloads and errornous downloads) the file will be deleted but no key returned.
-(NSString*)finishedDownload:(NSString*)path friendUUID:(NSString*)friendUUID downloadRef:(unsigned long long)ref hash:(NSString*)hash{
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://transferme.it/app/finishedDownload.php"];
    NSLog(@"key %llu", ref);
    r.POSTDictionary = @{
                         @"path":path,
                         @"friendUUID": friendUUID,
                         @"UUID":[CustomFunctions getSystemUUID],
                         @"UUIDKey":[_keychain getKey:@"UUID Key"],
                         @"hash":hash,
                         @"ref":[NSNumber numberWithUnsignedLongLong:ref]
                         };
    
    NSError *error = nil;
    NSString *password = [r startSynchronousWithError:&error];
    
    if(error != nil){
        NSLog(@"Error finishing download: %@",[error localizedDescription]);
        [DesktopNotification send:@"Unable To Delete File From Server!" message:@"File will be deleted within the hour."];
        return @"";
    }
    
    return password;
}

-(void)keepAlive:(NSTimer *)timer{
    if(_dl){
        NSString* path = [[timer userInfo] objectForKey:@"path"];
        [CustomFunctions sendNotificationCenter:path name:@"keep-alive"];
    }else{
        NSLog(@"No download request");
        [timer invalidate];
    }
}

// TODO run finished download on finish
-(void)finish{
    NSLog(@"finished download");
    [_mb setDMenu];
    [_dl cancel];
    _dl = nil;
}
@end
