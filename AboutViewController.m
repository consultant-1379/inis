//
//  AboutViewController.m
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 22/03/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "AboutViewController.h"
#import "AppDelegate.h"

@implementation AboutViewController

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@synthesize aboutTextView;
@synthesize titleImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *backgroundImage = [UIImage imageNamed:@"status_bar.png"];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    // Set expiration dates for both ENIS and BSIM
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    
    BsimFileContents *bsimFile =  [BsimFileContents sharedBsimContents];
    NSDate *enisValidTo = bsimFile.nisCert.ValidTo;
    NSDate *bsimValidTo = bsimFile.bsimCert.ValidTo;
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    
    aboutTextView.text = [NSString stringWithFormat:@"© Ericsson OSS %@. All Rights Reserved\n\nVersion: %@\n\nENIS Certificate Expiry Date:\n%@"
                          "\n\nBSIM Certificate Expiry Date:\n%@", [self getCurrentYear], version, [dateFormatter stringFromDate:enisValidTo], [dateFormatter stringFromDate:bsimValidTo]];
    [dateFormatter release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    if (IS_IPHONE_5) {
        NSLog(@"About View: Device has iPhone 5 resolution.");
        [self adjustSubViewsForiPhone5Resolution];
    }
    else {
        NSLog(@"About View: Device has NOT iPhone 5 resolution.");
    }
    
    UIImage *backgroundImage = [UIImage imageNamed:@"status_bar.png"];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    [self putDoneNavButton];
    [self setTitle:@"About"];
    
    aboutTextView.opaque = NO;
    aboutTextView.backgroundColor = [UIColor clearColor];
    
    // Set expiration dates for both ENIS and BSIM
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    
    BsimFileContents *bsimFile =  [BsimFileContents sharedBsimContents];
    NSDate *enisValidTo = bsimFile.nisCert.ValidTo;
    NSDate *bsimValidTo = bsimFile.bsimCert.ValidTo;
    
    aboutTextView.text = [NSString stringWithFormat:@"© Ericsson OSS 2012. All Rights Reserved\n\nVersion: 1.0\n\nENIS Certificate Expiry Date:\n%@"
                          "\n\nBSIM Certificate Expiry Date:\n%@", [dateFormatter stringFromDate:enisValidTo], [dateFormatter stringFromDate:bsimValidTo]];
    [dateFormatter release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)putDoneNavButton {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
                                    initWithTitle:@"Done"                                            
                                    style:UIBarButtonItemStyleDone 
                                    target:self action:@selector(dismissAbout:)];
    doneButton.tintColor = [UIColor lightGrayColor];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
}

- (IBAction)dismissAbout:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
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

- (void)adjustSubViewsForiPhone5Resolution {
    [self.titleImageView setFrame:CGRectMake(53, 65, 230, 135)];
    
    [self.aboutTextView setFrame:CGRectMake(0, 250, 320, 236)];
    self.aboutTextView.font=[self.aboutTextView.font fontWithSize:15];
}

- (NSString *)getCurrentYear {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    return yearString;
}

- (void)dealloc {
    [super dealloc];
    [aboutTextView release];
    [titleImageView release];
}

@end
