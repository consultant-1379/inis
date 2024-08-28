//
//  UINavigationController+autoRotate.m
//  ENIS
//
//  Created by Tuna Erdurmaz on 09/11/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "UINavigationController+autoRotate.h"

@implementation UINavigationController (autoRotate)

-(BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
