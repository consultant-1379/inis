//
//  ScanViewControllerTests.h
//  ENIS iOSTests
//
//  Created by Tuna Erdurmaz on 18/03/2012.
//  Copyright (c) 2012 Trinity College Dublin. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AppDelegate.h"
#import "ScanViewController.h"
#import "RequestProperty.h"

@interface ScanViewControllerTests : SenTestCase {
    AppDelegate *appDelegate;
    ScanViewController *scanViewController;
    UIView *scanView;
    NSString *jobString;
    RequestProperty *requestProp;
    NSString *retrieveuuid;
    NSString *statusAndTimeString;
    NSString *jobStatusImageString;
    NSString *mockTime;
    NSString *action;
}   

- (void)testAppDelegate;
- (void)testWorkOrderEntry;
- (void)testSerialNoEntry;
- (void)testAddJob;
- (void)testAddJobStatusAndTime;
- (void)testAddStatusImage;
- (void)testClearJob;
- (void)testCheckForDuplicateJob;
- (void)testCheckForDuplicateJobWorkOrder;
- (void)testCheckForDuplicateJobSerialNo;
- (void)testSendJobNodeNameRequestProp;
- (void)testSendJobStatusAndTimeRequestProp;
- (void)testSendJobActionRequestProp;
- (void)testSendJobUUIDRequestProp;
- (void)testRemoveDuplicateTag1;
- (void)testRemoveDuplicateTag2;
- (void)testRemoveDuplicateTag3;
- (void)testRemoveDuplicateTag4;

@end
