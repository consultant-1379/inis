//
//  CertInitialiser.m
//  ENIS
//
//  Created by Patrick Russell on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CertInitialiser.h"
#import "CkoCertStore.h"
#import "CkoCert.h"
#import "CkoPublicKey.h"
#import "FileLogger.h"

@implementation CertInitialiser

@synthesize nisCert, bsimCert;


-(NSString *)verifySecretAndInitialize:(NSString *) secret{
    FLog(@"Cert init");
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];  
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"nis.p12"];
    CkoCertStore *nisCertStore = [[[CkoCertStore alloc] init] autorelease];
    BOOL success = [nisCertStore LoadPfxFile:filePath password:secret];
    
    int numCerts;
    numCerts = [nisCertStore.NumCertificates intValue];
    FLog(@"PFX contains %d certificates\n" ,numCerts) ;
    
    if (numCerts != 0 && success == YES) {
        FLog(@"Certs found in certstore and verify secret SUCCESS");
        
        NSString *bsimCertFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"bsim.cert"];
        bsimCert = [[CkoCert alloc ] init];
        
        if( ![self.bsimCert LoadFromFile:bsimCertFilePath] ) {
            FLog(@"File not found error %@", bsimCert.LastErrorText);
            return @"failed";
        }
        
        for(int i = 0; i < numCerts; i++) {
            
            CkoCert *cert = [nisCertStore GetCertificate:[NSNumber numberWithInt:i]];
            if ([cert HasPrivateKey]) {
                
                self.nisCert = cert;
                return @"success";
            }
        }
    }
    else {
        FLog(@"No certs found in certstore or verify secret NOT SUCCESSFUL");
    }
    
    return @"failed";
}

-(void)dealloc{
    [super dealloc];
    [bsimCert release];
    [nisCert release];
}

@end
