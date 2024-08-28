//
//  MailReciever.h
//  ENIS
//
//  Created by Patrick Russell on 02/05/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"
#import "CkoEmail.h"

@interface MailReciever : NSObject{
    
}

+ (Response *)processEmail:(CkoEmail *)email;
- (void)getNewItemsFromBsim;
- (void)waitGetNewItemsFromBsim;
- (UILocalNotification *)createNotification:(NSString *)nodeSerial status:(NSString *)status;
- (void)updateJobListAndCreateNotif:(NSString *)statusTimeString statusImageString:(NSString *)statusImageString currentResponse:(Response *)currentResponse;

@end
