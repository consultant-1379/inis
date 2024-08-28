//
//  RequestProperty.h
//  ENIS
//
//  Created by Patrick Russell on 10/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestProperty : NSObject{
    NSString *ACTION, *NODENAME, *SERIAL;
    NSString *LOCATIONINCLUDED, *LATITUDE, *LONGITUDE, *ALTITUDE, *ACCURACY, *FIXAGE, *CRS, *STATTIME, *UUID;
    BOOL LOGS;
}

@property (nonatomic, copy) NSString *ACTION, *NODENAME, *SERIAL;
@property (nonatomic, copy) NSString  *LOCATIONINCLUDED, *LATITUDE, *LONGITUDE, *ALTITUDE, *ACCURACY, *FIXAGE, *CRS, *STATTIME, *UUID;
@property (nonatomic, assign) BOOL LOGS;

@end
