//
//  JobListViewControllerTests.m
//  ENIS
//
//  Created by Tuna Erdurmaz on 10/10/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "JobListViewControllerTests.h"
#import "JobListViewController.h"
#import "ScanViewControllerTests.h"
#import "RequestProperty.h"
#import "SSKeychain.h"
#import "SettingsViewController.h"

@implementation JobListViewControllerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    jobListViewController = appDelegate.jobListViewController;
    scanViewController = appDelegate.scanViewController;
    jobListView = jobListViewController.view;
    
    jobString1 = @"Test_STN1";
    jobString1 = [jobString1 stringByAppendingString:@"\n"];
    jobString1 = [jobString1 stringByAppendingString:@"SC111111111"];
    
    jobString2 = @"Test_STN2";
    jobString2 = [jobString2 stringByAppendingString:@"\n"];
    jobString2 = [jobString2 stringByAppendingString:@"SC222222222"];
    
    jobString3 = @"Test_STN3";
    jobString3 = [jobString3 stringByAppendingString:@"\n"];
    jobString3 = [jobString3 stringByAppendingString:@"SC333333333"];
    
    statusAndTimeString = @"Sending bind request";
    mockTime = @"05.10.2012 11:56";
    
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:mockTime];
    
    jobStatusImageString = @"status2";
    
    nodeName = @"Test_STN1";
    serialNo = @"SC111111111";
    action = @"cancel";
    
    [scanViewController addJob:jobString1];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    retrieveuuid = [SSKeychain passwordForService:@"com.ericsson.nis" account:@"user"];
    
    requestProp = [[RequestProperty alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
    
    jobString1 = @"";
    jobString2 = @"";
    jobString3 = @"";
    
    statusAndTimeString = @"";
    mockTime = @"";
    jobStatusImageString = @"";
    nodeName = @"";
    serialNo = @"";
    action = @"";
    retrieveuuid = @"";
    
    [jobListArray removeAllObjects];
    [statusAndTimeArray removeAllObjects];
    [statusImageArray removeAllObjects];
    
    [emailQueue removeAllObjects];
    
    isGPSLocation = NO;
    
    [requestProp release];
}


- (void)testDeleteJob {
    
    [jobListArray removeAllObjects];
    [statusAndTimeArray removeAllObjects];
    [statusImageArray removeAllObjects];
    
    [scanViewController addJob:jobString1];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController addJob:jobString2];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController addJob:jobString3];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    jobListViewController.tableView.allowsSelection = YES;
    
    [jobListViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                                           animated:NO
                                                           scrollPosition:UITableViewScrollPositionNone];
    
    [jobListViewController.editButton setTitle:@"Done"];
    [jobListViewController deleteJob];
    
    STAssertFalse([jobListArray containsObject:jobString2], @"deleteJob method for second row is failed.");
}

- (void)testCancelJobNotYetSent {
    [jobListArray removeAllObjects];
    [statusAndTimeArray removeAllObjects];
    [statusImageArray removeAllObjects];
    
    requestProp.NODENAME = @"Test_STN2";
    requestProp.SERIAL = @"SC222222222";
    [emailQueue addObject:requestProp];
    
    [scanViewController addJob:jobString1];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController addJob:jobString2];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController addJob:jobString3];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    jobListViewController.tableView.allowsSelection = YES;
    
    [jobListViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                                 animated:NO
                                           scrollPosition:UITableViewScrollPositionNone];
    
    [jobListViewController.editButton setTitle:@"Done"];
    [jobListViewController cancelJob];
    
    STAssertFalse([[statusAndTimeArray objectAtIndex:1] rangeOfString:@"Cancelled"].location == NSNotFound, @"cancelJob method for second row is failed. The status should be cancelled hence the job hasn't been sent yet.");
}

- (void)testCancelJobAlreadySent {
    [jobListArray removeAllObjects];
    [statusAndTimeArray removeAllObjects];
    [statusImageArray removeAllObjects];
    
    statusAndTimeString = @"Waiting for bind response";
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:mockTime];
    
    requestProp.NODENAME = @"Test_STN2";
    requestProp.SERIAL = @"SC222222222";
    [emailQueue addObject:requestProp];
    
    [scanViewController addJob:jobString1];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController addJob:jobString2];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController addJob:jobString3];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    jobListViewController.tableView.allowsSelection = YES;
    
    [jobListViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                                 animated:NO
                                           scrollPosition:UITableViewScrollPositionNone];
    
    [jobListViewController.editButton setTitle:@"Done"];
    [jobListViewController cancelJob];
    
    STAssertFalse([[statusAndTimeArray objectAtIndex:1] rangeOfString:@"Cancelling"].location == NSNotFound, @"cancelJob method for second row is failed. The status should be Cancelling.");
}

- (void)testCancelJobEmailQueue {
    [jobListArray removeAllObjects];
    [statusAndTimeArray removeAllObjects];
    [statusImageArray removeAllObjects];
    
    requestProp.NODENAME = @"Test_STN2";
    requestProp.SERIAL = @"SC222222222";
    [emailQueue addObject:requestProp];
    
    [scanViewController addJob:jobString1];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController addJob:jobString2];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController addJob:jobString3];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    jobListViewController.tableView.allowsSelection = YES;
    
    [jobListViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                                 animated:NO
                                           scrollPosition:UITableViewScrollPositionNone];
    
    [jobListViewController.editButton setTitle:@"Done"];
    [jobListViewController cancelJob];
    
    STAssertFalse([emailQueue containsObject:requestProp], @"requestProp should be removed from emailQueue after 'Cancelled' from 'Sending bind request' status.");
}

- (void)testAddCancelExpectedJob {
    [jobListViewController addCancelExpectedJob:jobString1];
    STAssertTrue([cancelExpectedJobArray containsObject:jobString1], @"addCancelExpectedJob method is failed");
}

- (void)testSendCancelJobRequestNodeNameRequestProp {
    
    [jobListViewController sendCancelJobRequest:0];
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEqualObjects([requestProp NODENAME], nodeName, @"Failed: expecting %@ but getting %@", nodeName, [requestProp NODENAME]);
}

- (void)testSendCancelJobRequestSerialNoRequestProp {
    
    [jobListViewController sendCancelJobRequest:0];
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEqualObjects([requestProp SERIAL], serialNo, @"Failed: expecting %@ but getting %@", serialNo, [requestProp SERIAL]);
}

- (void)testSendCancelJobRequestActionRequestProp {
    
    [jobListViewController sendCancelJobRequest:0];
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEqualObjects([requestProp ACTION], action, @"Failed: expecting %@ but getting %@", action, [requestProp ACTION]);
}

- (void)testSendCancelJobRequestUUIDRequestProp {
    
    [jobListViewController sendCancelJobRequest:0];
    
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEqualObjects([requestProp UUID], retrieveuuid, @"Failed: expecting %@ but getting %@", retrieveuuid, [requestProp UUID]);
}

- (void)testCancelJobRequestStatusAndTimeRequestProp {
    
    statusAndTimeString = @"Cancelling";
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:[appDelegate getCurrentDate]];
    
    [jobListViewController sendCancelJobRequest:0];
    
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEqualObjects([requestProp STATTIME], statusAndTimeString, @"Failed: expecting %@ but getting %@", statusAndTimeString, [requestProp STATTIME]);
}

@end
