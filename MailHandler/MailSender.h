//
//  MailSender.h
//  ENIS
//
//  Created by Patrick Russell on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProperty.h"
#import "BsimFileContents.h"

@class Reachability;

@interface MailSender : NSObject{
    BsimFileContents *bsimFile;
}

@property (nonatomic, retain) BsimFileContents *bsimFile;

-(void)sendRequest:(RequestProperty*)reqProp;
+(BOOL) connectedToNetwork;

@end
