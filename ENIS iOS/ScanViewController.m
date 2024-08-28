//
//  ScanViewController.m
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 18/03/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

NSString * const BATCH_ID = @"BatchID";
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 1.13;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

NSString *EPSG = @"4326";
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#import "ScanViewController.h"
#import "SettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "RequestProperty.h"
#import "MailSender.h"
#import "AppDelegate.h"
#import "FileLogger.h"
#import "SSKeychain.h"

@implementation ScanViewController

@synthesize workOrderTextField;
@synthesize serialNoTextField;
@synthesize sendBarButton;
@synthesize clearBarButton;
@synthesize sendButton;
@synthesize clearButton;
@synthesize activityIndicator;
@synthesize aDelegate;
@synthesize reader;
@synthesize tapRecognizer;
@synthesize gpsLAT, gpsLONG, gpsALT, gpsACC, gpsFIX;
@synthesize paneWorkOrderImageView, paneSerialNoImageView;
@synthesize workOrderLabel, serialNoLabel;
@synthesize workOrderButton, serialNoButton;
@synthesize validSerialNoActionTitle;

NSMutableArray *jobListArray;
NSMutableArray *statusAndTimeArray;
NSMutableArray *statusImageArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Scan", @"This is for Scanning");
        self.tabBarItem.image = [UIImage imageNamed:@"scan_tab_icon.png"];
        
        scanWorkOrderFlag = NO;
        scanSerialNoFlag = NO;
        
        reader = [[ZBarReaderViewController alloc] init];
        reader.readerDelegate = self;
        reader.showsZBarControls = NO;
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    if (IS_IPHONE_5) {
        NSLog(@"Scan View: Device has iPhone 5 resolution.");
        [self adjustSubViewsForiPhone5Resolution];
    }
    else {
        NSLog(@"Scan View: Device has NOT iPhone 5 resolution.");
    }
    
    aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"status_bar.png"];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    reader.cameraOverlayView = [self addToolbar];
    
    [self setTitle:@"Scan"];
    [self putSendNavButton];
    [self putClearNavButton];
    
    // Add notification listeners for UITextFields
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableDisableSaveButton)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:workOrderTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableDisableSaveButton)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:serialNoTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableDisableClearButton)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:workOrderTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableDisableClearButton)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:serialNoTextField];
    
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                                       pathForResource: @"beep-7" ofType:@"wav"]], &soundID);
    
    /* Dismiss keyboard when touching outside of textfield - 
     Add an UITapGestureRecogniser and assign it to the view */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view.superview addGestureRecognizer:tap];
    [tap release];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
     UIKeyboardWillShowNotification object:nil];
    
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
     UIKeyboardWillHideNotification object:nil];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(dismissKeyboard:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)sendNavButtonPressed:(id)sender {
    FLog(@"Send new job button pressed");
    
   if ( ![self isSerialNoValid:serialNoTextField.text] ) {
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Invalid Serial Number.\n\nPlease, enter a valid Serial Number."] delegate:self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil];
        popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
        
        [popupQuery showInView:self.parentViewController.tabBarController.view];
        [popupQuery release];
   }
   else if ([self checkForDuplicateJob]) {
        NSString *jobString = workOrderTextField.text;
        jobString = [jobString stringByAppendingString:@"\n"];
        jobString = [jobString stringByAppendingString:serialNoTextField.text];
        
        NSString *statusAndTimeString = [statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]];
        NSArray *status = [statusAndTimeString componentsSeparatedByString:@"\n"];
        
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@Job already exists, status is %@.\nIf you continue, existing job will be deleted." , self.validSerialNoActionTitle, [status objectAtIndex:0]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send this job", nil];
        popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
        
        [popupQuery showInView:self.parentViewController.tabBarController.view];
        popupQuery.tag = 1;
        [popupQuery release];
    }
    else if ([self checkForDuplicateJobWorkOrder] && [self checkForDuplicateJobSerialNo]) {
        
        NSArray *jobArrayWorkOrder;
        for (NSString* job in jobListArray)
        {   
            if ([job rangeOfString:workOrderTextField.text].location != NSNotFound) {
                
                NSString *jobListString = [jobListArray objectAtIndex:[jobListArray indexOfObject:job]];
                jobArrayWorkOrder = [jobListString componentsSeparatedByString:@"\n"];
                
                if ( [workOrderTextField.text isEqualToString:[jobArrayWorkOrder objectAtIndex:0]]) {
                    break;
                }
            }
        }
        
        NSString *jobStringWorkOrder = [jobArrayWorkOrder objectAtIndex:0];
        jobStringWorkOrder = [jobStringWorkOrder stringByAppendingString:@"\n"];
        jobStringWorkOrder = [jobStringWorkOrder stringByAppendingString:[jobArrayWorkOrder objectAtIndex:1]];
        
        NSString *statusAndTimeStringWorkOrder = [statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobStringWorkOrder]];
        NSArray *statusAndTimeArrayWorkOrder = [statusAndTimeStringWorkOrder componentsSeparatedByString:@"\n"];
        
        
        
        /////////////////
        NSArray *jobArraySerialNo;
        for (NSString* job in jobListArray)
        {   
            if ([job rangeOfString:serialNoTextField.text].location != NSNotFound) {
                
                NSString *jobListString = [jobListArray objectAtIndex:[jobListArray indexOfObject:job]];
                jobArraySerialNo = [jobListString componentsSeparatedByString:@"\n"];
                
                if ( [serialNoTextField.text isEqualToString:[jobArraySerialNo objectAtIndex:1]]) {
                    break;
                }
            }
        }
        
        NSString *jobStringSerialNo = [jobArraySerialNo objectAtIndex:0];
        jobStringSerialNo = [jobStringSerialNo stringByAppendingString:@"\n"];
        jobStringSerialNo = [jobStringSerialNo stringByAppendingString:[jobArraySerialNo objectAtIndex:1]];
        
        NSString *statusAndTimeStringSerialNo = [statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobStringSerialNo]];
        NSArray *statusAndTimeArraySerialNo = [statusAndTimeStringSerialNo componentsSeparatedByString:@"\n"];
        
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@Node name \"%@\" is already used for serial number \"%@\", job is in status %@.\nIf you continue, existing job will be deleted.\n\n"
                                                                          "Serial number \"%@\" is already used for node \"%@\", job is in status %@.\nIf you continue, existing job will be deleted.",
                                                                          self.validSerialNoActionTitle,
                                                                          [jobArrayWorkOrder objectAtIndex:0], 
                                                                          [jobArrayWorkOrder objectAtIndex:1], 
                                                                          [statusAndTimeArrayWorkOrder objectAtIndex:0],
                                                                          [jobArraySerialNo objectAtIndex:1], 
                                                                          [jobArraySerialNo objectAtIndex:0], 
                                                                          [statusAndTimeArraySerialNo objectAtIndex:0]] 
                                                                delegate:self 
                                                       cancelButtonTitle:@"Cancel" 
                                                  destructiveButtonTitle:nil 
                                                       otherButtonTitles:@"Send this job", nil];
        
        popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
        
        [popupQuery showInView:self.parentViewController.tabBarController.view];
        popupQuery.tag = 2;
        [popupQuery release];
    }
    else if ([self checkForDuplicateJobWorkOrder]) {
        FLog(@"There is a duplicate");
        NSArray *jobArray;
        for (NSString* job in jobListArray)
        {   
            if ([job rangeOfString:workOrderTextField.text].location != NSNotFound) {
                
                NSString *jobListString = [jobListArray objectAtIndex:[jobListArray indexOfObject:job]];
                jobArray = [jobListString componentsSeparatedByString:@"\n"];
                
                if ( [workOrderTextField.text isEqualToString:[jobArray objectAtIndex:0]]) {
                    break;
                }
            }
        }
        
        NSString *jobString = [jobArray objectAtIndex:0];
        jobString = [jobString stringByAppendingString:@"\n"];
        jobString = [jobString stringByAppendingString:[jobArray objectAtIndex:1]];
        
        NSString *statusAndTimeString = [statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]];
        NSArray *statusAndTimeArray = [statusAndTimeString componentsSeparatedByString:@"\n"];
        
        
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@Node name \"%@\" is already used for serial number \"%@\", job is in status %@.\nIf you continue, existing job will be deleted." ,
                                                                          self.validSerialNoActionTitle,
                                                                          [jobArray objectAtIndex:0], 
                                                                          [jobArray objectAtIndex:1], 
                                                                          [statusAndTimeArray objectAtIndex:0]] 
                                                                delegate:self 
                                                       cancelButtonTitle:@"Cancel" 
                                                  destructiveButtonTitle:nil 
                                                       otherButtonTitles:@"Send this job", nil];
        
        popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
        
        [popupQuery showInView:self.parentViewController.tabBarController.view];
        popupQuery.tag = 3;
        [popupQuery release];
    }
    else if ([self checkForDuplicateJobSerialNo]) {
        
        NSArray *jobArray;
        for (NSString* job in jobListArray)
        {   
            if ([job rangeOfString:serialNoTextField.text].location != NSNotFound) {
                
                NSString *jobListString = [jobListArray objectAtIndex:[jobListArray indexOfObject:job]];
                jobArray = [jobListString componentsSeparatedByString:@"\n"];
                
                if ( [serialNoTextField.text isEqualToString:[jobArray objectAtIndex:1]]) {
                    break;
                }
            }
        }
        
        NSString *jobString = [jobArray objectAtIndex:0];
        jobString = [jobString stringByAppendingString:@"\n"];
        jobString = [jobString stringByAppendingString:[jobArray objectAtIndex:1]];
        
        NSString *statusAndTimeString = [statusAndTimeArray objectAtIndex:[jobListArray indexOfObject:jobString]];
        NSArray *statusAndTimeArray = [statusAndTimeString componentsSeparatedByString:@"\n"];
        
        
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@Serial number \"%@\" is already used for node \"%@\", job is in status %@.\nIf you continue, existing job will be deleted." ,
                                                                          self.validSerialNoActionTitle,
                                                                          [jobArray objectAtIndex:1], 
                                                                          [jobArray objectAtIndex:0], 
                                                                          [statusAndTimeArray objectAtIndex:0]] 
                                                                delegate:self 
                                                       cancelButtonTitle:@"Cancel" 
                                                  destructiveButtonTitle:nil 
                                                       otherButtonTitles:@"Send this job", nil];
        
        popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
        
        [popupQuery showInView:self.parentViewController.tabBarController.view];
        popupQuery.tag = 4;
        [popupQuery release];
    }
    else 
    {
        // Send without prompt warning text
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:self.validSerialNoActionTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send this job", nil];
        popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
        
        [popupQuery showInView:self.parentViewController.tabBarController.view];
        popupQuery.tag = 5;
        [popupQuery release];
    }
}
 
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0 && actionSheet.tag == 5) {
        [self sendJob];
    }
    else if (buttonIndex == 0 && actionSheet.tag == 1) {
        [self removeDuplicateTag1];
    }
    else if (buttonIndex == 0 && actionSheet.tag == 2) {
        [self removeDuplicateTag2];
    }
    else if (buttonIndex == 0 && actionSheet.tag == 3) {
        [self removeDuplicateTag3];
    }
    else if (buttonIndex == 0 && actionSheet.tag == 4) {
        [self removeDuplicateTag4];
    }
    else if (buttonIndex == 1) {
        FLog(@"Cancel button pressed");
    }
}

