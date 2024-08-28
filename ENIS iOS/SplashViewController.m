//
//  SplashViewController.m
//  ENIS iOS
//
//  Created by Tuna Erdurmaz on 02/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize activityIndicator;
@synthesize defaultImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.activityIndicator startAnimating];
    
    NSLog(@"Device has %@", [self isRetina] == YES ? @"Retina display." : @"NOT Retina display.");
    
    if ([self isRetina] == YES) {
        if (IS_IPHONE_5) {
            NSLog(@"Device has iPhone 5 resolution.");
            UIImage * image = [UIImage imageNamed:@"Default-568h@2x.png"];
            self.defaultImageView.image = nil;
            [defaultImageView initWithImage:image];
            
            CGRect frameActivityIndicator = self.activityIndicator.frame;
            frameActivityIndicator.origin.x = 142;
            frameActivityIndicator.origin.y = 250;
            self.activityIndicator.frame = frameActivityIndicator;
        }
        else {
            NSLog(@"Device has NOT iPhone 5 resolution.");
            UIImage * image = [UIImage imageNamed:@"Default@2x.png"];
            self.defaultImageView.image = nil;
            [defaultImageView initWithImage:image];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL) isRetina {
    if([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        return [[UIScreen mainScreen] scale] == 2.0 ? YES : NO;
    
    return NO;
}

- (void)dealloc {
    [super dealloc];
    [activityIndicator release];
    [defaultImageView release];
}

@end
