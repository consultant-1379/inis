//
//  UITabBarController+autoRotate.m
//  ENIS
//
//  Created by Tuna Erdurmaz on 09/11/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "UITabBarController+autoRotate.h"

@implementation UITabBarController (autoRotate)

-(BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
