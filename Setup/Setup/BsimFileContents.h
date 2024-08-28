//
//  BsimFileContents.h
//  ENIS
//
//  Created by Patrick Russell on 11/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CkoCert.h"
#import "Properties.h"
#import "ExtractBsim.h"

@interface BsimFileContents : NSObject{
    CkoCert *nisCert;
    CkoCert *bsimCert;
    Properties *properties;
    BOOL extracted;
    ExtractBsim *bsimExtractor;
    
}

@property (nonatomic, retain) CkoCert *nisCert, *bsimCert;
@property (nonatomic, retain) Properties *properties;
@property (nonatomic, retain) ExtractBsim *bsimExtractor;
+(BsimFileContents *)sharedBsimContents;
-(bool)extract;
-(NSString *)verifyAndInitialize:(NSString *) secret;

@end
