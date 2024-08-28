//
//  AppDelegate.m
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 18/03/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "AppDelegate.h"

#import "ScanViewController.h"
#import "JobListViewController.h"
#import "SettingsViewController.h"
#import "NotificationSettingsViewController.h"
#import "SplashViewController.h"
#import "EndpointConfigViewController.h"
#import "ExtractBsim.h"
#import "FileFromWeb.h"
#import "Properties.h"
#import "Location.h"
#import "FileLogger.h"
#import "MailSender.h"
#import "MailReciever.h"
#import "Reachability.h"
#import "CkoMailMan.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize splashViewController, endpointConfigViewController;
@synthesize bsimFile;
@synthesize scanViewController, jobListViewController, settingsViewController, mailLock, locationController, mailSendTimer, gettingUpdates,bgtask, performingNetworkTask;

NSMutableArray *emailQueue;
int iconBadgeNumber = 1;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self restoreApplicationState]; // IMPORTANT: Saves application data
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    self.gettingUpdates = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    emailQueue = [[NSMutableArray alloc] init];
    mailLock = [[NSLock alloc]init];

    // Override point for customization after application launch.
    UINavigationController *scanNavigationController = [[UINavigationController alloc] init];
    UINavigationController *jobListNavigationController = [[UINavigationController alloc] init];
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] init];
    
    scanViewController = [[ScanViewController alloc] initWithNibName:@"ScanViewController" bundle:nil];
    jobListViewController = [[JobListViewController alloc] initWithNibName:@"JobListViewController" bundle:nil];
    settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    
    scanNavigationController.viewControllers = [NSArray arrayWithObjects:scanViewController, nil];
    jobListNavigationController.viewControllers = [NSArray arrayWithObjects:jobListViewController, nil];
    settingsNavigationController.viewControllers = [NSArray arrayWithObjects:settingsViewController, nil];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:scanNavigationController, jobListNavigationController, settingsNavigationController, nil];
    
    [scanNavigationController release];
    [jobListNavigationController release];
    [settingsNavigationController release];
    
    
    if (isGPSLocation) {
        locationController = [[Location alloc] init];
        [locationController.locationManager startUpdatingLocation];
    }
    
    bsimFile =  [BsimFileContents sharedBsimContents];
   
    BOOL extracted = [bsimFile extract];
    
    
    if(extracted == false){
        
        FLog(@"NO BSIM FILE FOUND or COULD NOT EXTRACTED"); 
        [self addEndpointConfigView];   // Here we will call a view to load in the bsim file from a web address
    }
    else {
        FLog(@"Bsim file Extracted");
        [self addSplashView];
        [self createPasswordAlert];
    }
    
    
    // Register the app for the Push- and Local-Notifications on iOS5 - else the users will not get the Local-Notifications
    //
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes: 
     UIRemoteNotificationTypeBadge | 
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    return YES;
}

- (BOOL)ENISCertificateExpired:(NSDate *)expiryDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    
    FLog(@"Current date: %@ Expiry date: %@", [dateFormatter dateFromString:[self getCurrentDate]], expiryDate);
    
    NSDate* earlierDate = [[dateFormatter dateFromString:[self getCurrentDate]] earlierDate:expiryDate];
    FLog(@"Earlier date: %@", earlierDate);
    
    [dateFormatter release];
    
    if ([earlierDate compare:expiryDate] == NSOrderedSame) {
        FLog(@"nis cert date is later in time than current date. ENIS cert is expired.");
        return YES;
    }
    FLog(@"nis cert date is earlier in time than current date.");
    return NO;
}

