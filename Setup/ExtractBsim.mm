//
//  DecryptBsim.m
//  ENIS
//
//  Created by Patrick Russell on 29/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExtractBsim.h"
#import "CkoZip.h"
#import "CkoCrypt2.h"
#import "CkoCert.h"
#import "CkByteData.h"
#import "Properties.h"
#import "BsimFileContents.h"
#import "FileLogger.h"

@implementation ExtractBsim

-(bool)extract{
    FLog(@"Extracting Bsim file");
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];  
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"iPhone.bsim"];
    NSString  *bsimCertPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"bsim.cert"];
    NSString  *nisCertPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"nis.p12"];
    NSString  *propsPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"bsim.properties"];
    BOOL bsimCertExists = [[NSFileManager defaultManager] fileExistsAtPath:bsimCertPath];
    BOOL nisCertExists = [[NSFileManager defaultManager] fileExistsAtPath:nisCertPath];
    BOOL propsExists = [[NSFileManager defaultManager] fileExistsAtPath:propsPath];
    
    if (!(bsimCertExists || nisCertExists || propsExists)) {
        
        BOOL success;
        CkoZip *zip = [[[CkoZip alloc] init] autorelease];
        
        //  Any string unlocks the component for the 1st 30-days.
        success = [zip UnlockComponent: @"ERCSSNZIP_m8KTASu0lYxB"];
        if (success != YES) {
            FLog(@"UnZip Failed");
            return false;
        }
        
        success = [zip OpenZip: filePath];
        if (success != YES) {
            FLog(@"UnZip Failed");
            return false;
        }
        
        int unzipcount;
        unzipcount = [[zip Unzip:documentsDirectory] intValue];
       if (unzipcount < 0){
            FLog(@"UnZip Failed  %@", zip.LastErrorText);
        }
        else {
            FLog(@"Successfully unzipped");
            return true;
        }
    }
    else {
         return true;
    }
       
    return false;
    
}

-(Properties *)decryptProperties:(CkoCert *)niscert{
    
    FLog(@"Decrypting Properties");
    CkoCrypt2 *crypt = [[CkoCrypt2 alloc]init];
    [crypt UnlockComponent:@"ERCSSNCrypt_wNpWvxvYMRLP"];
    
    if(![crypt SetDecryptCert:niscert]){
        FLog(@"Failed %@", crypt.LastErrorText);
    }
    [crypt setCryptAlgorithm:@"PKI"];
    
    NSData *encryptedProps;
    
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];  
    NSString  *bsimPropsfilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"bsim.properties"];
    
    encryptedProps = [crypt ReadFile:bsimPropsfilePath];
    
    if(encryptedProps == Nil){
        FLog(@"Failed to read properties file %@", crypt.LastErrorText);
    }
    //test
    
    NSData *probsWithoutSignature;
    NSData *decryptedData;
    
    decryptedData = [crypt DecryptBytes:encryptedProps];
    //[crypt verify]
    probsWithoutSignature = [crypt OpaqueVerifyBytes:decryptedData];
    if(decryptedData == Nil){
        FLog(@"decrypt returned error %@", crypt.LastErrorText);
        
    }
    
    if(probsWithoutSignature == Nil){
        FLog(@"Verify returned error%@", crypt.LastErrorText);
    }
    
    CkoCert *signingCert = [crypt GetLastCert];
    if (signingCert == Nil) {
        FLog(@"No signature returned after verify %@", crypt.LastErrorText);
    }
    
    [crypt release];
    
    NSString *propsdata =  [[NSString alloc] initWithData:probsWithoutSignature
                                                 encoding:NSUTF8StringEncoding];
    
    NSArray *lines = [propsdata componentsSeparatedByString:@"\n"];
    Properties *properties = [[[Properties alloc] init] autorelease];
    [properties generateProperties:lines];
    
    [propsdata release];
    
    return properties;
        
}


@end
