//
//  EmailBodyCreatorTests.h
//  ENIS
//
//  Created by Tuna Erdurmaz on 12/12/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RequestProperty.h"
#import "EmailBodyCreator.h"

@interface EmailBodyCreatorTests : SenTestCase {
    RequestProperty *requestProp;
    EmailBodyCreator *emailBodyCreator;
    NSString *actionBind, *actionCancel;
    NSString *nodeName;
    NSString *serialNo;
    NSString *retrieveuuid;
    NSString *EPSG;
}

- (void)testCreateRequestPropActionBind;
- (void)testCreateRequestPropActionCancel;
- (void)testCreateRequestPropNodeNameActionBind;
- (void)testCreateRequestPropSerialActionBind;
- (void)testCreateRequestPropNodeNameActionCancel;
- (void)testCreateRequestPropSerialActionCancel;
- (void)testCreateRequestPropUUID;
- (void)testCreateRequestDate;
- (void)testCreateRequestPropLocationIncludedFalse;
- (void)testCreateRequestPropLocationIncludedTrue;

- (void)testCreateRequestPropLatitudeActionBindLocationIncludedTrue;
- (void)testCreateRequestPropLongitudeActionBindLocationIncludedTrue;
- (void)testCreateRequestPropAltitudeActionBindLocationIncludedTrue;
- (void)testCreateRequestPropAccuracyActionBindLocationIncludedTrue;
- (void)testCreateRequestPropFixageActionBindLocationIncludedTrue;
- (void)testCreateRequestPropCRSActionBindLocationIncludedTrue;

- (void)testCreateRequestPropLatitudeActionBindLocationIncludedFalse;
- (void)testCreateRequestPropLongitudeActionBindLocationIncludedFalse;
- (void)testCreateRequestPropAltitudeActionBindLocationIncludedFalse;
- (void)testCreateRequestPropAccuracyActionBindLocationIncludedFalse;
- (void)testCreateRequestPropFixageActionBindLocationIncludedFalse;
- (void)testCreateRequestPropCRSActionBindLocationIncludedFalse;

- (void)testCreateRequestPropLatitudeActionCancel;
- (void)testCreateRequestPropLongitudeActionCancel;
- (void)testCreateRequestPropAltitudeActionCancel;
- (void)testCreateRequestPropAccuracyActionCancel;
- (void)testCreateRequestPropFixageActionCancel;
- (void)testCreateRequestPropCRSActionCancel;

@end
