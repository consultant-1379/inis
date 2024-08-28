//
//  EndpointConfigViewController.m
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 03/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "EndpointConfigViewController.h"
#import "AppDelegate.h"
#import "FileFromWeb.h"
#import "ExtractBsim.h"
#import "FileLogger.h"
#import <Security/Security.h>
#import "SSKeychain.h"

NSString * const ConfigurationTitle = @"Configure ENIS";

@interface EndpointConfigViewController ()

@end

@implementation EndpointConfigViewController
@synthesize bsimURLTextField;
@synthesize activityIndicator;
@synthesize versionAndCopyrightTextView;
@synthesize activityIndicatorLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImage *backgroundImage = [UIImage imageNamed:@"status_bar.png"];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    [self setTitle:ConfigurationTitle];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    versionAndCopyrightTextView.text = [NSString stringWithFormat:@"Version %@\n© Ericsson OSS %@. All Rights Reserved", version, [self getCurrentYear]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)installConfigFileButtonPressed:(id)sender {
    
    FileFromWeb *fileFromWeb = [[[FileFromWeb alloc] init] autorelease];
    
    
    [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    
    if ( [fileFromWeb getFileFromServer:bsimURLTextField.text] ) {
        FLog(@"File from web found");
        
        ExtractBsim *extractBsim = [[[ExtractBsim alloc] init] autorelease];
        bool extracted = [extractBsim extract];
            
        if (extracted == true) {
            FLog(@"Bsim file Found");
            
            // Remove configuration view
            [self.view removeFromSuperview];
            self.view = nil;
            
            NSString *retrieveuuid = [SSKeychain passwordForService:@"com.ericsson.nis" account:@"user"];
            
            if (retrieveuuid == nil) {
                CFUUIDRef theUUID = CFUUIDCreate(NULL);
                CFStringRef string = CFUUIDCreateString(NULL, theUUID);
                CFRelease(theUUID);
                NSString *identifer = (NSString *)string;
                [SSKeychain setPassword:identifer forService:@"com.ericsson.nis" account:@"user"];
                CFRelease(string);
            }

            // Enter into application
            AppDelegate* aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [aDelegate addSplashView];
            [aDelegate createPasswordAlert];
        }
        else {
            FLog(@"File from web found but unzip failed");
            [self generateAlert:ConfigurationTitle msg:@"Configuration file is installed but unzip failed."];
        }
    }
    
    else {
        if ( [[bsimURLTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 ) {
            FLog(@"Configuration file location is empty");
            [self generateAlert:ConfigurationTitle msg:@"Field should not be empty."];
        }
        else if ( ![self connected] ) {
            FLog(@"No internet connection while installing configuration file.");
            [self generateAlert:@"Configuration Error" msg:@"There is no internet connection. Please, check your connectivity."];
        }
        else {
            FLog(@"File from web NOT found");
            [self generateAlert:@"Configuration Error" msg:@"Installation failed, please check the location entered."];
        }
    }
    
    [activityIndicatorLabel setHidden:YES];
    [activityIndicator stopAnimating];
}

- (void) generateAlert:(NSString *)title msg:(NSString *)msg { 
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:title 
                          message:msg
                          delegate:self 
                          cancelButtonTitle:nil 
                          otherButtonTitles:@"OK", nil]; 
    [alert show]; 
    [alert release];
}

- (void) threadStartAnimating:(id)data {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [activityIndicator startAnimating];
    [activityIndicatorLabel setHidden:NO];
    [pool release];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)putCancelNavButton {
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNavButtonPressed:)];
     self.navigationItem.rightBarButtonItem = cancelButton;
     self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
     [cancelButton release];
}

- (void)removeCancelNavButton {
    self.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)cancelNavButtonPressed:(id)sender {
    
    // Remove configuration view
    AppDelegate* aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [aDelegate.endpointConfigViewController.view removeFromSuperview];
    aDelegate.endpointConfigViewController = nil;
    [self.navigationController.navigationBar removeFromSuperview];
    
    // Introduce Splash (Login) screen again
    [aDelegate addSplashView];
    [aDelegate createPasswordAlert];
}

- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (NSString *)getCurrentYear {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    return yearString;
}

- (void)dealloc {
	[bsimURLTextField release];
    [activityIndicator release];
    [versionAndCopyrightTextView release];
    [activityIndicatorLabel release];
    [super dealloc];
}

@end
