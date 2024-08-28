//
//  JobListViewControllerTests.h
//  ENIS
//
//  Created by Tuna Erdurmaz on 10/10/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AppDelegate.h"
#import "RequestProperty.h"

@interface JobListViewControllerTests : SenTestCase {
    AppDelegate *appDelegate;
    JobListViewController *jobListViewController;
    ScanViewController *scanViewController;
    UIView *jobListView;
    UIView *scanView;
    NSString *jobString1, *jobString2, *jobString3;
    NSString *statusAndTimeString;
    NSString *mockTime;
    NSString *jobStatusImageString;
    RequestProperty *requestProp;
    NSString *action;
    NSString *nodeName;
    NSString *serialNo;
    NSString *retrieveuuid;
}

- (void)testDeleteJob;
- (void)testCancelJobNotYetSent;
- (void)testCancelJobAlreadySent;
- (void)testAddCancelExpectedJob;
- (void)testSendCancelJobRequestNodeNameRequestProp;
- (void)testSendCancelJobRequestSerialNoRequestProp;
- (void)testSendCancelJobRequestActionRequestProp;
- (void)testSendCancelJobRequestUUIDRequestProp;
- (void)testCancelJobRequestStatusAndTimeRequestProp;
- (void)testCancelJobEmailQueue;

@end
