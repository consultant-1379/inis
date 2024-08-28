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
#import "CkoEmail.h"
#import "EmailBodyCreator.h"
#import "BsimFileContents.h"
#import "ScanViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JobListViewController.h"
#import "Reachability.h"
#import "FileLogger.h"
#import "MailReciever.h"
#import "SettingsViewController.h"

@implementation MailSender

@synthesize bsimFile;

-(void)sendRequest:(RequestProperty*)reqProps{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    FLog(@"Sending new request");
    NSMutableString *strOutput = [NSMutableString stringWithCapacity:1000];
    AppDelegate *aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    bsimFile = [BsimFileContents sharedBsimContents];
    [aDelegate.mailLock lock];	
    CkoMailMan *mailman = [[[CkoMailMan alloc] init] autorelease];
    Properties *props = [BsimFileContents sharedBsimContents].properties;
    BOOL success;
    success = [mailman UnlockComponent: @"ERCSSNMAILQ_9vOBrSPO4R6g"];
    if (success != YES) {
        [strOutput appendString: mailman.LastErrorText];
        [strOutput appendString: @"\n"];
        FLog(@"Error %@", strOutput);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem sending email - Chilkat CkoMailMan licencing problem occurs" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert setTag:12];
        [alert show];
        [alert release];
        return;
    }
    
    if (props.outgoingForceSecurity) {
        mailman.SmtpSsl = YES; 
    }
    
    mailman.AutoFix = false;
    mailman.SmtpHost = props.outgoingMailServer;
    mailman.SmtpUsername = props.iPhoneEmailUsername;
    mailman.SmtpPassword = props.iPhoneEmailPassword;

    mailman.SmtpPort = props.outgoingMailServerPort;
    

    CkoEmail *email = [[[CkoEmail alloc] init] autorelease];
    EmailBodyCreator *emailBody = [[[EmailBodyCreator alloc] init] autorelease];
    
    email.Subject = @"BSIM Auto-Integration";
    NSString *body;
    body = [emailBody create:reqProps];
    email.Body = body;
    
    
    email.From = props.iPhoneEmailAddress;
    [email setSendSigned:true];
    
    [email AddTo: @"" emailAddress:props.bsimEmailAddress];
    [email setPkcs7CryptAlg:@"aes"];
    [email setPkcs7KeyLength:[NSNumber numberWithInt:256]];   //128
    
    email.SendEncrypted = YES;
    FLog([bsimFile.nisCert SerialNumber]);
    [email SetSigningCert:bsimFile.nisCert];
    bool setcert = [email SetEncryptCert: bsimFile.bsimCert];
    
    if (!setcert) {
        FLog(@"Error with cert %@", email.LastErrorText); 
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Certificate error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert setTag:12];
        [alert show];
    }
    
   
    bool result = [MailSender connectedToNetwork];
    if(result){
        success = [mailman SendEmail: email];
        if (success != YES) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Item not sent - connection failed to the mail server." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert setTag:12];
            [alert show];
            alert.delegate = nil; // Ensures subsequent delegate method calls won't crash
            alert = nil;
            [alert release];
            
            [strOutput appendString: mailman.LastErrorText];
            [strOutput appendString: @"\n"];
            FLog(strOutput);
        }
        else {
            NSString *statusAndTimeString = @"";
            int count = [jobListArray count];
            int i = 0;
            bool found = false;
            if ([reqProps.ACTION isEqualToString:@"bind"]) {
                statusAndTimeString = @"Waiting for bind response";
            }
            else if ([reqProps.ACTION isEqualToString:@"cancel"]) {
                statusAndTimeString = @"Waiting for cancel response";
            }
            statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
            statusAndTimeString = [statusAndTimeString stringByAppendingString:[aDelegate getCurrentDate]];
                
            while(i < count && found == false){
                NSString *job = [jobListArray objectAtIndex:i];
                NSArray *split = [job componentsSeparatedByString:@"\n"];
                NSString *currentNodeName = [split objectAtIndex:0];
                NSString *currentNodeSerial = [split objectAtIndex:1];
                if (( [currentNodeName isEqualToString:reqProps.NODENAME]) && ([currentNodeSerial isEqualToString:reqProps.SERIAL])) {
                    [statusAndTimeArray replaceObjectAtIndex:i withObject:statusAndTimeString];
                    found = true;
                }
                i++;
            }
                
            [aDelegate.jobListViewController.tableView reloadData];
            [aDelegate.jobListViewController.cancelAlertView dismissWithClickedButtonIndex:-1 animated:YES];
            [aDelegate.jobListViewController.deleteAlertView dismissWithClickedButtonIndex:-1 animated:YES];
            aDelegate.jobListViewController.cancelButton.enabled = NO;
            aDelegate.jobListViewController.deleteButton.enabled = NO;
                
            [strOutput appendString: @"Mail Sent!"];

            [strOutput appendString: @"\n"];
            aDelegate.performingNetworkTask = false;
            if (aDelegate.gettingUpdates == NO) {
                aDelegate.gettingUpdates = YES;
                MailReciever *mailReciever = [[[MailReciever alloc]init] autorelease];
                [NSThread detachNewThreadSelector:@selector(waitGetNewItemsFromBsim) toTarget:mailReciever withObject:nil];
            }
            FLog(strOutput);

        }
    }
    
    [aDelegate.mailLock unlock];
    
    [pool release];
}
   
-(void)dealloc{
    [super dealloc];
}

+ (BOOL) connectedToNetwork
{
    Properties *props = [BsimFileContents sharedBsimContents].properties;
	Reachability *r = [Reachability reachabilityWithHostName:props.outgoingMailServer ];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL internet;
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
		internet = NO;
	} else {
		internet = YES;
	}
	return internet;
} 

@end
