//
//  EmailBodyCreatorTests.m
//  ENIS
//
//  Created by Tuna Erdurmaz on 12/12/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "EmailBodyCreatorTests.h"
#import "EmailBodyCreator.h"
#import "SSKeychain.h"

@implementation EmailBodyCreatorTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    nodeName = @"Test_STN1";
    serialNo = @"SC111111111";
    actionBind = @"bind";
    actionCancel = @"cancel";
    retrieveuuid = [SSKeychain passwordForService:@"com.ericsson.nis" account:@"user"];
    EPSG = @"4326";
    
    requestProp = [[RequestProperty alloc] init];
    emailBodyCreator = [[EmailBodyCreator alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
    
    nodeName = @"";
    serialNo = @"";
    actionBind = @"";
    actionCancel = @"";
    retrieveuuid = @"";
    EPSG = @"";
    
    [requestProp release];
    [emailBodyCreator release];
}

- (void)testCreateRequestPropActionBind {
    requestProp.ACTION = actionBind;
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"action=bind\n"].location != NSNotFound, @"create method is failed. The result string should contain action=%@ but contains %@", [requestProp ACTION]);
}

- (void)testCreateRequestPropActionCancel {
    requestProp.ACTION = actionCancel;
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"action=cancel\n"].location != NSNotFound, @"create method is failed. The result string should contain action=%@", [requestProp ACTION]);
}

- (void)testCreateRequestPropNodeNameActionBind {
    requestProp.ACTION = actionBind;
    requestProp.NODENAME = nodeName;
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"workorder=Test_STN1\n"].location != NSNotFound, @"create method is failed. The result string should contain workorder=%@", [requestProp NODENAME]);
}

- (void)testCreateRequestPropSerialActionBind {
    requestProp.ACTION = actionBind;
    requestProp.SERIAL = serialNo;
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"nodeserial=SC111111111\n"].location != NSNotFound, @"create method is failed. The result string should contain nodeserial=%@", [requestProp SERIAL]);
}

- (void)testCreateRequestPropNodeNameActionCancel {
    requestProp.ACTION = actionCancel;
    requestProp.NODENAME = nodeName;
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"workorder=Test_STN1\n"].location != NSNotFound, @"create method is failed. The result string should contain workorder=%@", [requestProp NODENAME]);
}

- (void)testCreateRequestPropSerialActionCancel {
    requestProp.ACTION = actionCancel;
    requestProp.SERIAL = serialNo;
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"nodeserial=SC111111111\n"].location != NSNotFound, @"create method is failed. The result string should contain nodeserial=%@", [requestProp SERIAL]);
}

- (void)testCreateRequestPropUUID {
    requestProp.ACTION = actionBind;
    requestProp.UUID = retrieveuuid;
    NSString *strIMSI = [NSString stringWithFormat:@"IMSI=%@\n", retrieveuuid];
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:strIMSI].location != NSNotFound, @"create method is failed. The result string should contain IMSI=%@.", [requestProp UUID]);
}

- (void)testCreateRequestPropLocationIncludedFalse {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"false";
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"gps.included=false"].location != NSNotFound, @"create method is failed. The result string should contain gps.included=%@", [requestProp LOCATIONINCLUDED]);
}

- (void)testCreateRequestPropLocationIncludedTrue {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"true";
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"gps.included=true"].location != NSNotFound, @"create method is failed. The result string should contain gps.included=%@", [requestProp LOCATIONINCLUDED]);
}

- (void)testCreateRequestDate {
    
    requestProp.ACTION = actionBind;
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter;
	dateFormatter = nil;
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"EEE MMM d HH:mm:ss z yyyy"];
    NSString *stringdate = [dateFormatter stringFromDate:now];
    [dateFormatter release];
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:stringdate].location != NSNotFound, @"create method is failed. The result string should contain #%@\n.", stringdate);
}

- (void)testCreateRequestPropLatitudeActionBindLocationIncludedTrue {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"true";
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"gps.latitude="].location != NSNotFound, @"create method is failed. The result string should contain gps.latitude=");
}

