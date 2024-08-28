//
//  Location.h
//  ENIS
//
//  Created by Patrick Russell on 23/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Location : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    
}

@property (nonatomic, retain) CLLocationManager *locationManager;  

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;


@end
