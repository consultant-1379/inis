//
//  Validator.h
//  ENIS
//
//  Created by Patrick Russell on 08/05/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CkoEmail.h"

@interface Validator : NSObject{
    
}

-(NSString *)validateEmail:(CkoEmail *)email;

@end
