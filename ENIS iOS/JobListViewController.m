//
//  JobListViewController.m
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 18/03/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "JobListViewController.h"
#import "ScanViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RequestProperty.h"
#import "MailSender.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "NotificationSettingsViewController.h"
#import "FileLogger.h"
#import "SSKeychain.h"
#import "MailReciever.h"

@implementation JobListViewController

@synthesize tableView, cell;
@synthesize editButton;
@synthesize cancelButton;
@synthesize deleteButton;
@synthesize deleteIndexPath;
@synthesize noJobsLabel;
@synthesize deleteAllButton;
@synthesize cancelSwipeButton, deleteSwipeButton;
@synthesize cellSwiped;
@synthesize swipeRecognizerLeft, swipeRecognizerRight, aDelegate;
@synthesize cancelAlertView, deleteAlertView;

const int ToolbarButtonSize = 130;
NSMutableArray *cancelExpectedJobArray;
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Job List", @"This is for listing jobs");
        self.tabBarItem.image = [UIImage imageNamed:@"job_list_tab_icon.png"];
        
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelToolbarButtonPressed:)];
        cancelButton.width = ToolbarButtonSize;
        cancelButton.enabled = NO;
        
        deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteToolbarButtonPressed:)];
        deleteButton.width = ToolbarButtonSize;
        deleteButton.tintColor = [UIColor redColor];
        deleteButton.enabled = NO;
        
        [self setToolbarItems:[NSArray arrayWithObjects:spacer, cancelButton, spacer, deleteButton, spacer, nil] animated:NO];
        [spacer release];
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
        NSLog(@"Job List View: Device has iPhone 5 resolution.");
        [self adjustSubViewsForiPhone5Resolution];
    }
    else {
        NSLog(@"Job List View: Device has NOT iPhone 5 resolution.");
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    
    aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    /* For iOS 5 to compile */
    UIImage *backgroundImage = [UIImage imageNamed:@"status_bar.png"];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    [self setTitle:@"Job List"];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
    tableView.allowsSelectionDuringEditing = YES;
    tableView.allowsSelection = NO;
    
    self.tableView.rowHeight = 113.0f;
    [self toolbarFooter:0 height:0];
    
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    
    //Add a left swipe gesture recognizer
    swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeRecognizerLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:swipeRecognizerLeft];
    
    //Add a right swipe gesture recognizer
    swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    swipeRecognizerRight.delegate = self;
    [swipeRecognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:swipeRecognizerRight];
    
    if(([aDelegate statusWaitingCount] > 0) && (!aDelegate.gettingUpdates)){
        MailReciever *mailRec = [[MailReciever alloc]init];
        [NSThread detachNewThreadSelector:@selector(waitGetNewItemsFromBsim) toTarget:mailRec withObject:nil];
    }
    
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self removeContentViewButtons];
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self removeContentViewButtons];
 
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    tableView.allowsSelection = NO;
    
    //Get location of the swipe
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    //Get the corresponding index path within the table view
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    //Check if index path is valid
    if(indexPath)
    {
        //Get the cell out of the table view
        self.cellSwiped = [self.tableView cellForRowAtIndexPath:indexPath];
        
        //Update the cell or model 
        // Create cancel button
        cancelSwipeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelSwipeButton.frame = CGRectMake(232, 15, 82, 32);
        [cancelSwipeButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [[cancelSwipeButton titleLabel] setFont:[UIFont systemFontOfSize:14.0]];
        [cancelSwipeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelSwipeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [cancelSwipeButton setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
        [cancelSwipeButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [[cancelSwipeButton titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
        [cancelSwipeButton setBackgroundImage:[UIImage imageNamed:@"button_active.png"] forState:UIControlStateNormal];
        cancelSwipeButton.tag = 1;
        [cancelSwipeButton addTarget:self action:@selector(cancelTableviewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        // Create delete button
        deleteSwipeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteSwipeButton.frame = CGRectMake(232, 68, 82, 32);
        [deleteSwipeButton setTitle:@"Delete" forState:UIControlStateNormal];
        [[deleteSwipeButton titleLabel] setFont:[UIFont systemFontOfSize:14.0]];
        [deleteSwipeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [deleteSwipeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [deleteSwipeButton setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
        [deleteSwipeButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [[deleteSwipeButton titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
        [deleteSwipeButton setBackgroundImage:[UIImage imageNamed:@"button_active.png"] forState:UIControlStateNormal];
        deleteSwipeButton.tag = 2;
        [deleteSwipeButton addTarget:self action:@selector(deleteTableviewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.35]; //0.75
        [UIView setAnimationDelegate:self];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:cellSwiped.contentView cache:YES];
        [cellSwiped.contentView addSubview:cancelSwipeButton];
        [cellSwiped.contentView addSubview:deleteSwipeButton];
        [UIView commitAnimations];
        
        
        // Enable/Disable Cancel contentview button
        bool notFailed = false;
        bool notCancelling = false;
        bool notWaiting = false;
        bool notCancelled = false;
        bool notCancelFailed = false;
        
        notFailed = ([cellSwiped.detailTextLabel.text rangeOfString:@"Failed"].location == NSNotFound);
        notCancelling = ([cellSwiped.detailTextLabel.text rangeOfString:@"Cancelling"].location == NSNotFound);
        notWaiting = ([cellSwiped.detailTextLabel.text rangeOfString:@"Waiting for cancel response"].location == NSNotFound);
        notCancelled = ([cellSwiped.detailTextLabel.text rangeOfString:@"Cancelled"].location == NSNotFound);
        notCancelFailed = ([cellSwiped.detailTextLabel.text rangeOfString:@"Cancel Failed"].location == NSNotFound);
        
        if ( notFailed && notCancelling && notWaiting && notCancelled && notCancelFailed ) {
            cancelSwipeButton.userInteractionEnabled = YES;
            [cancelSwipeButton setBackgroundImage:[[UIImage imageNamed:@"button_active.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        }
        else {
            cancelSwipeButton.userInteractionEnabled = NO;
            [cancelSwipeButton setBackgroundImage:[[UIImage imageNamed:@"button_inactive.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        }
        
    }
}

-(void)clearSwipeButtons:(UITapGestureRecognizer*) recognizer {
    [self removeContentViewButtons];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView {
    [self removeContentViewButtons];
    
    if ( !(self.editing) ) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        tableView.allowsSelection = NO;
    }
}

- (void)removeContentViewButtons {
    
    if( self.cellSwiped != nil && [[self.cellSwiped.contentView viewWithTag:1] isDescendantOfView:cellSwiped.contentView] ) {
        FLog(@"Removing content view buttons.");
        [[cellSwiped.contentView viewWithTag:1] removeFromSuperview];
        [[cellSwiped.contentView viewWithTag:2] removeFromSuperview];
    }
}


- (void)sendCancelJobRequest:(int)index {
    
    NSString *job = [jobListArray objectAtIndex:index];
    NSArray *jobFields = [job componentsSeparatedByString:@"\n"];

    FLog(@"Sending Cancel Request");
    NSString *retrieveuuid = [SSKeychain passwordForService:@"com.ericsson.nis" account:@"user"];
    RequestProperty *requestProp = [[RequestProperty alloc] init];
    requestProp.ACTION = @"cancel";
    requestProp.UUID = retrieveuuid;
    
    job = [jobListArray objectAtIndex:index];
    jobFields = [job componentsSeparatedByString:@"\n"];
    
    requestProp.NODENAME = [jobFields objectAtIndex:0];
    requestProp.SERIAL = [jobFields objectAtIndex:1];
    
    NSString *statusAndTimeString = @"Cancelling";
    statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
    statusAndTimeString = [statusAndTimeString stringByAppendingString:[self getCurrentDate]];
    requestProp.STATTIME = statusAndTimeString;
    [emailQueue addObject:requestProp];
    if (aDelegate.mailSendTimer == nil) {
        aDelegate.mailSendTimer = [[NSTimer alloc]init];
        aDelegate.mailSendTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:aDelegate selector:@selector(checkTimerAndUpdate) userInfo:nil repeats: YES];
    }
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

    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.tableView reloadData];
    
    [self.tableView addGestureRecognizer:swipeRecognizerRight];
    [self.tableView addGestureRecognizer:swipeRecognizerLeft];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    iconBadgeNumber = 1;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [super setEditing:NO animated:YES];
    //[self.tableView setEditing:NO animated:YES];
    [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
    [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
    
    [self toolbarFooter:0 height:0];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    tableView.allowsSelection = NO;
    cancelButton.enabled = NO;
    deleteButton.enabled = NO;
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    self.deleteAllButton = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
    [self removeContentViewButtons];
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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([jobListArray count] > 0) {
        if (self.navigationItem.rightBarButtonItem == nil) {
            [self putNavEditButton];
        }
        
        self.noJobsLabel.hidden = YES;
    }
    else {
        self.noJobsLabel.hidden = NO;
    }
    return [jobListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
    NSInteger row = [indexPath row];
	NSUInteger count = [jobListArray count];
    NSString *workOrderLabel = nil;
    CGFloat textLabelFontSize;
	
	cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
    // Set up the cell...
	cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.text = [jobListArray objectAtIndex:count-1-row]; 
	cell.detailTextLabel.text = [statusAndTimeArray objectAtIndex:count-1-row]; 
	cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    NSArray *tmpJobListArray = [cell.textLabel.text componentsSeparatedByString:@"\n"];
    workOrderLabel = [tmpJobListArray objectAtIndex:0];
    textLabelFontSize = [self adjustCellTextLabelSize:workOrderLabel];
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:textLabelFontSize];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
	
    UIImage* theImage = [UIImage imageNamed:[statusImageArray objectAtIndex:count-1-row]];
    cell.imageView.image = theImage;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    deleteButton.enabled = YES;
    cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    
    bool notFailed = false;
    bool notCancelling = false;
    bool notWaiting = false;
    bool notCancelled = false;
    bool notCancelFailed = false;
    
    notFailed = ([cell.detailTextLabel.text rangeOfString:@"Failed"].location == NSNotFound);
    notCancelling = ([cell.detailTextLabel.text rangeOfString:@"Cancelling"].location == NSNotFound);
    notWaiting = ([cell.detailTextLabel.text rangeOfString:@"Waiting for cancel response"].location == NSNotFound);
    notCancelled = ([cell.detailTextLabel.text rangeOfString:@"Cancelled"].location == NSNotFound);
    notCancelFailed = ([cell.detailTextLabel.text rangeOfString:@"Cancel Failed"].location == NSNotFound);
    
    if ( notFailed && notCancelling && notWaiting && notCancelled && notCancelFailed ) {
        cancelButton.enabled = YES;
    }
    
    else {
        cancelButton.enabled = NO;
    }
}

- (CGFloat)adjustCellTextLabelSize:(NSString *)textLabel {
    return ( [textLabel length] < 40 ) ? 18.0 : 14.0;
}

- (void)putNavEditButton {
    editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editTable:)];
    [self.navigationItem setRightBarButtonItem:editButton];
}

- (IBAction) editTable:(id)sender {
    
    cancelButton.enabled = NO;
    deleteButton.enabled = NO;
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
    if(self.editing) {
        [super setEditing:NO animated:YES];
        //[self.tableView setEditing:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
        
        [self toolbarFooter:0 height:0];
        [self.navigationController setToolbarHidden:YES animated:YES];
        tableView.allowsSelection = NO;
        
        self.deleteAllButton = nil;
        self.navigationItem.leftBarButtonItem = nil;
        
        // Add back gesture recognizers
        [self.tableView addGestureRecognizer:swipeRecognizerRight];
        [self.tableView addGestureRecognizer:swipeRecognizerLeft];
    }
    else {
        [super setEditing:YES animated:YES];
        //[self.tableView setEditing:YES animated:YES];
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        
        [self toolbarFooter:1 height:44];
        [self.navigationController setToolbarHidden:NO animated:YES];
        tableView.allowsSelection = YES;
        
        [self putNavDeleteAllButton];
        
        // Remove gesture recognizers
        [self.tableView removeGestureRecognizer:swipeRecognizerRight];
        [self.tableView removeGestureRecognizer:swipeRecognizerLeft];
        
        [self removeContentViewButtons];
    }
}

- (void)cancelToolbarButtonPressed:(id)sender {
    
    cancelAlertView = [[UIAlertView alloc] 
						  initWithTitle:@"Are you sure you want to cancel this job?" 
						  message:nil 
						  delegate:self 
						  cancelButtonTitle:@"No" 
						  otherButtonTitles:@"Yes", nil]; 
    cancelAlertView.tag = 1;
    [cancelAlertView show];
}

- (void)deleteToolbarButtonPressed:(id)sender {
    deleteAlertView = [[UIAlertView alloc]
						  initWithTitle:@"Are you sure you want to delete this job?" 
						  message:nil 
						  delegate:self 
						  cancelButtonTitle:@"No" 
						  otherButtonTitles:@"Yes", nil]; 
    deleteAlertView.tag = 2;
    [deleteAlertView show]; 
}

- (void)cancelTableviewButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Are you sure you want to cancel this job?" 
						  message:nil 
						  delegate:self 
						  cancelButtonTitle:@"No" 
						  otherButtonTitles:@"Yes", nil]; 
    alert.tag = 1;
    [alert show]; 
    [alert release];
}

- (void)deleteTableviewButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Are you sure you want to delete this job?" 
						  message:nil 
						  delegate:self 
						  cancelButtonTitle:@"No" 
						  otherButtonTitles:@"Yes", nil]; 
    alert.tag = 2;
    [alert show]; 
    [alert release];
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // CANCEL JOB
    if (actionSheet.tag == 1 && buttonIndex == 1) {
        [self cancelJob];
    }
    
    // DELETE JOB
    else if (actionSheet.tag == 2 && buttonIndex == 1) {
        [self deleteJob];
    }
}

- (void)cancelJob {
    FLog(@"Cancelling job");
    
    aDelegate.performingNetworkTask = YES;
    
    if ( [self.editButton.title isEqualToString:@"Done"] )
    { // Edit with edit nav button
        
        cell = [self.tableView cellForRowAtIndexPath:tableView.indexPathForSelectedRow];
      
        if ( [cell.detailTextLabel.text rangeOfString:@"Waiting for bind response"].location != NSNotFound ) {
            [self addCancelExpectedJob:cell.textLabel.text];
            FLog(@"Cancel expected job is %@", cell.textLabel.text);
        }
        
        NSString *statusAndTimeString = @"Cancelling";
        NSString *cancelledString = @"Cancelled";
        statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
        cancelledString = [cancelledString stringByAppendingString:@"\n"];
        statusAndTimeString = [statusAndTimeString stringByAppendingString:[self getCurrentDate]];
        cancelledString = [cancelledString stringByAppendingString:[self getCurrentDate]];
        
        NSString *cancellingstatusImage = @"status2";
        NSString *cancelledstatusImage = @"status3";
        BOOL notyetsent = false;
        
        // Update generic status and time Array
        for (int index = 0; index < [statusAndTimeArray count]; index++) {
            
            NSString *job = cell.textLabel.text;
            NSArray *jobFields = [job componentsSeparatedByString:@"\n"];
            
            bool notSending = false;
            notSending = ([cell.detailTextLabel.text rangeOfString:@"Sending bind request"].location == NSNotFound);
            
            // delete job from queue if not already sent.
            for (RequestProperty *element in emailQueue) {
                // do something with object
                if ( [element.NODENAME isEqualToString:[jobFields objectAtIndex:0]] && [element.SERIAL isEqualToString:[jobFields objectAtIndex:1]] )
                {
                    if (!notSending) {
                        [emailQueue removeObject:element];
                        notyetsent = true;
                    }
                    break;
                }
            }
            
            if ( [cell.textLabel.text isEqualToString:[jobListArray objectAtIndex:index]] && (!notyetsent) ) {
                FLog(@"ALREADYSENT");
                [statusAndTimeArray replaceObjectAtIndex:index withObject:statusAndTimeString];
                [statusImageArray replaceObjectAtIndex:index withObject:cancellingstatusImage];
                [self sendCancelJobRequest:index];
                
                [tableView reloadData];
                cancelButton.enabled = NO;
                deleteButton.enabled = NO;
                [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
                return;
            }
            
            else if ( [cell.textLabel.text isEqualToString:[jobListArray objectAtIndex:index]] && (notyetsent) ) {
                FLog(@"NOTYETSENT");
                [statusAndTimeArray replaceObjectAtIndex:index withObject:cancelledString];
                [statusImageArray replaceObjectAtIndex:index withObject:cancelledstatusImage];
                
                // Create Local Notification for a job update
                if ( ![notifValue isEqualToString:Off] && ![notifValue isEqualToString:Error_only] ) {
                    FLog(@"Notifications %@", notifValue);
                    NSString *job = [jobListArray objectAtIndex:index];
                    NSArray *jobFields = [job componentsSeparatedByString:@"\n"];
                    [self createNotification:[jobFields objectAtIndex:1] status:cancelledString];
                }
                
                [tableView reloadData];
                cancelButton.enabled = NO;
                deleteButton.enabled = NO;
                [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
                return;
            }
        }
        
    }
    else 
    { // This is edit with user gestures (swipe your finger)
        
        if ( [cellSwiped.detailTextLabel.text rangeOfString:@"Waiting for bind response"].location != NSNotFound ) {
            [self addCancelExpectedJob:cellSwiped.textLabel.text];
            FLog(@"Cancel expected job is %@", cellSwiped.textLabel.text);
        }
        
        NSString *statusAndTimeString = @"Cancelling";
        NSString *cancelledString = @"Cancelled";
        statusAndTimeString = [statusAndTimeString stringByAppendingString:@"\n"];
        statusAndTimeString = [statusAndTimeString stringByAppendingString:[self getCurrentDate]];
        cancelledString = [cancelledString stringByAppendingString:@"\n"];
        cancelledString = [cancelledString stringByAppendingString:[self getCurrentDate]];
        NSString *cancellingstatusImage = @"status2";
        NSString *cancelledstatusImage = @"status3";
        BOOL notyetsent = false;

        
        // Update generic status and time Array
        for (int index = 0; index < [statusAndTimeArray count]; index++) {
            
            NSString *job = cellSwiped.textLabel.text;
            NSArray *jobFields = [job componentsSeparatedByString:@"\n"];
            
            bool notSending = false;
            notSending = ([cellSwiped.detailTextLabel.text rangeOfString:@"Sending bind request"].location == NSNotFound);
            
            // delete job from queue if not already sent.
            for (RequestProperty *element in emailQueue) {
                // do something with object
                if ( [element.NODENAME isEqualToString:[jobFields objectAtIndex:0]] && [element.SERIAL isEqualToString:[jobFields objectAtIndex:1]] )
                {
                    if (!notSending) {
                        [emailQueue removeObject:element];
                        notyetsent = true;
                    }
                    break;
                }
            }
            
            if ( [cellSwiped.textLabel.text isEqualToString:[jobListArray objectAtIndex:index]] && (!notyetsent) ) {
                FLog(@"ALREADYSENT");
                [statusAndTimeArray replaceObjectAtIndex:index withObject:statusAndTimeString];
                [statusImageArray replaceObjectAtIndex:index withObject:cancellingstatusImage];
                //cancelButton.enabled = NO;
                [self sendCancelJobRequest:index];
                
                [tableView reloadData];
                [self removeContentViewButtons];
                return;
            }
            else if ( [cellSwiped.textLabel.text isEqualToString:[jobListArray objectAtIndex:index]] && (notyetsent) ) {
                FLog(@"NOTYETSENT");
                [statusAndTimeArray replaceObjectAtIndex:index withObject:cancelledString];
                [statusImageArray replaceObjectAtIndex:index withObject:cancelledstatusImage];
                
                // Create Local Notification for a job update
                if ( ![notifValue isEqualToString:Off] && ![notifValue isEqualToString:Error_only] ) {
                    FLog(@"Notifications %@", notifValue);
                    NSString *job = [jobListArray objectAtIndex:index];
                    NSArray *jobFields = [job componentsSeparatedByString:@"\n"];
                    [self createNotification:[jobFields objectAtIndex:1] status:cancelledString];
                }
                
                [tableView reloadData];
                [self removeContentViewButtons];
                return;
            }
        } // END FOR
    }
}

- (void)deleteJob {
    FLog(@"Deleting Job");
    if ( [self.editButton.title isEqualToString:@"Done"] )
    {   // Edit with edit nav button
        NSInteger row = tableView.indexPathForSelectedRow.row;
        NSUInteger count = [jobListArray count];
        
        [jobListArray removeObjectAtIndex:count-1-row];
        [statusAndTimeArray removeObjectAtIndex:count-1-row];
        [statusImageArray removeObjectAtIndex:count-1-row];
        
        [self.tableView beginUpdates];        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:tableView.indexPathForSelectedRow, nil] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
        
        cancelButton.enabled = NO;
        deleteButton.enabled = NO;
    }
    else 
    {   // This is edit with user gestures (swipe your finger)
        NSIndexPath *indexPath = [self.tableView indexPathForCell:self.cellSwiped];
        NSInteger row = indexPath.row;
        NSUInteger count = [jobListArray count];
        
        [jobListArray removeObjectAtIndex:count-1-row];
        [statusAndTimeArray removeObjectAtIndex:count-1-row];
        [statusImageArray removeObjectAtIndex:count-1-row];
        
        [self.tableView beginUpdates];        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
        
        [self removeContentViewButtons];
    }

    if ([jobListArray count] == 0) {
        [super setEditing:NO animated:YES];
        //[self.tableView setEditing:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        [self toolbarFooter:0 height:0];
        [self.navigationController setToolbarHidden:YES animated:YES];
        tableView.allowsSelection = NO;
        
        [jobListArray removeAllObjects];
        [statusAndTimeArray removeAllObjects];
        [statusImageArray removeAllObjects];
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    }
}

- (UILocalNotification *)createNotification:(NSString *)serialNumber status:(NSString *)status {
    
    UIApplication *app = [UIApplication sharedApplication];
    
    // Create a new notification
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        
        localNotif.alertBody = [NSString stringWithFormat:@"Job updated - %@\n%@", serialNumber, status];
        localNotif.alertAction = @"View";
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = iconBadgeNumber++;
        [app presentLocalNotificationNow:localNotif];
        
        [localNotif release];
    }
    
    return localNotif;
}

- (void)addCancelExpectedJob:(NSString *)cancelExpectedJob {
    if (cancelExpectedJobArray == nil) {
		cancelExpectedJobArray = [[NSMutableArray alloc] init];
	}
	
	[cancelExpectedJobArray addObject:cancelExpectedJob];
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

- (void)putNavDeleteAllButton {
    deleteAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete All" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteAllNavButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:deleteAllButton];
}

- (IBAction)deleteAllNavButtonPressed:(id)sender { 
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete all list of jobs?"
															 delegate:self cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Delete All Jobs"
													otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.destructiveButtonIndex = 0;	// make the first button red (destructive)
	actionSheet.cancelButtonIndex = 1;
	
	[actionSheet showInView:self.parentViewController.tabBarController.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[jobListArray removeAllObjects];
		[statusAndTimeArray removeAllObjects];
        [statusImageArray removeAllObjects];
		[tableView reloadData]; 
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
		
        [super setEditing:NO animated:YES];
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = nil;
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
        self.navigationItem.leftBarButtonItem = nil;
        [self toolbarFooter:0 height:0];
        [self.navigationController setToolbarHidden:YES animated:YES];
        tableView.allowsSelection = NO;
        
        self.navigationItem.leftBarButtonItem = nil;
	}    
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

- (void)toolbarFooter:(CGFloat)width height:(CGFloat)height {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    [footer release];
}

- (void)adjustSubViewsForiPhone5Resolution {
    [self.noJobsLabel setFrame:CGRectMake(108, 180, 104, 44)];
}

- (void)dealloc {
    [super dealloc];
	[tableView release];
	[cell release];
    [editButton release];
    [cancelButton release];
    [deleteButton release];
    [deleteIndexPath release];
    [noJobsLabel release];
    [deleteAllButton release];
    [cancelSwipeButton release];
    [deleteSwipeButton release];
    [swipeRecognizerLeft release];
    [swipeRecognizerRight release];
    [cancelAlertView release];
    [deleteAlertView release];
    
    self.cellSwiped = nil;
    [cellSwiped release];
}

@end
