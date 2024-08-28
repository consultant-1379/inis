//
//  MailReciever.m
//  ENIS
//
//  Created by Patrick Russell on 02/05/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "MailReciever.h"
#import "FileLogger.h"
#import "CkoCert.h"
#import "BsimFileContents.h"
#import "AppDelegate.h"
#import "POPReciever.h"
#import "IMAPReciever.h"
#import "BsimFileContents.h"
#import "ScanViewController.h"
#import "JobListViewController.h"
#import "Validator.h"
#import "SettingsViewController.h"
#import "NotificationSettingsViewController.h"
#import "JobListViewController.h"

@implementation MailReciever

+(Response *)processEmail:(CkoEmail *)email{
    
    Response *response = [[[Response alloc]init] autorelease];
    Validator *validator = [[[Validator alloc]init] autorelease];
    
    NSString *validateResult = [validator validateEmail:email];
    
    if ( ![validateResult isEqualToString:@"success"] ) {
        FLog(@"Email not valid: %@", validateResult);
        return nil;
    }
        
    NSString *responseBody = email.Body;
    
    NSArray *array = [responseBody componentsSeparatedByString:@"\n"];
    
    if (array.count >= 5) {
    
        NSString *item = @"";
        int i = 0;

        // result
        item = [array objectAtIndex:i];
        for (item in array) {
            if ([item rangeOfString:@"result"].location != NSNotFound) {
                NSArray *itemArray = [item componentsSeparatedByString:@":"];
                response.RESULT = [itemArray objectAtIndex:1];
                break;
            }
            else {
                i++;
            }
        }
        
        
        // action
        i = 0;
        item = [array objectAtIndex:i];
        for (item in array) {
            if ([item rangeOfString:@"action"].location != NSNotFound) {
                NSArray *itemArray = [item componentsSeparatedByString:@":"];
                response.ACTION = [itemArray objectAtIndex:1];
                break;
            }
            else {
                i++;
            }
        }
        

        // workorder
        i = 0;
        item = [array objectAtIndex:i];
        for (item in array) {
            if ([item rangeOfString:@"workorder"].location != NSNotFound) {
                NSArray *itemArray = [item componentsSeparatedByString:@":"];
                response.NODENAME = [itemArray objectAtIndex:1];
                break;
            }
            else {
                i++;
            }
        }
        
        
        // nodeserial
        i = 0;
        item = [array objectAtIndex:i];
        for (item in array) {
            if ([item rangeOfString:@"nodeserial"].location != NSNotFound) {
                NSArray *itemArray = [item componentsSeparatedByString:@":"];
                response.NODESERIAL = [itemArray objectAtIndex:1];
                break;
            }
            else {
                i++;
            }
        }
     
        
    }
    return response;
}

-(void)waitGetNewItemsFromBsim{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
     FLog(@"Wait Get new items from bsim called");
    AppDelegate *aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    aDelegate.performingNetworkTask = YES;
    [NSThread sleepForTimeInterval:5.0];
    [self getNewItemsFromBsim];
    
     [pool release];
}