void uncaughtExceptionHandler(NSException *exception)
{
    // Log [exception description] or name, reason, callStackSymbols
    FLog(@"BAD ACCESS EXCEPTION %@", [exception description]);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    FLog(@"Resign Active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"WAITING COUNT: %i", [self statusWaitingCount]);
    
    if ( (self.performingNetworkTask) || (self.gettingUpdates) )
    {
        if ([self hasNetAccess])
        {
            [self requestFinishCurrentTask];
        }
        else
        {
            [self schedulePendingTasks];
        }
    }
    
     /* Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits. */
    
    
    [self saveApplicationState];
    
    [self resignKeyboard];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    FLog(@"WillEnterForeground");
    
    [self resignKeyboard];
    
    if ( [self.tabBarController selectedIndex] == 1 ) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0; // remove badge number from the icon
        iconBadgeNumber = 1;
    }
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    FLog(@"Notification Received, %@, set for date %@", notification.alertBody, [notification.fireDate description]);
    
    if (application.applicationState != UIApplicationStateActive) {
        
        //UIView *topView = self.window.rootViewController.view;
        //if( ![topView isKindOfClass:[SplashViewController class]] ) {
            [self.tabBarController setSelectedIndex:1];
        //}
        
        // Dismiss Editing to Job List before selecting the notif row
        if(self.jobListViewController.editing) {
            [self.jobListViewController setEditing:NO animated:YES];
            [self.jobListViewController.navigationItem.rightBarButtonItem setTitle:@"Edit"];
            [self.jobListViewController.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
            [self.jobListViewController toolbarFooter:0 height:0];
            [self.jobListViewController.navigationController setToolbarHidden:YES animated:NO];
            self.jobListViewController.cancelButton.enabled = NO;
            self.jobListViewController.deleteButton.enabled = NO;
            self.jobListViewController.deleteAllButton = nil;
            self.jobListViewController.navigationItem.leftBarButtonItem = nil;
        }
        // Remove swipe edit buttons
        [self.jobListViewController removeContentViewButtons];
        // Add back gesture recognizers
        [self.jobListViewController.tableView addGestureRecognizer:self.jobListViewController.swipeRecognizerRight];
        [self.jobListViewController.tableView addGestureRecognizer:self.jobListViewController.swipeRecognizerLeft];
        
        
        // Set selected cell on table view from incoming notification
        int jobCount = [jobListArray count];
        int index;
        for (index = 0; index < jobCount; index++) {
        
            NSString *job = [jobListArray objectAtIndex:index];
            NSArray *jobFields = [job componentsSeparatedByString:@"\n"];
        
            NSArray *notifAlertBody = [notification.alertBody componentsSeparatedByString:@"\n"];
        
            NSString *serialNumber = [[notifAlertBody objectAtIndex:0] stringByReplacingOccurrencesOfString:@"Job updated - " withString:@""];
            FLog(@"Node name from notification center: %@", serialNumber);
        
            if ([[jobFields objectAtIndex:1] isEqualToString:serialNumber]) {
                FLog(@"Selected index on table will be %i", index);
                break;
            }
        }
    
        self.jobListViewController.tableView.allowsSelection = YES;
        [self.jobListViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(jobCount-1-index) inSection:0]
                                                          animated:NO
                                                    scrollPosition:UITableViewScrollPositionNone];
        
        [self.jobListViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(jobCount-1-index) inSection:0] atScrollPosition:UITableViewScrollPositionNone  animated:NO];
    
    
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0; // remove badge number from the icon
        iconBadgeNumber = 1;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    FLog(@"DidBecomeActive");
    /*
     Restart any taskssss were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // Just in case there is still a BG task running
    [self cleanUpBackgroundTask];
    
    // Just in case there is a BG task scheduled for another 10 min interval
    [self cancelPendingTasks];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    FLog(@"AppWillTerminate");
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [self saveApplicationState];
}

- (bool) hasNetAccess
{
    Properties *props = [BsimFileContents sharedBsimContents].properties;
	Reachability *r = [Reachability reachabilityWithHostName:props.outgoingMailServer ];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL internet;
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
		internet = NO;
	} else {
		internet = YES;
	}
	return internet;
} 


- (void) requestFinishCurrentTask
{
    
    bgtask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        FLog(@"Expiration Handler");
        // Do any last-minute last-chance cleanup before the system terminates the app
        
        if ( (self.performingNetworkTask) || (self.gettingUpdates) )
            [self schedulePendingTasks];
        else [self cancelPendingTasks];
        
        [self cleanUpBackgroundTask];
    }];
    
    dispatchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    
    if (dispatchTimer)
    {
        dispatch_source_set_timer(dispatchTimer, dispatch_walltime(NULL, 0), 2ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
        dispatch_source_set_event_handler(dispatchTimer, ^{[self finishTaskInBackground];});
        dispatch_resume(dispatchTimer);
    }
    else FLog(@"Count not create timer for background execution");
    
}

- (void) cleanUpBackgroundTask
{
    FLog(@"cleanupBackgroundTask");

    // This gives the time for other functions to return before suspending the background thread
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ [self doCleanUpBackgroundTask]; });
}

- (void) doCleanUpBackgroundTask
{
    FLog(@"cleanupBackgroundTask");
    
    if ( (dispatchTimer) && (dispatch_source_testcancel(dispatchTimer) == 0l) )
    {
        dispatch_source_cancel(dispatchTimer);
        dispatch_release(dispatchTimer);
        dispatchTimer = nil;        
    }
    
    if (bgtask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgtask];
        bgtask = UIBackgroundTaskInvalid;        
    }
}

- (void) schedulePendingTasks
{
    FLog(@"schedulePendingTasks");
    [[UIApplication sharedApplication] setKeepAliveTimeout:660 handler:^{ [self doPendingTasksInBackground]; }];
}

- (void) cancelPendingTasks
{
     FLog(@"cancelPendingTasks");
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
}


- (void) finishTaskInBackground
{
    FLog(@"finishTaskInBackground");
    
    if ( (self.performingNetworkTask) || (self.gettingUpdates) )
    {
        FLog(@"There is work to do");
        if ( (![self hasNetAccess]) || (![self enoughTime]) )
        {
            // No Net Access or Not enough time
            FLog(@"Try again in 10 minutes");
            [self schedulePendingTasks];
            [self cleanUpBackgroundTask];
        }
    }
    else
    {
        FLog(@"No work to do");
        [self cancelPendingTasks];
        [self cleanUpBackgroundTask];
    }
    
    return;
}


- (void) doPendingTasksInBackground
{
    FLog(@"Starting 10s BG Execution");
    
    if (![self hasNetAccess])
        return;
    
    if ( (self.performingNetworkTask) || (self.gettingUpdates) ) 
    {
        FLog(@"Requesting more time");
        [self cancelPendingTasks];
        [self requestFinishCurrentTask];
    }
    else [self cancelPendingTasks];
}


- (BOOL) enoughTime
{
    NSTimeInterval timeLeft = [[UIApplication sharedApplication] backgroundTimeRemaining];
    FLog(@"Remaining Time = %g", timeLeft);
    
    if (timeLeft > 10.0)
        return YES;
    
    // Less than 1 second left before app gets terminated/suspended by system
    return NO;
}


- (void)saveApplicationState {
    FLog(@"Saving application state");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (jobListArray != nil) {
		[defaults setObject:jobListArray forKey:@"savedJobListArray"];
		[defaults setObject:statusAndTimeArray forKey:@"savedStatusAndTimeArray"];
        [defaults setObject:statusImageArray forKey:@"savedStatusImageArray"];
	}
    
    [defaults setBool:isShutter forKey:@"SwitchShutter"];
    [defaults setBool:isVibrate forKey:@"SwitchVibrate"];
    [defaults setObject:notifValue forKey:@"SwitchNotifications"];
    [defaults setBool:isFlashLight forKey:@"SwitchFlashLight"];
    [defaults setBool:isGPSLocation forKey:@"SwitchGPSLocationService"];
    
    // save it
    [defaults synchronize];
}


-(void)checkTimerAndUpdate{
    
    int count = [emailQueue count];
    if (count == 0) {
        [self.mailSendTimer invalidate];
        self.mailSendTimer = nil;
    }    
    [NSThread detachNewThreadSelector:@selector(performUpdate) toTarget:self withObject:nil];
        
}

-(void)performUpdate{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    bool networkConnection = [MailSender connectedToNetwork];
    if (!networkConnection || ![self smtpConnectionToMailServer]) {
        FLog(@"Trying to send but no network connection and/or smtp connection failed to the mail server");
        return;
    }
    int count = [emailQueue count];

    while ( count != 0 && (networkConnection) ) {
        FLog(@"Getting current request %i", count);
        RequestProperty *currentRequest = [emailQueue objectAtIndex:0];
        MailSender *sender = [[[MailSender alloc]init] autorelease];
        [emailQueue removeObject:currentRequest];
        [sender sendRequest:currentRequest];
        FLog(@"current request: %@", currentRequest.NODENAME);
        count = [emailQueue count];
    }
    
    [pool release];
}

- (BOOL)smtpConnectionToMailServer {
    CkoMailMan *mailman = [[[CkoMailMan alloc] init] autorelease];
    Properties *props = [BsimFileContents sharedBsimContents].properties;
    BOOL success;
    success = [mailman UnlockComponent: @"ERCSSNMAILQ_9vOBrSPO4R6g"];
    
    if (success != YES) {
        FLog(@"Problem sending email - Chilkat CkoMailMan licencing problem occurs");
        return NO;
    }
    
    if (props.outgoingForceSecurity) {
        mailman.SmtpSsl = YES;
    }
    mailman.AutoFix = false;
    mailman.SmtpHost = props.outgoingMailServer;
    mailman.SmtpUsername = props.iPhoneEmailUsername;
    mailman.SmtpPassword = props.iPhoneEmailPassword;
    mailman.SmtpPort = props.outgoingMailServerPort;
    
    bool mailServerConnection = [mailman OpenSmtpConnection];
    FLog(@"Smtp Mail Server connection: %@", mailServerConnection == 1 ? @"YES": @"NO");
    
    return mailServerConnection == 1 ? YES : NO;
}

- (void)restoreApplicationState {
    FLog(@"Restoring application state");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:@"savedJobListArray"] count] > 0) {
		jobListArray = [[defaults objectForKey:@"savedJobListArray"] mutableCopy];
		statusAndTimeArray = [[defaults objectForKey:@"savedStatusAndTimeArray"] mutableCopy];
        statusImageArray = [[defaults objectForKey:@"savedStatusImageArray"] mutableCopy];
	}
    
    if ([defaults objectForKey:@"SwitchShutter"] != nil) {
        isShutter = [defaults boolForKey:@"SwitchShutter"];
    }
    if ([defaults objectForKey:@"SwitchVibrate"] != nil) {
        isVibrate = [defaults boolForKey:@"SwitchVibrate"];
    }
    if ([defaults objectForKey:@"SwitchNotifications"] != nil) {
        notifValue = [defaults stringForKey:@"SwitchNotifications"];
    }
    if ([defaults objectForKey:@"SwitchFlashLight"] != nil) {
        isFlashLight = [defaults boolForKey:@"SwitchFlashLight"];
    }
    if ([defaults objectForKey:@"SwitchGPSLocationService"] != nil) {
        isGPSLocation = [defaults boolForKey:@"SwitchGPSLocationService"];
    }
}

- (void)resignKeyboard {
    // Resign any open keyboard on Scan View before the app enters background or terminates
    if (scanViewController.workOrderTextField.isFirstResponder) {
        [scanViewController.workOrderTextField resignFirstResponder];
    }
    else if (scanViewController.serialNoTextField.isFirstResponder) {
        [scanViewController.serialNoTextField resignFirstResponder];
    }
}

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
 {
 }
 */

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
 {
 }
 */

- (void)addEndpointConfigView {
    FLog(@"Loading endpoint config view");
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    if (self.endpointConfigViewController == nil) { 
        EndpointConfigViewController *endpointConfigController = 
        [[EndpointConfigViewController alloc] initWithNibName:@"EndpointConfigViewController" 
                                                       bundle:nil]; 
        self.endpointConfigViewController = endpointConfigController; 
        [endpointConfigController release]; 
	}
    
    UINavigationController *configurationNavigationController = [[UINavigationController alloc] init];
    configurationNavigationController.viewControllers = [NSArray arrayWithObjects:endpointConfigViewController, nil];
    
    self.window.rootViewController = configurationNavigationController;
    [self.window makeKeyAndVisible];
    
    [configurationNavigationController release];
}

- (void)addSplashView {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    
    if (self.splashViewController == nil) { 
        SplashViewController *splashController = 
        [[SplashViewController alloc] initWithNibName:@"SplashViewController" 
                                               bundle:nil]; 
        self.splashViewController = splashController; 
        [splashController release]; 
	}
    
    self.window.rootViewController = self.splashViewController;
    [self.window makeKeyAndVisible];
}

- (void)createPasswordAlert {
    FLog(@"Propmting user for password");
    UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Login" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Configure", @"Submit", nil];
    loginAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [[loginAlert textFieldAtIndex:0] setPlaceholder:@"password"];
    [[loginAlert textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
    loginAlert.tag = 1;
    [loginAlert show];
    [loginAlert release];
}

- (void)createPasswordIncorrectAlert {
    FLog(@"Password Wrong");
    UIAlertView *loginNotAlert = [[UIAlertView alloc] initWithTitle:@"Authentication Error" message:@"Your password was entered incorrectly." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Configure", @"Retry", nil];
    loginNotAlert.tag = 2;
    [loginNotAlert show];
    [loginNotAlert release];
}

- (void)createCertsNotValidAlert:(NSString *)strDate {
    FLog(@"Certs Invalid");
    NSString *completeMessage = [NSString stringWithFormat:@"Certificate expired on %@.\nPlease install a new configuration file", strDate];
    UIAlertView *certsNotValid = [[UIAlertView alloc] initWithTitle:@"NIS Error" message:completeMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"Configure", nil];
    certsNotValid.tag = 3;
    [certsNotValid show];
    [certsNotValid release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    FLog(@"Logging in");
    
    if (alertView.tag == 1) {        
        
        NSString *res2 = [[alertView textFieldAtIndex:0]text];
        NSString *res = [bsimFile verifyAndInitialize:res2];
        
        if ( buttonIndex == 1 && [res isEqualToString:@"success"] ) {
            FLog(@"Login successful!");
            
            if ( ![self ENISCertificateExpired:bsimFile.nisCert.ValidTo] ) {
                [self.splashViewController.view removeFromSuperview];
                self.splashViewController = nil;
                
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
                
                self.window.rootViewController = self.tabBarController;
                [self.window makeKeyAndVisible];
                
                // Incase the user logged out from settings
                if (self.tabBarController.selectedIndex != 0) {
                    FLog(@"Tabbar selected index is not 0");
                    self.tabBarController.selectedIndex = 0;
                    
                    // Scroll back to top of Settings view
                    [settingsViewController.groupedTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                }
            }
            else {
                FLog(@"ENIS cert is expired prompt.");
                [self createCertsNotValidAlert:[self formatExpiryDate:bsimFile.nisCert.ValidTo]];
            }
        }
        else if (buttonIndex == 0) {
            FLog(@"Alert tag 1, button Configure");
            
            [self.splashViewController.view removeFromSuperview];
            self.splashViewController = nil;
            
            [self addEndpointConfigView];
            [self.endpointConfigViewController putCancelNavButton];
        }
        else {
            [alertView dismissWithClickedButtonIndex:-1 animated:YES];
            [self createPasswordIncorrectAlert];
        }
    }
    else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            [alertView dismissWithClickedButtonIndex:-1 animated:YES];
            [self createPasswordAlert];
        }
        else if (buttonIndex == 0) {
            FLog(@"Alert tag 2, button Configure");
            
            [self.splashViewController.view removeFromSuperview];
            self.splashViewController = nil;
            
            [self addEndpointConfigView];
            [self.endpointConfigViewController putCancelNavButton];
        }
    }
    else if (alertView.tag == 3) {
        FLog(@"Alert tag 3, button Configure");
        FLog(@"ENIS cert is expired.");
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [alertView dismissWithClickedButtonIndex:-1 animated:YES];
        NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        NSString  *bsimPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"iPhone.bsim"];
        NSString  *bsimCertPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"bsim.cert"];
        NSString  *nisCertPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"nis.p12"];
        NSString  *propsPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"bsim.properties"];
        [fileManager removeItemAtPath:bsimPath error:NULL];
        [fileManager removeItemAtPath:bsimCertPath error:NULL];
        [fileManager removeItemAtPath:nisCertPath error:NULL];
        [fileManager removeItemAtPath:propsPath error:NULL];
        
        [self.splashViewController.view removeFromSuperview];
        self.splashViewController = nil;
        
        [self addEndpointConfigView];
        [self.endpointConfigViewController removeCancelNavButton];
    }
}

