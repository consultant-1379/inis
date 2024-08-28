//
//  EmailBodyCreator.h
//  ENIS
//
//  Created by Patrick Russell on 10/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProperty.h"

@interface EmailBodyCreator : NSObject

-(NSString *)create:(RequestProperty *) requestProp;

@end
