//
//  SettingsViewController.m
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 21/03/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "NotificationSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "FileLogger.h"

@implementation SettingsViewController
@synthesize aboutViewController;
@synthesize notificationSettingsViewController;
@synthesize tableContents;
@synthesize sortedKeys;
@synthesize aSwitch;
@synthesize torchSession;
@synthesize groupedTableView;
@synthesize notifValueLabel;

NSString * const ShutterSound = @"Shutter sound";
NSString * const Vibrate = @"Vibrate";
NSString * const FlashLight = @"Flash-light";
NSString * const Notifications = @"Notifications";
NSString * const GPSLocation = @"GPS location";

BOOL isShutter = YES, isVibrate = YES, isFlashLight = NO, isGPSLocation = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Settings", @"This is for Settings and About view");
        self.tabBarItem.image = [UIImage imageNamed:@"gear_tab_icon.png"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    
    /* For iOS 5 to compile */
    UIImage *backgroundImage = [UIImage imageNamed:@"status_bar.png"];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    [self setTitle:@"Settings"];
    [self putAboutNavButton];
    
    // Configure grouped table view
    NSArray *arrTemp1 = [[NSArray alloc]
                         initWithObjects:GPSLocation, nil];
	NSArray *arrTemp2 = [[NSArray alloc]
                         initWithObjects:Notifications, nil];
	NSArray *arrTemp3 = [[NSArray alloc]
                         initWithObjects:ShutterSound, Vibrate, FlashLight,nil];
	NSDictionary *temp =[[NSDictionary alloc]
                         initWithObjectsAndKeys:arrTemp3, @"Camera", arrTemp2, @"", arrTemp1, @"Record",nil];
	self.tableContents =temp;
	[temp release];
	self.sortedKeys =[[self.tableContents allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
	[arrTemp1 release];
	[arrTemp2 release];
	[arrTemp3 release];
    
    //create the SEND LOGS button
    UIButton *sendLogsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendLogsButton.frame = CGRectMake(0, 12, 290, 48); // y was 50
    [sendLogsButton setTitle:@"Send Logs" forState:UIControlStateNormal];
    //[logOutButton setTitleColor:[UIColor  grayColor] forState:UIControlStateNormal];
    sendLogsButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [sendLogsButton addTarget:self action:@selector(sendLogsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //create the LOG OUT button
    UIButton *logOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logOutButton.frame = CGRectMake(0, 75, 290, 48); // y was 105
    [logOutButton setTitle:@"Log Out" forState:UIControlStateNormal];
    //[logOutButton setTitleColor:[UIColor  grayColor] forState:UIControlStateNormal];
    logOutButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [logOutButton addTarget:self action:@selector(logOutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //create a footer view on the bottom of the tabeview
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 290, 132)];
    [footerView addSubview:logOutButton];
    [footerView addSubview:sendLogsButton];
    groupedTableView.tableFooterView = footerView;
    [footerView release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)logOutButtonPressed:(id)sender {
    AppDelegate* aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Remove main app view
    [aDelegate.tabBarController.view removeFromSuperview];
    
    // Introduce Splash view
    [aDelegate addSplashView];
    [aDelegate createPasswordAlert];
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

-(NSString *)checkExpiryDate:(CkoCert *) cert{
    
    NSString *result;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *outputText = @"Licence is valid until:\n";
    NSDate *validTo = cert.ValidTo;
    result =  [outputText stringByAppendingString:[dateFormatter stringFromDate:validTo]];
    [dateFormatter release];
    return result;
    
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

- (void)putAboutNavButton {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(aboutNavButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
}

- (IBAction)aboutNavButtonPressed:(id)sender {
    
	if (self.aboutViewController == nil) 
	{ 
		AboutViewController *aboutController = 
		[[AboutViewController alloc] initWithNibName:@"AboutViewController" 
											  bundle:nil]; 
		self.aboutViewController = aboutController; 
		[aboutController release]; 
	} 
	
	UINavigationController *aboutNavController = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
	
	aboutNavController.navigationBar.tintColor = [UIColor whiteColor];
	aboutNavController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	[self presentViewController:aboutNavController animated:YES completion:nil];
	[aboutNavController release];
}

#pragma mark Table Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sortedKeys count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [self.sortedKeys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	NSArray *listData =[self.tableContents objectForKey:[self.sortedKeys objectAtIndex:section]];
	return [listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
	NSArray *listData =[self.tableContents objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]];
    
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    
	if(cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:SimpleTableIdentifier] autorelease];
        
        NSUInteger row = [indexPath row];
        cell.textLabel.text = [listData objectAtIndex:row];
        
        // Add switch to the cells
        if ( ![cell.textLabel.text isEqualToString:Notifications] ) {
            aSwitch = [[[UISwitch alloc] init] autorelease];
            [aSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:aSwitch];
            cell.accessoryView = aSwitch;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        // Add arrow to the Notifications setting cell
        else if ( [cell.textLabel.text isEqualToString:Notifications] ) {
            CGRect notifValueLabelFrame = CGRectMake(195, 9, 78, 25);
            notifValueLabel = [[UILabel alloc] initWithFrame:notifValueLabelFrame];
            notifValueLabel.backgroundColor = [UIColor clearColor];
            notifValueLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
            notifValueLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:notifValueLabel];
            [notifValueLabel release];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        // Set user default values
        if (isShutter && [cell.textLabel.text isEqualToString:ShutterSound]) {
            aSwitch.on = YES;
        }
        if (isVibrate && [cell.textLabel.text isEqualToString:Vibrate]) {
            aSwitch.on = YES;
        }
        if (isFlashLight && [cell.textLabel.text isEqualToString:FlashLight]) {
            aSwitch.on = YES;
        }
        if (isGPSLocation && [cell.textLabel.text isEqualToString:GPSLocation]) {
            aSwitch.on = YES;
        }
	}
    
    notifValueLabel.text = notifValue;
    
	return cell;
}

- (void)switchToggled:(id)sender {
    UISwitch* switchControl = sender;
    UITableViewCell *cell = (UITableViewCell *)switchControl.superview;
    FLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
    FLog(@"%@", cell.textLabel.text);
    
    if ([cell.textLabel.text isEqualToString:ShutterSound]) {
        if (!switchControl.on) {
            isShutter = NO;
            FLog( @"The switch is %@", isShutter ? @"YES" : @"NO" );
        }
        else {
            isShutter = YES;
            FLog( @"The switch is %@", isShutter ? @"YES" : @"NO" );
        }
    }
    else if ([cell.textLabel.text isEqualToString:Vibrate]) {
        if (!switchControl.on) {
            isVibrate = NO;
        }
        else {
            isVibrate = YES;
        }
    }
    else if ([cell.textLabel.text isEqualToString:FlashLight]) {
        if (!switchControl.on) {
            isFlashLight = NO;
        }
        else {
            isFlashLight = YES;
        }
    }
    else if ([cell.textLabel.text isEqualToString:GPSLocation]) {
        if (!switchControl.on) {
            isGPSLocation = NO;
            AppDelegate  *aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (aDelegate.locationController.locationManager != nil) {
                [aDelegate.locationController.locationManager stopUpdatingLocation];

            }
        }
        else {
            isGPSLocation = YES;
            if (isGPSLocation) {
                AppDelegate  *aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                FLog(@"email address %@", aDelegate.bsimFile.properties.iPhoneEmailAddress);
                aDelegate.locationController = [[[Location alloc] init] autorelease];
                [aDelegate.locationController.locationManager startUpdatingLocation];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *listData =[self.tableContents objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]];
    NSUInteger row = [indexPath row];
    NSString *rowValue = [listData objectAtIndex:row];
    
    if ([rowValue isEqualToString:Notifications]) {
        if (self.notificationSettingsViewController == nil)
        {
            NotificationSettingsViewController *notifController =
            [[NotificationSettingsViewController alloc] initWithNibName:@"NotificationSettingsViewController"
                                                  bundle:nil];
            self.notificationSettingsViewController = notifController;
            [notifController release];
        }
        
        [self.navigationController pushViewController:notificationSettingsViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)sendLogsButtonPressed:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [[mailer navigationBar] setTintColor:[UIColor blackColor]];
        [mailer setSubject:@"iOS ENIS Logs"];
        //NSArray *toRecipients = [NSArray arrayWithObjects:@"fisrtMail@example.com", nil];
        //[mailer setToRecipients:toRecipients];
        
        NSString *documentsDirectory = [NSHomeDirectory()
                                        stringByAppendingPathComponent:@"Documents"];
        NSString *logPath = [documentsDirectory
                             stringByAppendingPathComponent:@"application.log"];
        
        NSData *file = [NSData dataWithContentsOfFile:logPath];
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy_HH:mm:ss"];
        NSString *currentTime = @"ENIS_Logs_";
        currentTime = [currentTime stringByAppendingString:[dateFormatter stringFromDate:today]];
        NSString *attName = [currentTime stringByAppendingString:@".txt"];
        [dateFormatter release];
        [mailer addAttachmentData:file mimeType:@"text/plain" fileName:attName];
        
        NSString *emailBody = @"Emailing the log file from the ENIS iPhone application.";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
        [mailer release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [super dealloc];
    [aboutViewController release];
    [notificationSettingsViewController release];
    [tableContents release];
	[sortedKeys release];
    [aSwitch release];
    [torchSession release];
    [groupedTableView release];
    [notifValueLabel release];
}

@end