- (void)sendJob {
    
    if ([workOrderTextField isFirstResponder]) {
        [workOrderTextField resignFirstResponder];
    }
    
    if ([serialNoTextField isFirstResponder]) {
        [serialNoTextField resignFirstResponder];
    }
    
    aDelegate.performingNetworkTask = YES;
    FLog(@"Constructing request property object for sending object");
    NSString *retrieveuuid = [SSKeychain passwordForService:@"com.ericsson.nis" account:@"user"];
    RequestProperty *requestProp = [[RequestProperty alloc] init];
    requestProp.UUID = retrieveuuid;
    requestProp.NODENAME = workOrderTextField.text;
    requestProp.SERIAL = serialNoTextField.text;
    NSString *jobString = workOrderTextField.text;
    jobString = [jobString stringByAppendingString:@"\n"];
    jobString = [jobString stringByAppendingString:serialNoTextField.text];
    [self addJob:jobString];
    
    NSString *statusAndTimeString = @"Sending bind request";
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:[self getCurrentDate]];
    requestProp.STATTIME = statusAndTimeString;
    requestProp.ACTION = @"bind";
    
    
    if( [CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) && isGPSLocation ){
        
        if (self.gpsLAT == nil) {
            [self recordGPSData];
        }
        
        requestProp.LOCATIONINCLUDED = @"true";
        requestProp.LATITUDE = self.gpsLAT;
        requestProp.LONGITUDE = self.gpsLONG;
        requestProp.ALTITUDE = self.gpsALT;
        requestProp.ACCURACY = self.gpsACC;
        requestProp.CRS = EPSG;
        
        FLog(@"GPS location on. LATITUDE: %@ LONGITUDE: %@ ALTITUDE: %@ HORIZONTAL ACCURACY: %@ CRS: %@", [requestProp LATITUDE] , [requestProp LONGITUDE], [requestProp ALTITUDE], [requestProp ACCURACY], [requestProp CRS]);
    }
    else {
        FLog(@"Location Services disabled - either from the app settings or device settings.");
        requestProp.LOCATIONINCLUDED = @"false";
    }
    
    [self addJobStatusAndTime:statusAndTimeString];
    
    [self addStatusImage:@"status2"];
    requestProp.LOGS = false;
    workOrderTextField.text = @"";
    serialNoTextField.text = @"";
    
    [self enableDisableSaveButton];
    [self enableDisableClearButton];
    [emailQueue addObject:requestProp];
    if (aDelegate.mailSendTimer == nil) {
        aDelegate.mailSendTimer = [[NSTimer alloc]init];
        aDelegate.mailSendTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:aDelegate selector:@selector(checkTimerAndUpdate) userInfo:nil repeats: YES];
    }
    
    //[requestProp release];
}