-(void)getNewItemsFromBsim{
    
    AppDelegate *aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    POPReciever *popMailReciever = [[[POPReciever alloc] init] autorelease];
    IMAPReciever *imapMailReciever = [[[IMAPReciever alloc] init] autorelease];
    NSArray *mailList = [[[NSArray alloc]init] autorelease];
    BsimFileContents *bsimFile =  [BsimFileContents sharedBsimContents];
    if ([aDelegate statusWaitingCount] == 0) {
        aDelegate.gettingUpdates = NO;
    }
    if ([bsimFile.properties.incomingMailProtocol isEqualToString:@"pop3"]) {
            if ([aDelegate statusWaitingCount] != 0) {

            mailList = [popMailReciever getNewItemsFromEmail];
            
        }
    }
    
    if ([bsimFile.properties.incomingMailProtocol isEqualToString:@"imap"]) { 
    if ([aDelegate statusWaitingCount] != 0) {
    
          mailList = [imapMailReciever getNewItemsFromEmail];
    }
    }

    if (mailList != nil) {
      
        
    NSString *statusImageString = @"";
    NSString *statusTimeString = @"";
    
    int messageCount = [mailList count];
    FLog(@"Mailbox count: %i", messageCount);
    
    for (int i = 0; i < messageCount; i++) {
        
        Response *currentResponse = [mailList objectAtIndex:i];
        NSString *jobString = currentResponse.NODENAME;
        jobString = [jobString stringByAppendingString:@"\n"];
        jobString = [jobString stringByAppendingString:currentResponse.NODESERIAL];
        
        if ([currentResponse.ACTION caseInsensitiveCompare:@"bind"] == NSOrderedSame) {
            if ([currentResponse.RESULT caseInsensitiveCompare:@"successful"] == NSOrderedSame) {
                
                FLog(@"cancelExpJobString: %@", jobString);
                if ( (cancelExpectedJobArray.count > 0 && [cancelExpectedJobArray containsObject:jobString]) || 
                    ([jobListArray containsObject:jobString] && ([[statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]] rangeOfString:@"Cancel Failed"].location != NSNotFound || [[statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]] rangeOfString:@"Cancelled"].location != NSNotFound)) ) {
                    
                    if ( [cancelExpectedJobArray containsObject:jobString] ) {
                        [cancelExpectedJobArray removeObject:jobString];
                        FLog(@"Count cancelExpectedJobArray: %i", [cancelExpectedJobArray count]);
                    }
                }
                else {
                    statusTimeString = @"Complete";
                    statusImageString = @"status3";
                    [self updateJobListAndCreateNotif:statusTimeString statusImageString:statusImageString currentResponse:currentResponse];
                }
            }
            else {
                
                FLog(@"cancelExpJobString: %@", jobString);
                if ( (cancelExpectedJobArray.count > 0 && [cancelExpectedJobArray containsObject:jobString]) || 
                    ([jobListArray containsObject:jobString] && ([[statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]] rangeOfString:@"Cancel Failed"].location != NSNotFound || [[statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]] rangeOfString:@"Cancelled"].location != NSNotFound)) ) {
                    
                    if ( [cancelExpectedJobArray containsObject:jobString] ) {
                        [cancelExpectedJobArray removeObject:jobString];
                        FLog(@"Count cancelExpectedJobArray: %i", [cancelExpectedJobArray count]);
                    }
                }
                else {
                    statusTimeString = @"Failed";
                    statusImageString = @"status4";
                    [self updateJobListAndCreateNotif:statusTimeString statusImageString:statusImageString currentResponse:currentResponse];
                }
            }
        }
        else if ([currentResponse.ACTION caseInsensitiveCompare:@"cancel"] == NSOrderedSame){
            
            if ([currentResponse.RESULT caseInsensitiveCompare:@"successful"] == NSOrderedSame) {
                
                FLog(@"cancelExpJobString: %@", jobString);
                if ( (cancelExpectedJobArray.count > 0 && [cancelExpectedJobArray containsObject:jobString]) || 
                    ([jobListArray containsObject:jobString] && ([[statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]] rangeOfString:@"Cancel Failed"].location != NSNotFound || [[statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]] rangeOfString:@"Cancelled"].location != NSNotFound)) ) {
                    
                    if ( [cancelExpectedJobArray containsObject:jobString] ) {
                        [cancelExpectedJobArray removeObject:jobString];
                        FLog(@"Count cancelExpectedJobArray: %i", [cancelExpectedJobArray count]);
                    }
                }
                
                statusTimeString = @"Cancelled";
                statusImageString = @"status3";
                [self updateJobListAndCreateNotif:statusTimeString statusImageString:statusImageString currentResponse:currentResponse];
            }
            else {
                
                FLog(@"cancelExpJobString: %@", jobString);
                if ( (cancelExpectedJobArray.count > 0 && [cancelExpectedJobArray containsObject:jobString]) || 
                    ([jobListArray containsObject:jobString] && ([[statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]] rangeOfString:@"Cancel Failed"].location != NSNotFound || [[statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]] rangeOfString:@"Cancelled"].location != NSNotFound)) ) {
                    
                    if ( [cancelExpectedJobArray containsObject:jobString] ) {
                        [cancelExpectedJobArray removeObject:jobString];
                        FLog(@"Count cancelExpectedJobArray: %i", [cancelExpectedJobArray count]);
                    }
                }
                
                statusTimeString = @"Cancel Failed";
                statusImageString = @"status4";
                [self updateJobListAndCreateNotif:statusTimeString statusImageString:statusImageString currentResponse:currentResponse];
            }
            
        }
        else if (aDelegate.gettingUpdates) {
            aDelegate.gettingUpdates = YES;
        }
    }
  }

}
   
