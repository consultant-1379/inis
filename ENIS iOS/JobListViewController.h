//
//  JobListViewController.h
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 18/03/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POPReciever.h"
#import "Response.h"
#import "AppDelegate.h"

@class ScanViewController;

extern const int ToolbarButtonSize;
extern NSMutableArray *cancelExpectedJobArray;

@interface JobListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate> {

    IBOutlet UITableView *tableView;
	UITableViewCell *cell;
    UIBarButtonItem *editButton;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *deleteButton;
    UIBarButtonItem *deleteAllButton;
    NSDateFormatter *dateFormatter;
    NSIndexPath *deleteIndexPath;
    IBOutlet UILabel *noJobsLabel;
    AppDelegate *aDelegate;
    bool newResponse;
    UIAlertView *cancelAlertView;
    UIAlertView *deleteAlertView;
    UIButton *cancelSwipeButton, *deleteSwipeButton;
    UITableViewCell *cellSwiped;
    UISwipeGestureRecognizer *swipeRecognizerLeft, *swipeRecognizerRight;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UITableViewCell *cell;
@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *cancelButton;
@property (nonatomic, retain) UIBarButtonItem *deleteButton;
@property (nonatomic, retain) UIBarButtonItem *deleteAllButton;
@property (nonatomic, retain) NSIndexPath *deleteIndexPath;
@property (nonatomic, retain) UILabel *noJobsLabel;
@property (nonatomic, retain) AppDelegate *aDelegate;
@property (nonatomic, retain) UIButton *cancelSwipeButton, *deleteSwipeButton;
@property (nonatomic, retain) UITableViewCell *cellSwiped;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeRecognizerLeft, *swipeRecognizerRight;
@property (nonatomic, retain) UIAlertView *cancelAlertView;
@property (nonatomic, retain) UIAlertView *deleteAlertView;

- (void)putNavEditButton;
- (IBAction)editTable:(id)sender;
- (void)setTitle:(NSString *)title;

- (void)cancelToolbarButtonPressed:(id)sender;
- (void)deleteToolbarButtonPressed:(id)sender;
- (void)cancelTableviewButtonPressed:(id)sender;
- (void)deleteTableviewButtonPressed:(id)sender;

- (NSString *)getCurrentDate;
- (void)toolbarFooter:(CGFloat)width height:(CGFloat)height;
- (void)sendCancelJobRequest:(int)index;

- (void)cancelJob;
- (void)deleteJob;
- (void)removeContentViewButtons;

- (void)putNavDeleteAllButton;
- (IBAction)deleteAllNavButtonPressed:(id)sender;
- (void)addCancelExpectedJob:(NSString *)cancelExpectedJob;
- (void)adjustSubViewsForiPhone5Resolution;
- (CGFloat)adjustCellTextLabelSize:(NSString *)textLabel;
- (UILocalNotification *)createNotification:(NSString *)nodeSerial status:(NSString *)status;

@end
