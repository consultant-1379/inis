//
//  UITabBarController+autoRotate.h
//  ENIS
//
//  Created by Tuna Erdurmaz on 09/11/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (autoRotate)

-(BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;

@end