- (void)testCreateRequestPropLongitudeActionBindLocationIncludedTrue {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"true";
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"gps.longitude="].location != NSNotFound, @"create method is failed. The result string should contain gps.longitude=");
}

- (void)testCreateRequestPropAltitudeActionBindLocationIncludedTrue {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"true";
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"gps.altitude="].location != NSNotFound, @"create method is failed. The result string should contain gps.altitude=");
}

- (void)testCreateRequestPropAccuracyActionBindLocationIncludedTrue {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"true";
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"gps.accuracy="].location != NSNotFound, @"create method is failed. The result string should contain gps.accuracy=");
}

- (void)testCreateRequestPropFixageActionBindLocationIncludedTrue {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"true";
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"gps.fixage="].location != NSNotFound, @"create method is failed. The result string should contain gps.fixage=");
}

- (void)testCreateRequestPropCRSActionBindLocationIncludedTrue {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"true";
    requestProp.CRS = EPSG;
    
    STAssertTrue([[emailBodyCreator create:requestProp] rangeOfString:@"gps.crs=4326"].location != NSNotFound, @"create method is failed. The result string should contain gps.crs=%@", [requestProp CRS]);
}

- (void)testCreateRequestPropLatitudeActionBindLocationIncludedFalse {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"false";
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.latitude="].location != NSNotFound, @"create method is failed. The result string should contain gps.latitude=");
}

- (void)testCreateRequestPropLongitudeActionBindLocationIncludedFalse {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"false";
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.longitude="].location != NSNotFound, @"create method is failed. The result string should contain gps.longitude=");
}

- (void)testCreateRequestPropAltitudeActionBindLocationIncludedFalse {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"false";
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.altitude="].location != NSNotFound, @"create method is failed. The result string should contain gps.altitude=");
}

- (void)testCreateRequestPropAccuracyActionBindLocationIncludedFalse {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"false";
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.accuracy="].location != NSNotFound, @"create method is failed. The result string should contain gps.accuracy=");
}

- (void)testCreateRequestPropFixageActionBindLocationIncludedFalse {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"false";
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.fixage="].location != NSNotFound, @"create method is failed. The result string should contain gps.fixage=");
}

- (void)testCreateRequestPropCRSActionBindLocationIncludedFalse {
    requestProp.ACTION = actionBind;
    requestProp.LOCATIONINCLUDED = @"false";
    requestProp.CRS = EPSG;
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.crs=4326"].location != NSNotFound, @"create method is failed. The result string should contain gps.crs=%@", [requestProp CRS]);
}

- (void)testCreateRequestPropLatitudeActionCancel {
    requestProp.ACTION = actionCancel;
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.latitude="].location != NSNotFound, @"create method is failed. The result string should contain gps.latitude=");
}

- (void)testCreateRequestPropLongitudeActionCancel {
    requestProp.ACTION = actionCancel;
    requestProp.LOCATIONINCLUDED = @"false";
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.longitude="].location != NSNotFound, @"create method is failed. The result string should contain gps.longitude=");
}

- (void)testCreateRequestPropAltitudeActionCancel {
    requestProp.ACTION = actionCancel;
    requestProp.LOCATIONINCLUDED = @"false";
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.altitude="].location != NSNotFound, @"create method is failed. The result string should contain gps.altitude=");
}

- (void)testCreateRequestPropAccuracyActionCancel {
    requestProp.ACTION = actionCancel;
    requestProp.LOCATIONINCLUDED = @"false";
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.accuracy="].location != NSNotFound, @"create method is failed. The result string should contain gps.accuracy=");
}

- (void)testCreateRequestPropFixageActionCancel {
    requestProp.ACTION = actionCancel;
    requestProp.LOCATIONINCLUDED = @"false";
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.fixage="].location != NSNotFound, @"create method is failed. The result string should contain gps.fixage=");
}

- (void)testCreateRequestPropCRSActionCancel {
    requestProp.ACTION = actionCancel;
    requestProp.CRS = EPSG;
    
    STAssertFalse([[emailBodyCreator create:requestProp] rangeOfString:@"gps.crs=4326"].location != NSNotFound, @"create method is failed. The result string should contain gps.crs=%@", [requestProp CRS]);
}

@end
