//
//  RequestProperty.m
//  ENIS
//
//  Created by Patrick Russell on 10/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "RequestProperty.h"

@implementation RequestProperty

@synthesize ACTION, SERIAL, NODENAME;
@synthesize LOCATIONINCLUDED, LATITUDE, LONGITUDE, ALTITUDE, ACCURACY, FIXAGE, CRS, STATTIME, UUID;
@synthesize LOGS;

/*
- (void)dealloc {
    [super dealloc];
	[ACTION release];
    [SERIAL release];
    [NODENAME release];
    [LOCATIONINCLUDED release];
    [LATITUDE release];
    [LONGITUDE release];
    [ALTITUDE release];
    [ACCURACY release];
    [FIXAGE release];
    [CRS release];
    [STATTIME release];
    [UUID release];
}
*/

@end
