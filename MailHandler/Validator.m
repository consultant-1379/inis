//
//  Validator.m
//  ENIS
//
//  Created by Patrick Russell on 08/05/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "Validator.h"
#import "CkoEmail.h" 
#import "BsimFileContents.h"

@implementation Validator

-(NSString *)validateEmail:(CkoEmail *)email{
    
    NSString *subject = email.Subject;
    NSString *result = nil;
    CkoCert *signedByCert = [email GetSignedByCert];
    BsimFileContents *bsimfilecont =  [BsimFileContents sharedBsimContents];
    
    if (![subject isEqualToString:@"BSIM Auto-Integration"]) {
        result = @"Subject not valid";
    }
    
    else if (![email ReceivedEncrypted]) {
        result = @"Email recieved not encrypted";
    }
    
    else if (![email ReceivedSigned]) {
        result = @"Email has not been signed.";
    }
    
    else if (![signedByCert.GetEncoded isEqual:bsimfilecont.bsimCert.GetEncoded]) {
        result = @"Signature of recieved email does not match.";
    }

    else {
        return @"success";
    }
    return result;
    
    
}

@end
