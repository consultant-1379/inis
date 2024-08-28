//
//  Response.h
//  ENIS
//
//  Created by Patrick Russell on 12/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Response : NSObject{
    
    NSString *NODENAME, *NODESERIAL, *ACTION, *RESULT;
}

@property (nonatomic, retain) NSString *NODENAME, *NODESERIAL, *ACTION, *RESULT;

@end
