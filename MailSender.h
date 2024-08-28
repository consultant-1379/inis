//
//  MailSender.h
//  ENIS
//
//  Created by Patrick Russell on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Properties.h"

@interface MailSender : NSObject


-(void)sendNewNode:(Properties *)properties;

@end
