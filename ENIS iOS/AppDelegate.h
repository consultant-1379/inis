//
//  AppDelegate.h
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 18/03/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CertInitialiser.h"
#import "Properties.h"
#import "BsimFileContents.h"
#import "Location.h"
@class SplashViewController;
@class EndpointConfigViewController;
@class ScanViewController;
@class JobListViewController;
@class SettingsViewController;
extern NSMutableArray *emailQueue;
extern NSLock *mailLock;
extern int iconBadgeNumber;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIActionSheetDelegate> {
    
    ScanViewController *scanViewController;
    JobListViewController *jobListViewController;
    SettingsViewController *settingsViewController;    
    UIImageView *splashView;
    SplashViewController *splashViewController;
    EndpointConfigViewController *endpointConfigViewController;
    Location *locationController;
    NSTimer *mailSendTimer;
    bool gettingUpdates;
    bool performingNetworkTask;
    UIBackgroundTaskIdentifier bgtask;
    dispatch_source_t dispatchTimer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, retain) ScanViewController *scanViewController;
@property (nonatomic, retain) JobListViewController *jobListViewController;
@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (nonatomic, retain) SplashViewController *splashViewController;
@property (nonatomic, retain) EndpointConfigViewController *endpointConfigViewController;
@property (nonatomic, retain) BsimFileContents *bsimFile;
@property (nonatomic, retain) NSLock *mailLock;
@property (nonatomic, retain) Location *locationController;
@property (nonatomic, retain) NSTimer *mailSendTimer;
@property bool gettingUpdates;
@property bool performingNetworkTask;
@property UIBackgroundTaskIdentifier bgtask;

- (void)addSplashView;
- (void)saveApplicationState;
- (void)restoreApplicationState;
- (void)createPasswordAlert;
- (void)addEndpointConfigView;
- (void)resignKeyboard;
- (void)checkTimerAndUpdate;
- (void)performUpdate;
- (bool)hasNetAccess;
- (NSString *)getCurrentDate;
- (NSMutableArray *)getGPSData;
- (int)statusWaitingCount;
void uncaughtExceptionHandler(NSException *exception);
- (void) cleanUpBackgroundTask;
- (BOOL)ENISCertificateExpired:(NSDate *)expiryDate;
- (void)createCertsNotValidAlert:(NSString *)strDate;
- (NSString *)formatExpiryDate:(NSDate *)expiryDate;
- (BOOL)smtpConnectionToMailServer;

@end
