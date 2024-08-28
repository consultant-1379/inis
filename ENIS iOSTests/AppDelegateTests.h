//
//  AppDelegateTests.h
//  ENIS
//
//  Created by Tuna Erdurmaz on 02/11/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AppDelegate.h"

@interface AppDelegateTests : SenTestCase {
    AppDelegate *appDelegate;
    NSDateFormatter *dateFormatter;
    NSDate *ENISCertNOTExpiredDate;
    NSDate *ENISCertExpiredDate;
    NSString *statusAndTimeString;
    NSString *mockTime;
    ScanViewController *scanViewController;
}

- (void)testAppDelegate;
- (void)testENISCertificateNOTExpired;
- (void)testENISCertificateExpired;
- (void)testFormatExpiryDate;
- (void)testStatusWaitingCountZero;
- (void)testStatusWaitingCountOne;
- (void)testStatusWaitingCountMultiple;
- (void)testAddSplashViewNotNil;
- (void)testAddSplashViewIsRoot;
- (void)testAddEndpointConfigViewNotNil;

@end
