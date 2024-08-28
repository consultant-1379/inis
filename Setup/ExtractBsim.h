//
//  DecryptBsim.h
//  ENIS
//
//  Created by Patrick Russell on 29/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CkoCert.h"
#import "Properties.h"

@interface ExtractBsim : NSObject

-(bool)extract;
-(Properties *)decryptProperties:(CkoCert *)niscert;

@end