- (void)updateJobListAndCreateNotif:(NSString *)statusTimeString statusImageString:(NSString *)statusImageString currentResponse:(Response *)currentResponse {
    
    AppDelegate *aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIApplication *app = [UIApplication sharedApplication];
    UILocalNotification *localNotif; //  = [[[UILocalNotification alloc] init] autorelease]
    
    NSString *tmpStatus = @"";
    tmpStatus = statusTimeString;
    
    statusTimeString = [statusTimeString stringByAppendingString:@"\n"];
    statusTimeString = [statusTimeString stringByAppendingString:[aDelegate getCurrentDate]];
    int count = [jobListArray count];
    int j = 0;
    bool found = false;
    NSString *responseNodeName = currentResponse.NODENAME;
    NSString *responseNodeSerial = currentResponse.NODESERIAL;
    while(j < count && found == false){
        NSString *job = [jobListArray objectAtIndex:j];
        NSArray *splitJob = [job componentsSeparatedByString:@"\n"];
        NSString *currentNodeName = [splitJob objectAtIndex:0];
        NSString *currentNodeSerial = [splitJob objectAtIndex:1];
        
        NSString *strStatusAndTime = [statusAndTimeArray objectAtIndex:j];
        NSArray *splitStatusAndTime = [strStatusAndTime componentsSeparatedByString:@"\n"];
        NSString *currentStatus = [splitStatusAndTime objectAtIndex:0];
        
        if (( [currentNodeName isEqualToString:responseNodeName]) && ([currentNodeSerial isEqualToString:responseNodeSerial])) {
            
            if ( ![currentStatus isEqualToString:tmpStatus] ) {   // Check added to prevent dublicate updates/notifs
                [statusAndTimeArray replaceObjectAtIndex:j withObject:statusTimeString];
                [statusImageArray replaceObjectAtIndex:j withObject:statusImageString];
                found = true;
                
                // Create Local Notification for a job update
                if ( ![notifValue isEqualToString:Off] ) {
                    FLog(@"Notifications %@", notifValue);
                    
                    bool isFailed;
                    isFailed = ([statusTimeString rangeOfString:@"Failed"].location != NSNotFound);
                    
                    if ( ([notifValue isEqualToString:On]) || ([notifValue isEqualToString:Error_only] && isFailed)  ) {
                        localNotif = [self createNotification:currentNodeSerial status:statusTimeString];
                        localNotif.soundName = UILocalNotificationDefaultSoundName;
                        localNotif.applicationIconBadgeNumber = iconBadgeNumber++;
                        [app presentLocalNotificationNow:localNotif];
                    }
                }
                
                [aDelegate.jobListViewController.tableView reloadData];
                [aDelegate.jobListViewController.cancelAlertView dismissWithClickedButtonIndex:-1 animated:YES];
                [aDelegate.jobListViewController.deleteAlertView dismissWithClickedButtonIndex:-1 animated:YES];
                aDelegate.jobListViewController.cancelButton.enabled = NO;
                aDelegate.jobListViewController.deleteButton.enabled = NO;
            }
        }
        j++; 
        
        FLog(@"item %@", job);
    }
}

- (UILocalNotification *)createNotification:(NSString *)nodeSerial status:(NSString *)status {
    
    UILocalNotification *localNotif = [[[UILocalNotification alloc] init] autorelease];
    if (localNotif) {
            
        localNotif.alertBody = [NSString stringWithFormat:@"Job updated - %@\n%@", nodeSerial, status];
        localNotif.alertAction = @"View";
    }
    
    return localNotif;
}

@end
