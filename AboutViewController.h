//
//  AboutViewController.h
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 22/03/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController {
    IBOutlet UITextView *aboutTextView;
    IBOutlet UIImageView *titleImageView;
}

@property (nonatomic, retain) UITextView *aboutTextView;
@property (nonatomic, retain) UIImageView *titleImageView;

- (IBAction)dismissAbout:(id)sender;
- (void)putDoneNavButton;
- (void)setTitle:(NSString *)title;
- (void)adjustSubViewsForiPhone5Resolution;
- (NSString *)getCurrentYear;

@end