- (void)recordGPSData {

    if( [CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) && isGPSLocation ) {
       
        NSMutableArray *gpsInfo = [aDelegate getGPSData];
        if ([gpsInfo count] > 1) {
            self.gpsLAT = [gpsInfo objectAtIndex:0];
            self.gpsLONG = [gpsInfo objectAtIndex:1];
            self.gpsALT = [gpsInfo objectAtIndex:2];
            self.gpsACC = [gpsInfo objectAtIndex:3];
            self.gpsFIX = [gpsInfo objectAtIndex:4];
            
            FLog(@"GPS location on. LATITUDE: %@ LONGITUDE: %@ ALTITUDE: %@ HORIZONTAL ACCURACY: %@ TIMESTAMP/FIXAGE: %@", gpsLAT , gpsLONG, gpsALT, gpsACC, gpsFIX);
        }
        else {
            FLog(@"todo error here, gpsInfo array not long enough or empty");
        }
    }
}

- (void)removeDuplicateTag1 {
    
    // Remove duplicate jobs from the list
    NSString *dupJobString = workOrderTextField.text;
    dupJobString = [dupJobString stringByAppendingString:@"\n"];
    dupJobString = [dupJobString stringByAppendingString:serialNoTextField.text];
    
    [statusAndTimeArray removeObjectAtIndex:[jobListArray indexOfObject:dupJobString]];
    [statusImageArray removeObjectAtIndex:[jobListArray indexOfObject:dupJobString]];
    [jobListArray removeObject:dupJobString];
    
    // Remove also the duplicate from email queue
    for (RequestProperty *element in emailQueue) {
        // do something with object
        if ( [element.NODENAME isEqualToString:workOrderTextField.text] && [element.SERIAL isEqualToString:serialNoTextField.text] )
        {
            [emailQueue removeObject:element];
            break;
        }
    }
    
    [self sendJob];
}

