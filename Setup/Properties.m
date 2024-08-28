//
//  Properties.m
//  ENIS
//
//  Created by Patrick Russell on 02/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Properties.h"
#import "FileLogger.h"

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

@implementation Properties
@synthesize incomingMailProtocol, bsimEmailAddress, incomingMailServer,outgoingMailServer,iPhoneEmailPassword,iPhoneEmailUsername, incomingMailServerPort,outgoingMailServerPort, iPhoneEmailAddress,incomingForceSecurity,outgoingForceSecurity;

-(void)generateProperties:(NSArray *)lines{
    self.incomingForceSecurity = NO;
    self.outgoingForceSecurity = NO;
    FLog(@"Generating properties object");
    for (NSString *propLine in lines){
        NSArray *propNameAndContent = [propLine componentsSeparatedByString:@"="]; 
        if ([propNameAndContent count] == 2) {
            NSString *propName = [propNameAndContent objectAtIndex:0];
            NSString *propContent = [propNameAndContent objectAtIndex:1];
            
            if (propName == nil || propContent == nil) {
                FLog(@"There is a problem with loading this property");
            }
            else {
                [self setProperty:propName :propContent];
            }

        }
               
    }
       
}
    
-(void)setProperty:(NSString *)propName :(NSString *) propContent{
if ([propName length] > 0){
    if ([propName isEqualToString:@"incoming_mail_protocol"]){
        
        self.incomingMailProtocol = propContent;
        
    }
    else if([propName isEqualToString:@"bsim_email_address"]){
        
        self.bsimEmailAddress = propContent;
    }
    else if([propName isEqualToString:@"android_email_password"]){
        
        self.iPhoneEmailPassword = propContent;
    }
    else if([propName isEqualToString:@"android_email_address"]){
        
        self.iPhoneEmailAddress = propContent;
    }
    else if([propName isEqualToString:@"outgoing_mail_server_port"]){
        
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        self.outgoingMailServerPort= [f numberFromString:propContent];
        [f release];
    }
    else if([propName isEqualToString:@"outgoing_mail_server"]){
        
        self.outgoingMailServer = propContent;
    }
    else if([propName isEqualToString:@"outgoing_force_security"]){
        
        self.outgoingForceSecurity = propContent;
    }
    else if([propName isEqualToString:@"incoming_mail_server"]){
        
        self.incomingMailServer = propContent;
    }
    else if([propName isEqualToString:@"incoming_force_security"]){
        
        self.incomingForceSecurity = propContent;
    }
    else if([propName isEqualToString:@"android_email_username"]){
        
        self.iPhoneEmailUsername = propContent;
    }
    else if([propName isEqualToString:@"incoming_mail_server_port"]){
        
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        self.incomingMailServerPort = [f numberFromString:propContent];
        [f release];
    }
    else if([propName isEqualToString:@"outgoing_force_security"]){
        
        if ([propContent isEqualToString:@"true"]) {
            self.outgoingForceSecurity = YES;
        }
    }
    else if([propName isEqualToString:@"incoming_force_security"]){
        
        if ([propContent isEqualToString:@"true"]) {
            self.incomingForceSecurity = YES;
        }

    }
    
    
}

}


@end
