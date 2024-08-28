//
//  FileFromWeb.m
//  ENIS
//
//  Created by Patrick Russell on 29/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileFromWeb.h"
#import "FileLogger.h"

@implementation FileFromWeb

- (BOOL)getFileFromServer:(NSString *)bsimURL {
    
    //NSString *bsimURL = @"http://welcome.ie/bs-x-9/android@athtem.eei.ericsson.se.bsim";
    NSURL  *bsimurl = [NSURL URLWithString:bsimURL];
    NSData *bsimurlData = [NSData dataWithContentsOfURL:bsimurl];
  
    if ( bsimurlData )
    {
        FLog(@"Downloading new Bsim file");
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];  
        NSString  *bsimFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"iPhone.bsim"];
        NSString  *bsimCertPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"bsim.cert"];
        NSString  *nisCertPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"nis.p12"];
        NSString  *propsPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"bsim.properties"];
        
        BOOL bsimFileExists = [[NSFileManager defaultManager] fileExistsAtPath:bsimFilePath];
        BOOL bsimCertExists = [[NSFileManager defaultManager] fileExistsAtPath:bsimCertPath];
        BOOL nisCertExists = [[NSFileManager defaultManager] fileExistsAtPath:nisCertPath];
        BOOL propsFileExists = [[NSFileManager defaultManager] fileExistsAtPath:propsPath];
        
        FLog(@"Deleting old files");
        
        if(bsimFileExists){
            [fileMgr removeItemAtPath:bsimFilePath error:nil];
        }
        if(bsimCertExists){
            [fileMgr removeItemAtPath:bsimCertPath error:nil];
        }
        if(nisCertExists){
            [fileMgr removeItemAtPath:nisCertPath error:nil];
        }
        if(propsFileExists){
            [fileMgr removeItemAtPath:propsPath error:nil];
        }
        
        FLog(@"Writing bsim file to path");
        [bsimurlData writeToFile:bsimFilePath atomically:YES];
        
        return YES;
    }
    else {
        return NO;
    }
}

@end
