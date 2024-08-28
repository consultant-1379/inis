//
//  ScanViewControllerTests.m
//  ENIS iOSTests
//
//  Created by Tuna Erdurmaz on 18/03/2012.
//  Copyright (c) 2012 Trinity College Dublin. All rights reserved.
//

#import "ScanViewControllerTests.h"
#import "RequestProperty.h"
#import "SSKeychain.h"
#import "SettingsViewController.h"

@implementation ScanViewControllerTests

- (void)setUp
{
    [super setUp];
    NSLog(@"Test Set-up");
    
    // Set-up code here.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    scanViewController = appDelegate.scanViewController;
    scanView = scanViewController.view;
    
    // Changing below initializations will cause some test failures
    [[scanViewController workOrderTextField] setText:@"Test_STN4"];
    [[scanViewController serialNoTextField] setText:@"SC316295434"];
    
    jobString = [[scanViewController workOrderTextField] text];
    jobString = [jobString stringByAppendingString:@"\n"];
    jobString = [jobString stringByAppendingString:[[scanViewController serialNoTextField] text]];
    
    statusAndTimeString = @"Sending bind request";
    mockTime = @"05.10.2012 11:56";
    jobStatusImageString = @"status2";
    
    retrieveuuid = [SSKeychain passwordForService:@"com.ericsson.nis" account:@"user"];
    
    action = @"bind";
}

- (void)tearDown
{
    // Tear-down code here.
    NSLog(@"Test Tear-down");
    
    [super tearDown];
    [[scanViewController workOrderTextField] setText:@""];
    [[scanViewController serialNoTextField] setText:@""];
    
    jobString = @"";
    retrieveuuid = @"";
    statusAndTimeString = @"";
    jobStatusImageString = @"";
    mockTime = @"";
    action = @"";
    retrieveuuid = @"";
    
    [jobListArray removeAllObjects];
    [statusAndTimeArray removeAllObjects];
    [statusImageArray removeAllObjects];
    
    [emailQueue removeAllObjects];
    
    isGPSLocation = NO;
}

- (void) testAppDelegate {
    STAssertNotNil(appDelegate, @"Cannot find the application delegate");
}

- (void)testWorkOrderEntry {
    STAssertTrue([[scanViewController.workOrderTextField text] isEqualToString:@"Test_STN4"], @"Scan Work-Order field data doesn't match with the entry.");
}

- (void)testSerialNoEntry {
    STAssertTrue([[scanViewController.serialNoTextField text] isEqualToString:@"SC316295434"], @"Scan Serial Number field data doesn't match with the entry.");
}

- (void)testAddJob {
    
    [scanViewController addJob:jobString];
    STAssertTrue([jobListArray containsObject:jobString], @"Job List Array doesn't contain the object.");
}

- (void)testAddJobStatusAndTime {
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:mockTime];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    STAssertTrue([statusAndTimeArray containsObject:statusAndTimeString], @"Status and Time Array doesn't contain the object.");
}

- (void)testAddStatusImage {
    [scanViewController addStatusImage:jobStatusImageString];
    STAssertTrue([statusImageArray containsObject:jobStatusImageString], @"Status Image Array doesn't contain the object.");
}

- (void)testClearJob {
    [scanViewController.clearButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertTrue([[[scanViewController workOrderTextField] text] isEqualToString:@""], @"Word Order Text Field is not cleared.");
    STAssertTrue([[[scanViewController serialNoTextField] text] isEqualToString:@""], @"Serial No Text Field is not cleared.");
}

- (void)testCheckForDuplicateJob {
    [scanViewController addJob:jobString];
    STAssertTrue([scanViewController checkForDuplicateJob], @"checkForDuplicateJob method is failed.");
}

- (void)testCheckForDuplicateJobWorkOrder {
    [[scanViewController workOrderTextField] setText:@"Test_STN4"];
    [[scanViewController serialNoTextField] setText:@"SC854483798"];
    [scanViewController addJob:jobString];
    STAssertTrue([scanViewController checkForDuplicateJobWorkOrder], @"checkForDuplicateJobWorkOrder method is failed.");
}

- (void)testCheckForDuplicateJobSerialNo {
    [[scanViewController workOrderTextField] setText:@"Test_STN8"];
    [[scanViewController serialNoTextField] setText:@"SC316295434"];
    [scanViewController addJob:jobString];
    STAssertTrue([scanViewController checkForDuplicateJobSerialNo], @"checkForDuplicateJobSerialNo method is failed.");
}

- (void)testSendJobNodeNameRequestProp {
    NSString *nodeName = [[scanViewController workOrderTextField] text];
    
    [scanViewController sendJob];
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEquals([requestProp NODENAME], nodeName, @"Failed: expecting %@ but getting %@", nodeName, [requestProp NODENAME]);
}

- (void)testSendJobSerialNoRequestProp {
    NSString *serialNo = [[scanViewController serialNoTextField] text];
    
    [scanViewController sendJob];
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEquals([requestProp SERIAL], serialNo, @"Failed: expecting %@ but getting %@", serialNo, [requestProp SERIAL]);
}

- (void)testSendJobStatusAndTimeRequestProp {
    
    statusAndTimeString = @"Sending bind request";
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:[appDelegate getCurrentDate]];
    
    [scanViewController sendJob];
    
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEqualObjects([requestProp STATTIME], statusAndTimeString, @"Failed: expecting %@ but getting %@", statusAndTimeString, [requestProp STATTIME]);
}