- (void)removeDuplicateTag2 {
    
    // Remove duplicate Work Order
    NSArray *jobArrayWorkOrder;
    for (NSString* job in jobListArray)
    {   
        if ([job rangeOfString:workOrderTextField.text].location != NSNotFound) {
            
            NSString *jobListString = [jobListArray objectAtIndex:[jobListArray indexOfObject:job]];
            jobArrayWorkOrder = [jobListString componentsSeparatedByString:@"\n"];
            
            if ( [workOrderTextField.text isEqualToString:[jobArrayWorkOrder objectAtIndex:0]]) {
                break;
            }
        }
    }
    
    NSString *jobStringWorkOrder = [jobArrayWorkOrder objectAtIndex:0];
    jobStringWorkOrder = [jobStringWorkOrder stringByAppendingString:@"\n"];
    jobStringWorkOrder = [jobStringWorkOrder stringByAppendingString:[jobArrayWorkOrder objectAtIndex:1]];
    
    [statusAndTimeArray removeObjectAtIndex:[jobListArray indexOfObject:jobStringWorkOrder]];
    [statusImageArray removeObjectAtIndex:[jobListArray indexOfObject:jobStringWorkOrder]];
    [jobListArray removeObject:jobStringWorkOrder];
    
    
    
    // Remove duplicate Serial No
    NSArray *jobArraySerialNo;
    for (NSString* job in jobListArray)
    {   
        if ([job rangeOfString:serialNoTextField.text].location != NSNotFound) {
            
            NSString *jobListString = [jobListArray objectAtIndex:[jobListArray indexOfObject:job]];
            jobArraySerialNo = [jobListString componentsSeparatedByString:@"\n"];
            
            if ( [serialNoTextField.text isEqualToString:[jobArraySerialNo objectAtIndex:1]]) {
                break;
            }
        }
    }
    
    NSString *jobStringSerialNo = [jobArraySerialNo objectAtIndex:0];
    jobStringSerialNo = [jobStringSerialNo stringByAppendingString:@"\n"];
    jobStringSerialNo = [jobStringSerialNo stringByAppendingString:[jobArraySerialNo objectAtIndex:1]];
    
    [statusAndTimeArray removeObjectAtIndex:[jobListArray indexOfObject:jobStringSerialNo]];
    [statusImageArray removeObjectAtIndex:[jobListArray indexOfObject:jobStringSerialNo]];
    [jobListArray removeObject:jobStringSerialNo];
    
    
    [self sendJob];
}

