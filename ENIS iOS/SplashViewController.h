//
//  SplashViewController.h
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 02/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController {
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIImageView *defaultImageView;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator; 
@property (nonatomic, retain) UIImageView *defaultImageView; 

- (BOOL) isRetina;

@end
