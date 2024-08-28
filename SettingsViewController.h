//
//  SettingsViewController.h
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 21/03/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>

@class AboutViewController;
@class NotificationSettingsViewController;

extern NSString * const ShutterSound;
extern NSString * const Vibrate;
extern NSString * const FlashLight;
extern NSString * const Notifications;

extern BOOL isShutter, isVibrate, isFlashLight, isGPSLocation;

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    AboutViewController *aboutViewController;
    NotificationSettingsViewController *notificationSettingsViewController;
    IBOutlet UITableView *groupedTableView;
    NSDictionary *tableContents;
	NSArray *sortedKeys;
    UISwitch *aSwitch;
    AVCaptureSession *torchSession;
    IBOutlet UILabel *notifValueLabel;
}

@property (nonatomic, retain) AboutViewController *aboutViewController;
@property (nonatomic, retain) NotificationSettingsViewController *notificationSettingsViewController;
@property (nonatomic,retain) UITableView *groupedTableView;
@property (nonatomic,retain) NSDictionary *tableContents;
@property (nonatomic,retain) NSArray *sortedKeys;
@property (nonatomic,retain) UISwitch *aSwitch;
@property (nonatomic, retain) AVCaptureSession * torchSession;
@property (nonatomic, retain) UILabel *notifValueLabel;

- (void)setTitle:(NSString *)title;
- (void)putAboutNavButton;
- (IBAction)aboutNavButtonPressed:(id)sender;
- (void)switchToggled:(id)sender;
- (IBAction)sendLogsButtonPressed:(id)sender;
- (IBAction)logOutButtonPressed:(id)sender;

@end
