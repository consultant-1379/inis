//
//  NotificationSettingsViewController.m
//  ENIS
//
//  Created by etunerd on 14/02/2013.
//  Copyright (c) 2013 Ericsson. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface NotificationSettingsViewController ()

@end

@implementation NotificationSettingsViewController

@synthesize groupedTableView;
@synthesize tableContents;
@synthesize sortedKeys;
@synthesize checkedIndexPath;

NSString * const On = @"On";
NSString * const Error_only = @"Error only";
NSString * const Off = @"Off";
NSString *notifValue = @"On";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTitle:@"Notifications"];
        
        // Configure grouped table view
        NSArray *arrTemp1 = [[NSArray alloc]
                             initWithObjects:On, Error_only, Off, nil];
        NSDictionary *temp =[[NSDictionary alloc]
                             initWithObjectsAndKeys:arrTemp1, @"", nil];
        self.tableContents =temp;
        [temp release];
        self.sortedKeys = [[self.tableContents allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        [arrTemp1 release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
	NSArray *listData = [self.tableContents objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]];
    
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    
	if(cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleValue1
                 reuseIdentifier:SimpleTableIdentifier] autorelease];
	}
	
    NSUInteger row = [indexPath row];
	cell.textLabel.text = [listData objectAtIndex:row];
    
    if ([notifValue isEqualToString:On] && [cell.textLabel.text isEqualToString:On]) {
        self.checkedIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
    }
    else if ([notifValue isEqualToString:Error_only] && [cell.textLabel.text isEqualToString:Error_only]) {
        self.checkedIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
    }
    else if ([notifValue isEqualToString:Off] && [cell.textLabel.text isEqualToString:Off]) {
        self.checkedIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *listData =[self.tableContents objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]];
    NSUInteger row = [indexPath row];
    NSString *rowValue = [listData objectAtIndex:row];
    
    // Uncheck the previous checked row
    if(self.checkedIndexPath) {
        UITableViewCell* uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        uncheckCell.textLabel.textColor = [UIColor blackColor];
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
    self.checkedIndexPath = indexPath;
    
    
    if ([rowValue isEqualToString:On]) {
        notifValue = On;
    }
    else if ([rowValue isEqualToString:Error_only]) {
        notifValue = Error_only;
    }
    else if ([rowValue isEqualToString:Off] ) {
        notifValue = Off;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AppDelegate* aDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [aDelegate.settingsViewController.groupedTableView reloadData];
}

- (void)dealloc {
    [super dealloc];
    [groupedTableView release];
    [tableContents release];
	[sortedKeys release];
    [checkedIndexPath release];
}

@end
