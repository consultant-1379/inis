//
//  ScanViewController.h
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 18/03/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "RequestProperty.h"

extern NSMutableArray *jobListArray;
extern NSMutableArray *statusAndTimeArray;
extern NSMutableArray *statusImageArray;

@interface ScanViewController : UIViewController <ZBarReaderDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIActionSheetDelegate> {
    
    IBOutlet UITextField *workOrderTextField;
    IBOutlet UITextField *serialNoTextField;
    IBOutlet UIImageView *paneWorkOrderImageView;
    IBOutlet UIImageView *paneSerialNoImageView;
    IBOutlet UILabel *workOrderLabel;
    IBOutlet UILabel *serialNoLabel;
    IBOutlet UIButton *workOrderButton;
    IBOutlet UIButton *serialNoButton;
    UIBarButtonItem *sendBarButton;
    UIBarButtonItem *clearBarButton;
    UIButton *sendButton, *clearButton;
    NSDateFormatter *dateFormatter;
    BOOL scanWorkOrderFlag, scanSerialNoFlag;
    CGFloat animatedDistance;
    SystemSoundID soundID;
    AppDelegate *aDelegate;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    ZBarReaderViewController *reader;
    UITapGestureRecognizer *tapRecognizer;
    NSString *gpsLAT, *gpsLONG, *gpsALT, *gpsACC, *gpsFIX;
    NSString *validSerialNoActionTitle;
}

@property (nonatomic, retain) UITextField *workOrderTextField;
@property (nonatomic, retain) UITextField *serialNoTextField;
@property (nonatomic, retain) UIImageView *paneWorkOrderImageView;
@property (nonatomic, retain) UIImageView *paneSerialNoImageView;
@property (nonatomic, retain) UILabel *workOrderLabel;
@property (nonatomic, retain) UILabel *serialNoLabel;
@property (nonatomic, retain) UIButton *workOrderButton;
@property (nonatomic, retain) UIButton *serialNoButton;
@property (nonatomic, retain) UIBarButtonItem *sendBarButton;
@property (nonatomic, retain) UIBarButtonItem *clearBarButton;
@property (nonatomic, retain) UIButton *sendButton, *clearButton;
@property (nonatomic, retain) AppDelegate *aDelegate;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) ZBarReaderViewController *reader;
@property (nonatomic, retain) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, retain) NSString *gpsLAT, *gpsLONG, *gpsALT, *gpsACC, *gpsFIX;
@property (nonatomic, retain) NSString *validSerialNoActionTitle;

- (IBAction)sendNavButtonPressed:(id)sender;
- (IBAction)clearNavButtonPressed:(id)sender;
- (IBAction)scanWorkOrderButtonTapped;
- (IBAction)scanSerialNoButtonTapped;

- (void)putSendNavButton;
- (void)putClearNavButton;
- (void)addJob:(NSString *)savedJob;
- (void)addJobStatusAndTime:(NSString *)savedJobStatusAndTime;
- (void)addStatusImage:(NSString *)savedStatusImage;
- (NSString *)getCurrentDate;
- (void)setTitle:(NSString *)title;
- (UIBarButtonItem *)createSquareClearBarButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a;
- (UIBarButtonItem *)createSquareSendBarButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a;
- (void)enableDisableSaveButton;
- (void)enableDisableClearButton;
- (void)threadStartAnimating:(id)data;
- (BOOL)checkForDuplicateJob;
- (BOOL)checkForDuplicateJobWorkOrder;
- (BOOL)checkForDuplicateJobSerialNo;
- (void)removeDuplicateTag1;
- (void)removeDuplicateTag2;
- (void)removeDuplicateTag3;
- (void)removeDuplicateTag4;
- (void)sendJob;
- (UIToolbar *)addToolbar;
- (void)dismissKeyboard:(UITapGestureRecognizer*) recognizer;
- (void)recordGPSData;
- (BOOL)isBatch;
- (void)adjustSubViewsForiPhone5Resolution;

@end
