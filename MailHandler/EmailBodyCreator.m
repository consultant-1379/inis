//
//  EmailBodyCreator.m
//  ENIS
//
//  Created by Patrick Russell on 10/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "EmailBodyCreator.h"
#import "FileLogger.h"

@implementation EmailBodyCreator

-(NSString *)create:(RequestProperty *) requestProp{
    
    FLog(@"Creating email body");
    
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter;
	dateFormatter = nil;
	dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"EEE MMM d HH:mm:ss z yyyy"];
    NSString *stringdate = [dateFormatter stringFromDate:now];
    
    NSMutableString *res = [[[NSMutableString alloc] init] autorelease];
  
    if ([requestProp.ACTION isEqualToString:@"bind"]) {
        FLog(@"EmailBodyCreator: Request is a BIND request");
        [res appendFormat: @"#%@\n", stringdate];
        [res appendFormat: @"nodeserial=%@\n", requestProp.SERIAL];
        [res appendFormat:@"workorder=%@\n", requestProp.NODENAME];
        [res appendFormat:@"IMSI=%@\n", requestProp.UUID];
        [res appendFormat:@"action=%@\n", requestProp.ACTION];
        [res appendFormat:@"network.included=%@\n", @"false"];
        
        if ( [requestProp.LOCATIONINCLUDED isEqualToString:@"true"] ) {
            FLog(@"LOCATIONINCLUDED is true. GPS is turned on.");
            [res appendFormat:@"gps.included=%@\n",requestProp.LOCATIONINCLUDED];
            [res appendFormat:@"gps.latitude=%@\n",requestProp.LATITUDE];
            [res appendFormat:@"gps.longitude=%@\n",requestProp.LONGITUDE];
            [res appendFormat:@"gps.altitude=%@\n",requestProp.ALTITUDE];
            [res appendFormat:@"gps.accuracy=%@\n",requestProp.ACCURACY];
            [res appendFormat:@"gps.fixage=%@\n",requestProp.FIXAGE];
            [res appendFormat:@"gps.crs=%@\n",requestProp.CRS];
        }
        else {
            FLog(@"LOCATIONINCLUDED is false. GPS is turned off.");
            [res appendFormat:@"gps.included=%@\n",requestProp.LOCATIONINCLUDED];
        }
        
        [res appendFormat:@"IMEI=%@", @"000000000000000"];
    }
    else if([requestProp.ACTION isEqualToString:@"cancel"]) {
        FLog(@"EmailBodyCreator: Request is a CANCEL request");
        [res appendFormat: @"#%@\n", stringdate];
        [res appendFormat: @"nodeserial=%@\n", requestProp.SERIAL];
        [res appendFormat:@"workorder=%@\n", requestProp.NODENAME];
        [res appendFormat:@"action=%@\n", requestProp.ACTION];
    }
    else {
        [res appendFormat:@"Request name invalid"];
    }
    
    return res;
}

@end
