//
//  AppDelegate.h
//  Pin5iClient
//
//  Created by mamong on 14-4-7.
//  Copyright (c) 2014年 wander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPRevealSideViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, PPRevealSideViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PPRevealSideViewController *ppRevevealSideViewController;

@end
