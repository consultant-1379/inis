//
//  EndpointConfigViewController.h
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 03/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

extern NSString * const ConfigurationTitle;

@interface EndpointConfigViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField *bsimURLTextField;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UITextView *versionAndCopyrightTextView;
    IBOutlet UILabel *activityIndicatorLabel;
}

@property (nonatomic, retain) IBOutlet UITextField *bsimURLTextField;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UITextView *versionAndCopyrightTextView;
@property (nonatomic, retain) IBOutlet UILabel *activityIndicatorLabel;

- (IBAction)installConfigFileButtonPressed:(id)sender;
- (IBAction)cancelNavButtonPressed:(id)sender;
- (void)setTitle:(NSString *)title;
- (void) threadStartAnimating:(id)data;
- (void) generateAlert:(NSString *)title msg:(NSString *)msg;
- (void)putCancelNavButton;
- (void)removeCancelNavButton;
- (BOOL)connected;
- (NSString *)getCurrentYear;;

@end
