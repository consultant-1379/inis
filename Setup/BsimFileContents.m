//
//  BsimFileContents.m
//  ENIS
//
//  Created by Patrick Russell on 11/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "BsimFileContents.h"
#import "ExtractBsim.h"
#import "CertInitialiser.h"
#import "AppDelegate.h"
#import "FileLogger.h"

@implementation BsimFileContents
@synthesize properties, bsimCert, bsimExtractor, nisCert;

static BsimFileContents *sharedBsimContents = nil;

+ (BsimFileContents *)sharedBsimContents {
    @synchronized(self) {
        if (sharedBsimContents == nil)
            sharedBsimContents = [[self alloc] init];
            
    }
    return sharedBsimContents;
}

-(bool)extract{

    bsimExtractor = [[ExtractBsim alloc]init]; 
    
    if([bsimExtractor extract] == YES){
        return true;
    }
    else {
        return false;
    }

}

-(NSString *)verifyAndInitialize:(NSString *) secret{
    
    FLog(@"Verify and initialsing");
    CertInitialiser *certInit = [[CertInitialiser alloc] init];
    NSString *result = [certInit verifySecretAndInitialize:secret];
    if ([result isEqualToString:@"success"]) {
        
        bsimCert = [[CkoCert alloc] init];
        sharedBsimContents.bsimCert = certInit.bsimCert;
        sharedBsimContents.nisCert = certInit.nisCert;
        properties = [[Properties alloc] init];
        sharedBsimContents.properties = [bsimExtractor decryptProperties:nisCert];
    }
    
    [certInit release];
    return result;
    
}

-(id)init{
    
    if (self = [super init]) {
        properties = [[Properties alloc]init];
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
}

@end