- (void)testSendJobActionRequestProp {
    
    [scanViewController sendJob];
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEqualObjects([requestProp ACTION], action, @"Failed: expecting %@ but getting %@", action, [requestProp ACTION]);
}

- (void)testSendJobUUIDRequestProp {
    
    [scanViewController sendJob];
    
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEqualObjects([requestProp UUID], retrieveuuid, @"Failed: expecting %@ but getting %@", retrieveuuid, [requestProp UUID]);
}

- (void)testSendJobLocationIncludedRequestProp {
    [scanViewController sendJob];
    
    if ([emailQueue count] > 0) {
        requestProp = [emailQueue objectAtIndex:0];
    }
    STAssertEqualObjects([requestProp LOCATIONINCLUDED], @"false", @"Failed: expecting %@ but getting %@", @"true", [requestProp LOCATIONINCLUDED]);
}

- (void)testRemoveDuplicateTag1 {
    
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:mockTime];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    
    [scanViewController addJob:jobString];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController removeDuplicateTag1];
    
    int occurrences = 0;
    for (NSString *job in jobListArray) {
        occurrences += [job isEqualToString:jobString] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for jobListArray. Expecting 1 but getting %i occurrences.", occurrences);
    
    occurrences = 0;
    for (NSString *statusAndTime in statusAndTimeArray) {
        occurrences += [statusAndTime isEqualToString:statusAndTimeString] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for statusAndTimeArray. Expecting 1 but getting %i occurrences.", occurrences);
    
    occurrences = 0;
    for (NSString *statusImage in statusImageArray) {
        occurrences += [statusImage isEqualToString:statusImage] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for statusImageArray. Expecting 1 but getting %i occurrences.", occurrences);
}

- (void)testRemoveDuplicateTag2 {
    
    NSString *jobString1 = @"Test_STN4";
    jobString1 = [jobString1 stringByAppendingString:@"\n"];
    jobString1 = [jobString1 stringByAppendingString:@"SC1111111111"];
                  
    NSString *jobString2 = @"Test_STN5";
    jobString2 = [jobString2 stringByAppendingString:@"\n"];
    jobString2 = [jobString2 stringByAppendingString:@"SC316295434"];
    
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:[appDelegate getCurrentDate]];
    
    [scanViewController addJob:jobString1];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
                  
    [scanViewController addJob:jobString2];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController removeDuplicateTag2];
    
    int occurrences = 0;
    for (NSString *job in jobListArray) {
        occurrences += [job isEqualToString:jobString] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for jobListArray. Expecting 1 but getting %i occurrences.", occurrences);
    
    occurrences = 0;
    for (NSString *statusAndTime in statusAndTimeArray) {
        occurrences += [statusAndTime isEqualToString:statusAndTimeString] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for statusAndTimeArray. Expecting 1 but getting %i occurrences.", occurrences);
    
    occurrences = 0;
    for (NSString *statusImage in statusImageArray) {
        occurrences += [statusImage isEqualToString:statusImage] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for statusImageArray. Expecting 1 but getting %i occurrences.", occurrences);
}

- (void)testRemoveDuplicateTag3 {
    
    NSString *jobString1 = @"Test_STN4";
    jobString1 = [jobString1 stringByAppendingString:@"\n"];
    jobString1 = [jobString1 stringByAppendingString:@"SC1111111111"];
    
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:[appDelegate getCurrentDate]];
    
    [scanViewController addJob:jobString1];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController removeDuplicateTag3];
    
    int occurrences = 0;
    for (NSString *job in jobListArray) {
        occurrences += [job isEqualToString:jobString] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for jobListArray. Expecting 1 but getting %i occurrences.", occurrences);
    
    occurrences = 0;
    for (NSString *statusAndTime in statusAndTimeArray) {
        occurrences += [statusAndTime isEqualToString:statusAndTimeString] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for statusAndTimeArray. Expecting 1 but getting %i occurrences.", occurrences);
    
    occurrences = 0;
    for (NSString *statusImage in statusImageArray) {
        occurrences += [statusImage isEqualToString:statusImage] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for statusImageArray. Expecting 1 but getting %i occurrences.", occurrences);
}

- (void)testRemoveDuplicateTag4 {
    
    NSString *jobString1 = @"Test_STN5";
    jobString1 = [jobString1 stringByAppendingString:@"\n"];
    jobString1 = [jobString1 stringByAppendingString:@"SC316295434"];
    
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:[appDelegate getCurrentDate]];
    
    [scanViewController addJob:jobString1];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    [scanViewController addStatusImage:jobStatusImageString];
    
    [scanViewController removeDuplicateTag4];
    
    int occurrences = 0;
    for (NSString *job in jobListArray) {
        occurrences += [job isEqualToString:jobString] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for jobListArray. Expecting 1 but getting %i occurrences.", occurrences);
    
    occurrences = 0;
    for (NSString *statusAndTime in statusAndTimeArray) {
        occurrences += [statusAndTime isEqualToString:statusAndTimeString] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for statusAndTimeArray. Expecting 1 but getting %i occurrences.", occurrences);
    
    occurrences = 0;
    for (NSString *statusImage in statusImageArray) {
        occurrences += [statusImage isEqualToString:statusImage] ? 1 : 0;
    }
    STAssertTrue(occurrences == 1, @"removeDuplicateTag1 method is failed for statusImageArray. Expecting 1 but getting %i occurrences.", occurrences);
}

@end
