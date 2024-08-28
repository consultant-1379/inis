//
//  AppDelegateTests.m
//  ENIS
//
//  Created by Tuna Erdurmaz on 02/11/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "AppDelegateTests.h"
#import "AppDelegate.h"
#import "ScanViewControllerTests.h"
#import "OCMock.h"
#import "MailSender.h"

@implementation AppDelegateTests

- (void)setUp
{
    [super setUp];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    scanViewController = appDelegate.scanViewController;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    
    ENISCertNOTExpiredDate = [dateFormatter dateFromString:@"15.04.2050 13:29:31"];
    ENISCertExpiredDate = [dateFormatter dateFromString:@"12.08.2012 12:28:53"];
    
    statusAndTimeString = @"Sending bind request";
    mockTime = @"05.10.2012 11:56";
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
    [dateFormatter release];
    
    statusAndTimeString = @"";
    mockTime = @"";
    
    [statusAndTimeArray removeAllObjects];
    
    scanViewController = nil;
}

- (void) testAppDelegate {
    STAssertNotNil(appDelegate, @"Cannot find the application delegate");
}

- (void)testENISCertificateNOTExpired {
    STAssertFalse([appDelegate ENISCertificateExpired:ENISCertNOTExpiredDate], @"ENISCertificateExpired method is failed");
}

- (void)testENISCertificateExpired {
    STAssertTrue([appDelegate ENISCertificateExpired:ENISCertExpiredDate], @"ENISCertificateExpired method is failed");
}

- (void)testFormatExpiryDate {
    STAssertEqualObjects([appDelegate formatExpiryDate:ENISCertExpiredDate], @"Aug 12, 2012, 12:28:53 PM", @"Failed: expecting  but getting %@", [appDelegate formatExpiryDate:ENISCertExpiredDate]);
}

- (void)testStatusWaitingCountZero {
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:mockTime];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    
    STAssertTrue([appDelegate statusWaitingCount] == 0, @"statusWaitingCount method is failed. Expecting 0 but getting %i occurrences.", [appDelegate statusWaitingCount]);
}

- (void)testStatusWaitingCountOne {
    statusAndTimeString = @"Waiting for bind request";
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:mockTime];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    
    STAssertTrue([appDelegate statusWaitingCount] == 1, @"statusWaitingCount method is failed. Expecting 0 but getting %i occurrences.", [appDelegate statusWaitingCount]);
}

- (void)testStatusWaitingCountMultiple {
    statusAndTimeString = @"Waiting for bind request";
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:mockTime];
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    
    statusAndTimeString = @"Waiting for bind response";
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    
    statusAndTimeString = @"Waiting for cancel response";
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    
    statusAndTimeString = @"Sending bind request";
    [scanViewController addJobStatusAndTime:statusAndTimeString];
    
    STAssertTrue([appDelegate statusWaitingCount] == 3, @"statusWaitingCount method is failed. Expecting 0 but getting %i occurrences.", [appDelegate statusWaitingCount]);
}

- (void)testAddSplashViewNotNil {
    [appDelegate addSplashView];
    STAssertTrue([appDelegate splashViewController] != nil, @"addSplashView method is failed. splashViewController shouldn't be nil  but %@.", [appDelegate splashViewController]);
}

- (void)testAddSplashViewIsRoot {
    [appDelegate addSplashView];
    STAssertEqualObjects([appDelegate splashViewController], appDelegate.window.rootViewController, @"splashViewController is not a rootViewController.");
}

- (void)testAddEndpointConfigViewNotNil {
    [appDelegate addEndpointConfigView];
    STAssertTrue([appDelegate endpointConfigViewController] != nil, @"addEndpointConfigView method is failed. endpointConfigViewController shouldn't be nil  but %@.", [appDelegate endpointConfigViewController]);
}

@end
