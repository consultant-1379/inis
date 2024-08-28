//
//  Properties.h
//  ENIS
//
//  Created by Patrick Russell on 02/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Properties : NSObject{
    NSString *incomingMailProtocol;
    NSString *bsimEmailAddress;
    NSString *iPhoneEmailPassword;
    NSString *iPhoneEmailAddress;
    NSNumber *outgoingMailServerPort;
    NSString *outgoingMailServer;
    NSString *incomingMailServer;
    NSString *iPhoneEmailUsername;
    NSNumber *incomingMailServerPort;
    bool outgoingForceSecurity;
    bool incomingForceSecurity;
    
}

@property (nonatomic, retain) NSString *incomingMailProtocol;
@property (nonatomic, retain) NSString *bsimEmailAddress;
@property (nonatomic, retain) NSString *iPhoneEmailPassword;
@property (nonatomic, retain) NSNumber *outgoingMailServerPort;
@property (nonatomic, retain) NSString *outgoingMailServer;
@property (nonatomic, retain) NSString *incomingMailServer;
@property (nonatomic, retain) NSString *iPhoneEmailUsername;
@property (nonatomic, retain) NSString *iPhoneEmailAddress;
@property (nonatomic, retain) NSNumber *incomingMailServerPort;
@property bool outgoingForceSecurity;
@property bool incomingForceSecurity;

-(void)generateProperties:(NSArray *)lines;
-(void)setProperty:(NSString *)propName :(NSString *)propContent;

@end