- (void)removeDuplicateTag3 {
    
    // Remove duplicate Work Order only
    NSArray *jobArray;
    for (NSString* job in jobListArray)
    {   
        if ([job rangeOfString:workOrderTextField.text].location != NSNotFound) {
            
            NSString *jobListString = [jobListArray objectAtIndex:[jobListArray indexOfObject:job]];
            jobArray = [jobListString componentsSeparatedByString:@"\n"];
            
            if ( [workOrderTextField.text isEqualToString:[jobArray objectAtIndex:0]]) {
                break;
            }
        }
    }
    
    NSString *jobString = [jobArray objectAtIndex:0];
    jobString = [jobString stringByAppendingString:@"\n"];
    jobString = [jobString stringByAppendingString:[jobArray objectAtIndex:1]];
    
    [statusAndTimeArray removeObjectAtIndex:[jobListArray indexOfObject:jobString]];
    [statusImageArray removeObjectAtIndex:[jobListArray indexOfObject:jobString]];
    [jobListArray removeObject:jobString];
    
    
    [self sendJob];
}

- (void)removeDuplicateTag4 {
    
    // Remove duplicate Serial No only
    NSArray *jobArray;
    for (NSString* job in jobListArray)
    {   
        if ([job rangeOfString:serialNoTextField.text].location != NSNotFound) {
            
            NSString *jobListString = [jobListArray objectAtIndex:[jobListArray indexOfObject:job]];
            jobArray = [jobListString componentsSeparatedByString:@"\n"];
            
            if ( [serialNoTextField.text isEqualToString:[jobArray objectAtIndex:1]]) {
                break;
            }
        }
    }
    
    NSString *jobString = [jobArray objectAtIndex:0];
    jobString = [jobString stringByAppendingString:@"\n"];
    jobString = [jobString stringByAppendingString:[jobArray objectAtIndex:1]];
    
    [statusAndTimeArray removeObjectAtIndex:[jobListArray indexOfObject:jobString]];
    [statusImageArray removeObjectAtIndex:[jobListArray indexOfObject:jobString]];
    [jobListArray removeObject:jobString];
    
    
    [self sendJob];
}