- (NSString *)formatExpiryDate:(NSDate *)expiryDate {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:expiryDate];
}

-(NSMutableArray *)getGPSData{
    FLog(@"Getting coordinates");
    locationController.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer; //1k
    [locationController.locationManager startUpdatingLocation];
    CLLocation *location = [locationController.locationManager location];
    
    // Configure the new event with information from the location
    CLLocationCoordinate2D locCoordinate = [location coordinate];
    CLLocationDistance locAltitude = [location altitude];
    CLLocationAccuracy locAccuracy = [location horizontalAccuracy];
    
    NSString *latitude = [NSString stringWithFormat:@"%f", locCoordinate.latitude]; 
    NSString *longitude = [NSString stringWithFormat:@"%f", locCoordinate.longitude];
    NSString *altitude = [NSString stringWithFormat:@"%.0f", locAltitude];
    NSString *accuracy = [NSString stringWithFormat:@"%.0f", locAccuracy];
    //NSDate *timestamp = location.timestamp;
    
    NSMutableArray *result = [[[NSMutableArray alloc]init] autorelease];
    [result addObject:latitude];
    [result addObject:longitude];
    [result addObject:altitude];
    [result addObject:accuracy];
    [result addObject:@"N/A"];  // timestamp, todo to fill FIXAGE
    
    return result;
}

- (NSString *)getCurrentDate {
	NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter;
	dateFormatter = nil;
	dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
	
	return [dateFormatter stringFromDate:now];
}

- (int)statusWaitingCount {
    
    int waitingCnt = 0;
    for (id status in statusAndTimeArray) {
        if ([status rangeOfString:@"Waiting"].location != NSNotFound) {
            waitingCnt++;
        }
    }
    
    return waitingCnt;
}

- (void)dealloc {
    [scanViewController release];
    [jobListViewController release];
    [settingsViewController release];
    [splashViewController release];
    [endpointConfigViewController release];
    [locationController release];
    [mailLock release];
    [bsimFile release];
    [super dealloc];
}

@end
