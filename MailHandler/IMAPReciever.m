//
//  IMAPReciever.m
//  ENIS
//
//  Created by Patrick Russell on 02/05/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "IMAPReciever.h"
#import "FileLogger.h"
#import "CkoImap.h"
#import "CkoEmailBundle.h"
#import "Response.h"
#import "CkoMessageSet.h"
#import "CkoEmail.h"
#import "MailReciever.h"
#import "AppDelegate.h"
@implementation IMAPReciever
@synthesize bsimFile, imap, useSsl, props;


-(NSArray *)getNewItemsFromEmail{
    NSMutableArray *emailList = [[[NSMutableArray alloc]init]autorelease];
    FLog(@"Getting new items from email");
    NSMutableString *strOutput = [NSMutableString stringWithCapacity:1000];
    self.bsimFile =  [BsimFileContents sharedBsimContents];
    props = self.bsimFile.properties;
    CkoCert *nisCert = self.bsimFile.nisCert;
    imap = [[CkoImap alloc] init];
    NSString *result;
    [imap SetDecryptCert2:nisCert key:nisCert.ExportPrivateKey];
    BOOL success;
    success = [imap UnlockComponent: @"ERCSSNIMAPMAILQ_4xD987C80R4K"];
    if (success != YES) {
        [strOutput appendString: imap.LastErrorText];
        [strOutput appendString: @"\n"];
        result = strOutput;
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem getting new emails" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert setTag:12];
        [alert show];
        FLog(@"Error with unlocking feature %@", result);
    }
    
    [imap setAutoFix:FALSE];
    /*
     mailman.MailHost = @"mail.welcome.ie";
     mailman.PopUsername = @"bsim@welcome.ie";
     mailman.PopPassword = @"AXVHh5wt";
     */
    if (props.incomingForceSecurity) {
        self.useSsl = YES;
    }
    imap.Port = props.incomingMailServerPort;

    if([self connected])
    {
    self.useSsl = YES;
        BOOL loggedin = [imap Login:props.iPhoneEmailUsername password:props.iPhoneEmailPassword];
    NSLog(@"Error: %@", imap.LastErrorText);
    CkoEmailBundle *bundle;
    if (loggedin) {
        
        [imap SelectMailbox:@"Inbox"];
        NSString *SEARCHCRITERIA = @"UNSEEN";
        CkoMessageSet *messageset = [imap Search:SEARCHCRITERIA bUid:true];
        if (messageset == nil) {
            FLog(@"MSGSETERROR %@", imap.LastErrorText);
            
        }
        //  Read mail headers and one line of the body.
        bundle = [imap FetchBundle:messageset];
        if (bundle == nil ) {
            [strOutput appendString: imap.LastErrorText];
            [strOutput appendString: @"\n"];
            result = strOutput;
            FLog(@"Nothing in email %@", result);
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Mail Received blank" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alert setTag:12];
            [alert show];
        }
        
        BOOL ascending;
        ascending = NO;
        [bundle SortByDate: ascending];
        int messageCount =  [[bundle MessageCount] intValue];
        CkoEmail *responseMail = [[CkoEmail alloc]init];
        
        for (int i = 0; i < messageCount; i++) {
            responseMail = [bundle GetEmail: [NSNumber numberWithInt: i]];
            
            Response *res = [MailReciever processEmail:responseMail];
            [emailList addObject:res];
            [imap SetMailFlag:responseMail flagName:@"Delete" value:[NSNumber numberWithInt:1]];
            
        }
        AppDelegate *aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([aDelegate statusWaitingCount] > 0) {
            aDelegate.gettingUpdates = YES;
            MailReciever *mailReciever = [[[MailReciever alloc]init] autorelease];
            [NSThread detachNewThreadSelector:@selector(waitGetNewItemsFromBsim) toTarget:mailReciever withObject:nil];
        }
  
        else {
            aDelegate.gettingUpdates = NO;
        }

    }
    else if(!loggedin){
        FLog(@"Could not log in to imap server");
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Mail Received blank" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert setTag:12];
        [alert show];
    }
    }
    AppDelegate *aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
      aDelegate.performingNetworkTask = false;
    return emailList;
    
}

-(BOOL)connected{
    bool isConnected;
    if(self.useSsl){
        isConnected = [imap Connect:props.incomingMailServer];
        self.imap.Ssl = YES;
        
    }
    else {
        isConnected = [imap Connect:props.incomingMailServer];
        self.imap.Ssl = NO;
        
    }
    return isConnected;
}

@end