- (IBAction)clearNavButtonPressed:(id)sender {
    workOrderTextField.text = @"";
    serialNoTextField.text = @"";
    
    clearButton.userInteractionEnabled = NO;
    [clearButton setBackgroundImage:[[UIImage imageNamed:@"button_inactive.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    
    [workOrderTextField resignFirstResponder];
    [serialNoTextField resignFirstResponder];
    
    [self enableDisableSaveButton];
    [self enableDisableClearButton];
}

- (void) addJob:(NSString *)savedJob {
	if (jobListArray == nil) {
		jobListArray = [[NSMutableArray alloc] init];
	}
	
	[jobListArray addObject:savedJob];
}

- (void) addJobStatusAndTime:(NSString *)savedJobStatusAndTime {
	if (statusAndTimeArray == nil) {
		statusAndTimeArray = [[NSMutableArray alloc] init];
	}
	
	[statusAndTimeArray addObject:savedJobStatusAndTime];
}

- (void) addStatusImage:(NSString *)savedStatusImage {
	if (statusImageArray == nil) {
		statusImageArray = [[NSMutableArray alloc] init];
	}
	
	[statusImageArray addObject:savedStatusImage];
}

- (NSString *)getCurrentDate {
	NSDate *now = [NSDate date];
	dateFormatter = nil;
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
	
	return [dateFormatter stringFromDate:now];
}

- (void)putSendNavButton {
    sendBarButton = [self createSquareSendBarButtonItemWithTitle:@"Send" target:self action:@selector(sendNavButtonPressed:)];
    self.navigationItem.rightBarButtonItem = sendBarButton;
}

- (void)putClearNavButton {
    clearBarButton = [self createSquareClearBarButtonItemWithTitle:@"Clear" target:self action:@selector(clearNavButtonPressed:)];
    self.navigationItem.leftBarButtonItem = clearBarButton;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        
        titleView.textColor = [UIColor grayColor];
                               
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (UIBarButtonItem *)createSquareSendBarButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a {
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    UIImage *buttonImage = [[UIImage imageNamed:@"button_inactive.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    [[sendButton titleLabel] setFont:[UIFont systemFontOfSize:13.0]];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [sendButton setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [sendButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [[sendButton titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
    
    CGRect buttonFrame = [sendButton frame];
    buttonFrame.size.width = [t sizeWithFont:[UIFont systemFontOfSize:13.0]].width + 72.0;
    buttonFrame.size.height = buttonImage.size.height - 8.0;
    [sendButton setFrame:buttonFrame];
    
    [sendButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    sendButton.userInteractionEnabled = NO;
    
    [sendButton setTitle:t forState:UIControlStateNormal];
    
    [sendButton addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    return [buttonItem autorelease];
}

- (UIBarButtonItem *)createSquareClearBarButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a {
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    UIImage *buttonImage = [[UIImage imageNamed:@"button_inactive.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    [[clearButton titleLabel] setFont:[UIFont systemFontOfSize:13.0]];
    [clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [clearButton setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [clearButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [[clearButton titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
    
    CGRect buttonFrame = [clearButton frame];
    buttonFrame.size.width = [t sizeWithFont:[UIFont systemFontOfSize:13.0]].width + 72.0;
    buttonFrame.size.height = buttonImage.size.height - 8.0;
    [clearButton setFrame:buttonFrame];
    
    [clearButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    clearButton.userInteractionEnabled = NO;
    
    [clearButton setTitle:t forState:UIControlStateNormal];
    
    [clearButton addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
    
    return [buttonItem autorelease];
}

- (void)cancelBarButtonItemTap:(id)sender {
    [self.reader dismissViewControllerAnimated:YES completion:nil];
}

- (UIToolbar *)addToolbar {
    UIToolbar *toolbar = [[[UIToolbar alloc] init] autorelease];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [toolbar sizeToFit];
    [toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    toolbar.tintColor = [UIColor blackColor];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:[[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelBarButtonItemTap:)] autorelease]];
    [toolbar setItems:items animated:NO];
    [items release];
    
    return toolbar;
}

- (IBAction) scanWorkOrderButtonTapped {
    FLog(@"Scan work order tapped");
    [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    
    // ADD: present a barcode reader that scans from the camera feed
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    reader.readerView.torchMode  = (isFlashLight == YES ? 1: 0);
    
    // present and release the controller
    [self presentViewController: reader
                       animated: YES
                     completion: nil];
    
    scanSerialNoFlag = NO;
    scanWorkOrderFlag = YES;
    
    [self.activityIndicator stopAnimating];
}

- (IBAction) scanSerialNoButtonTapped {
    FLog(@"Scan serial number tapped");
    [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    
    // ADD: present a barcode reader that scans from the camera feed
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    reader.readerView.torchMode  = (isFlashLight == YES ? 1: 0);
    
    // present and release the controller
    [self presentViewController: reader
                       animated: YES
                     completion: nil];
    
    scanWorkOrderFlag = NO;
    scanSerialNoFlag = YES;
    
    [self.activityIndicator stopAnimating];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    FLog(@"Image Taken");
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    if (isShutter) {
        // Play sound
        AudioServicesPlaySystemSound (soundID);
    }
    
    if (isVibrate) {
        // Vibrate device
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    
    // EXAMPLE: do something useful with the barcode data
    if (scanWorkOrderFlag == YES) {
        workOrderTextField.text = symbol.data;
        scanWorkOrderFlag = NO;
        
        [self enableDisableSaveButton];
        [self enableDisableClearButton];
    }
    else if (scanSerialNoFlag == YES) {
        serialNoTextField.text = symbol.data;
        scanSerialNoFlag = NO;
        
        [self enableDisableSaveButton];
        [self enableDisableClearButton];
        
        [self recordGPSData];
    }
    
    // EXAMPLE: do something useful with the barcode image
    /*resultImage.image =
    [info objectForKey: UIImagePickerControllerOriginalImage];*/
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [self.reader dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];

    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    if (textField == self.workOrderTextField) {
        [serialNoTextField becomeFirstResponder];
    }
    
    if (textField == self.serialNoTextField) {
        [self recordGPSData];
    }
}

- (void)enableDisableSaveButton {
    
    if (workOrderTextField.text.length != 0 && serialNoTextField.text.length != 0) {
        sendButton.userInteractionEnabled = YES;
        [sendButton setBackgroundImage:[[UIImage imageNamed:@"button_active.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    }
    else {
        sendButton.userInteractionEnabled = NO;
        [sendButton setBackgroundImage:[[UIImage imageNamed:@"button_inactive.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    }
}

- (void)enableDisableClearButton {
    
        if (workOrderTextField.text.length != 0) {
            clearButton.userInteractionEnabled = YES;
            [clearButton setBackgroundImage:[[UIImage imageNamed:@"button_active.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        }
        else if (serialNoTextField.text.length == 0) {
            clearButton.userInteractionEnabled = NO;
            [clearButton setBackgroundImage:[[UIImage imageNamed:@"button_inactive.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        }
    
        if (serialNoTextField.text.length != 0) {
            clearButton.userInteractionEnabled = YES;
            [clearButton setBackgroundImage:[[UIImage imageNamed:@"button_active.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        }
        else if (workOrderTextField.text.length == 0) {
            clearButton.userInteractionEnabled = NO;
            [clearButton setBackgroundImage:[[UIImage imageNamed:@"button_inactive.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        }
}

- (void) threadStartAnimating:(id)data {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [activityIndicator startAnimating];
    [pool release];
}

- (BOOL)checkForDuplicateJob {
    
    NSString *jobString = workOrderTextField.text;
    jobString = [jobString stringByAppendingString:@"\n"];
    jobString = [jobString stringByAppendingString:serialNoTextField.text];
    
    return ([jobListArray containsObject:jobString]) ?
    YES : NO;
}

- (BOOL)checkForDuplicateJobWorkOrder {
    
    for (NSString* job in jobListArray)
    {   
        if ( ![self isBatch] && [job rangeOfString:workOrderTextField.text].location != NSNotFound) {
            
            NSString *jobListString = [jobListArray objectAtIndex:[jobListArray indexOfObject:job]];
            NSArray *jobListArray = [jobListString componentsSeparatedByString:@"\n"];
            
            if ( [workOrderTextField.text isEqualToString:[jobListArray objectAtIndex:0]] ) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)checkForDuplicateJobSerialNo {

    for (NSString* job in jobListArray)
    {   
        if ([job rangeOfString:serialNoTextField.text].location != NSNotFound) {
            
            NSString *jobListString = [jobListArray objectAtIndex:[jobListArray indexOfObject:job]];
            NSArray *jobListArray = [jobListString componentsSeparatedByString:@"\n"];
            
            if ( [serialNoTextField.text isEqualToString:[jobListArray objectAtIndex:1]]) {
                return YES;
            }
        }
    }
    
    return NO;
}

-(void) keyboardWillShow:(NSNotification *) note {
    [self.view addGestureRecognizer:tapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:tapRecognizer];
}

-(void)dismissKeyboard:(UITapGestureRecognizer*) recognizer {
    if (self.workOrderTextField.isFirstResponder) {
        [self.workOrderTextField resignFirstResponder];
    }
    else if (self.serialNoTextField.isFirstResponder) {
        [self.serialNoTextField resignFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSRange spaceRange = [string rangeOfString:@" "];
    if (spaceRange.location != NSNotFound) {
        return NO;
    } else {
    	return YES;
    }
}

- (BOOL)isBatch {
    return [workOrderTextField.text rangeOfString:BATCH_ID].location != NSNotFound ? YES : NO;
}

- (BOOL)isSerialNoValid:(NSString *)serialNo {
    NSString *extractedSerialNo = [NSString stringWithString:serialNo];
    
    if ([extractedSerialNo length] == 11 && [[extractedSerialNo uppercaseString] hasPrefix:@"S"]) {
        extractedSerialNo = [extractedSerialNo substringFromIndex:1];
        [serialNoTextField setText:extractedSerialNo];
        self.validSerialNoActionTitle = [NSString stringWithFormat:@"%@ is the valid Serial Number for this job.\n", extractedSerialNo];
        return true;
    }
    else if ([extractedSerialNo length] == 13 && [[extractedSerialNo uppercaseString] hasPrefix:@"(S)"]) {
        extractedSerialNo = [extractedSerialNo substringFromIndex:3];
        [serialNoTextField setText:extractedSerialNo];
        self.validSerialNoActionTitle = [NSString stringWithFormat:@"%@ is the valid Serial Number for this job.\n", extractedSerialNo];
        return true;
    }
    
    if ([extractedSerialNo length] != 10) {
        return false;
    }
    else {
        self.validSerialNoActionTitle = @"";
        [serialNoTextField setText:extractedSerialNo];
        return true;
    }
}

- (void)adjustSubViewsForiPhone5Resolution {
    [self.paneWorkOrderImageView setFrame:CGRectMake(6, 34, 309, 208)];
    [self.paneSerialNoImageView setFrame:CGRectMake(6, 244, 309, 208)];
    
    [self.workOrderLabel setFrame:CGRectMake(14, 85, 136, 50)];
    self.workOrderLabel.font=[self.workOrderLabel.font fontWithSize:22];
    [self.serialNoLabel setFrame:CGRectMake(14, 292, 141, 50)];
    self.serialNoLabel.font=[self.serialNoLabel.font fontWithSize:22];
    
    CGRect frameWorkOrderTextField = self.workOrderTextField.frame;
    frameWorkOrderTextField.origin.x = 14;
    frameWorkOrderTextField.origin.y = 192;
    frameWorkOrderTextField.size.width = 292;
    frameWorkOrderTextField.size.height = 31;
    self.workOrderTextField.frame = frameWorkOrderTextField;
    
    CGRect frameSerialNoTextField = self.serialNoTextField.frame;
    frameSerialNoTextField.origin.x = 14;
    frameSerialNoTextField.origin.y = 401;
    frameSerialNoTextField.size.width = 292;
    frameSerialNoTextField.size.height = 31;
    self.serialNoTextField.frame = frameSerialNoTextField;
    
    CGRect frameWorkOrderButton = self.workOrderButton.frame;
    frameWorkOrderButton.origin.x = 230;
    frameWorkOrderButton.origin.y = 77;
    frameWorkOrderButton.size.width = 76;
    frameWorkOrderButton.size.height = 66;
    self.workOrderButton.frame = frameWorkOrderButton;
    
    CGRect frameSerialNoButton = self.serialNoButton.frame;
    frameSerialNoButton.origin.x = 230;
    frameSerialNoButton.origin.y = 284;
    frameSerialNoButton.size.width = 76;
    frameSerialNoButton.size.height = 66;
    self.serialNoButton.frame = frameSerialNoButton;
    
    CGRect frameActivityIndicator = self.activityIndicator.frame;
    frameActivityIndicator.origin.x = 141;
    frameActivityIndicator.origin.y = 225;
    frameSerialNoButton.size.width = 37;
    frameSerialNoButton.size.height = 37;
    self.activityIndicator.frame = frameActivityIndicator;
}

- (void)dealloc {
	[workOrderTextField release];
    [dateFormatter release];
    [serialNoTextField release];
    [sendBarButton release];
    [clearBarButton release];
    [sendButton release];
    [clearButton release];
    [activityIndicator release];
    [reader release];
    [tapRecognizer release];
    [gpsLAT release];
    [gpsLONG release];
    [gpsALT release];
    [gpsACC release];
    [gpsFIX release];
    [paneWorkOrderImageView release];
    [paneSerialNoImageView release];
    [workOrderLabel release];
    [serialNoLabel release];
    [workOrderButton release];
    [serialNoButton release];
    [validSerialNoActionTitle release];
    [super dealloc];
}

@end
