//
//  NotificationSettingsViewController.h
//  ENIS
//
//  Created by etunerd on 14/02/2013.
//  Copyright (c) 2013 Ericsson. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const On;
extern NSString * const Error_only;
extern NSString * const Off;
extern NSString *notifValue;

@interface NotificationSettingsViewController : UIViewController {
    IBOutlet UITableView *groupedTableView;
    NSDictionary *tableContents;
	NSArray *sortedKeys;
    NSIndexPath* checkedIndexPath;
}

@property (nonatomic,retain) UITableView *groupedTableView;
@property (nonatomic,retain) NSDictionary *tableContents;
@property (nonatomic,retain) NSArray *sortedKeys;
@property (nonatomic, retain) NSIndexPath *checkedIndexPath;

- (void)setTitle:(NSString *)title;

@end