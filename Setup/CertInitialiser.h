//
//  CertInitialiser.h
//  ENIS
//
//  Created by Patrick Russell on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CkoCert.h"

@interface CertInitialiser : NSObject{
    CkoCert *nisCert;
    CkoCert *bsimCert;
}
@property (nonatomic, retain) CkoCert *nisCert;
@property (nonatomic, retain) CkoCert *bsimCert;


-(NSString *)verifySecretAndInitialize:(NSString *) secret;

@end
