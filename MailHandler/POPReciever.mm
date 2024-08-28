//
//  POPReciever.m
//  ENIS
//
//  Created by Patrick Russell on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "POPReciever.h"
#import "CkoMailMan.h"
#import "CkoCert.h"
#import "CertInitialiser.h"
#import "CkoEmailBundle.h"
#import "CkoStringArray.h"
#import "CkoEmail.h"
#import "ScanViewController.h"
#import "FileLogger.h"
#import "MailSender.h"
#import "MailReciever.h"

@implementation POPReciever
@synthesize bsimFile;

-(NSArray *)getNewItemsFromEmail{
    NSMutableArray *emailList = [[[NSMutableArray alloc]init]autorelease];
    FLog(@"Getting new items from email");
    NSMutableString *strOutput = [NSMutableString stringWithCapacity:1000];
    self.bsimFile =  [BsimFileContents sharedBsimContents];
    Properties *props = self.bsimFile.properties;
    CkoCert *nisCert = self.bsimFile.nisCert;
    CkoMailMan *mailman = [[[CkoMailMan alloc] init] autorelease];
    NSString *result;
    [mailman SetDecryptCert2:nisCert key:nisCert.ExportPrivateKey];
    BOOL success;
    success = [mailman UnlockComponent: @"ERCSSNIMAPMAILQ_4xD987C80R4K"];
    if (success != YES) {
        [strOutput appendString: mailman.LastErrorText];
        [strOutput appendString: @"\n"];
        result = strOutput;
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem getting new emails" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert setTag:12];
        [alert show];
        FLog(@"Error with unlocking feature %@", result);
    }
    AppDelegate *aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [mailman setAutoFix:FALSE];

    if (props.incomingForceSecurity) {
        mailman.PopSsl = YES; 
    }
    
    mailman.MailPort = props.incomingMailServerPort;
    mailman.MailHost = props.incomingMailServer;
    mailman.PopUsername = props.iPhoneEmailUsername;
    mailman.PopPassword = props.iPhoneEmailPassword;
    
    
    if ([aDelegate statusWaitingCount] > 0) {
        aDelegate.gettingUpdates = YES;
        MailReciever *mailReciever = [[[MailReciever alloc]init] autorelease];
        [NSThread detachNewThreadSelector:@selector(waitGetNewItemsFromBsim) toTarget:mailReciever withObject:nil];
    }

    else {
        aDelegate.gettingUpdates = NO;
    }

    
    int numMessages = [[mailman GetMailboxCount] intValue];
    if (numMessages == 0) {
        aDelegate.performingNetworkTask = NO;
        return nil;
    }

    CkoEmailBundle *bundle;
    //  Read mail headers and one line of the body.
    bundle = mailman.CopyMail;
    
    if (bundle == nil ) {
        [strOutput appendString: mailman.LastErrorText];
        [strOutput appendString: @"\n"];
        result = strOutput;
        FLog(@"Network Connection Issue %@", result);
        aDelegate.performingNetworkTask = false;
        return nil;
    }

    BOOL ascending;
    ascending = NO;
    [bundle SortByDate: ascending];
    int messageCount =  [[bundle MessageCount] intValue];
    CkoEmail *responseMail;
    
    for (int i = 0; i < messageCount; i++) {
        responseMail = [bundle GetEmail: [NSNumber numberWithInt: i]];
    Response *res = [MailReciever processEmail:responseMail];
        if (res != nil) {
             [emailList addObject:res];
        }
       
    [mailman DeleteEmail:responseMail];
        
    }
   
     aDelegate.performingNetworkTask = false;   
     return emailList;

}


-(void)dealloc{
    [super dealloc];
    //[bsimFile release]; /* No need to release since there is pool release */
}

@end
