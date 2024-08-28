//
//  MailSender.m
//  ENIS
//
//  Created by Patrick Russell on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailSender.h"
#import "CkoMailMan.h"
#import "CkoCert.h"
#import "CertInitialiser.h"
#import "CkoEmailBundle.h"
#import "CkoStringArray.h"
#import "CkoEmail.h"

@implementation MailSender

-(void)sendNewNode:(Properties*)properties{
    
    NSMutableString *strOutput = [NSMutableString stringWithCapacity:1000];
    
    //  The mailman object is used for sending and receiving email.
    CkoMailMan *mailman = [[CkoMailMan alloc] init];
    
    //  Any string argument automatically begins the 30-day trial.
    BOOL success;
    success = [mailman UnlockComponent: @"30-day trial"];
    if (success != YES) {
        [strOutput appendString: mailman.LastErrorText];
        [strOutput appendString: @"\n"];
        NSLog(@"Error %@", strOutput);
        return;
    }
    
    //  Set the SMTP server.
    mailman.SmtpHost = @"mail.welcome.ie";
    mailman.SmtpUsername = @"bsim@welcome.ie";
    mailman.SmtpPassword = @"AXVHh5wt";
    
    mailman.SmtpSsl = YES;
    mailman.SmtpPort = [NSNumber numberWithInt:465];
    //  Load the .cer file into a certificate object.
    //  When sending S/MIME encrypted email, it is the recipient's
    //  certificate that is used for encryption.  Only the public key
    //  is needed to encrypt.  The recipient is the only
    //  one possessing the private key, and therefore is the only
    //  one able to decrypt.
        
    //  Create a new email object
    CkoEmail *email = [[CkoEmail alloc] init];
    
    email.Subject = @"This email is encrypted";
    email.Body = @"This is a digitally encrypted mail";
    email.From = properties.iPhoneEmailAddress;
    [email setSendSigned:true];
 
  
    [email AddTo: @"" emailAddress:@"bsim@welcome.ie"];
    
    [email setPkcs7CryptAlg:@"aes"];
    [email setPkcs7KeyLength:[NSNumber numberWithInt:128]];
    CertInitialiser *certInitaliser = [[CertInitialiser alloc] init];
    [certInitaliser initialize];
    CkoCert *bsimCert = [certInitaliser bsimCert]; 
    NSLog(@"Bsim Cert Info%@", bsimCert.SerialNumber);
    //  Indicate that the email is to be sent encrypted.
    email.SendEncrypted = YES;
    [email SetSigningCert:certInitaliser.privCert];
    //  Specify the certificate to be used for encryption.
    bool setcert = [email SetEncryptCert: certInitaliser.privCert];
    if (!setcert) {
        NSLog(@"Error with cert %@", email.LastErrorText);
    }
    
    success = [mailman SendEmail: email];
    if (success != YES) {
        [strOutput appendString: mailman.LastErrorText];
        [strOutput appendString: @"\n"];
    }
    else {
        [strOutput appendString: @"Mail Sent!"];
        [strOutput appendString: @"\n"];
    }
    
    
    NSLog(@"Error %@", strOutput);
}

   
    


@end
