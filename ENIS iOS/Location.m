//
//  Location.m
//  ENIS
//
//  Created by Patrick Russell on 23/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "Location.h"
#import "FileLogger.h"

@implementation Location

@synthesize locationManager;

- (id) init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self; // send loc updates to myself
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
  // FLog(@"Location: %@", [newLocation description]);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
//	FLog(@"Error: %@", [error description]);
}

- (void)dealloc {
    [locationManager release];
    [super dealloc];
}



@end
