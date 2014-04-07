//
//  AppDelegate.m
//  Pin5iClient
//
//  Created by mamong on 14-4-7.
//  Copyright (c) 2014年 wander. All rights reserved.
//

#import "AppDelegate.h"


#import "HomeViewController.h"
#import "MSUserCenter.h"


#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    MSUserCenter *userCenter = [MSUserCenter sharedUserCenter];
    BOOL success = [userCenter initSubscriptionSetting];
    NSLog(@"launch %d",success);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    HomeViewController *homeVC = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    UINavigationController *homeNav = [[UINavigationController alloc]initWithRootViewController:homeVC];
    
    
    self.ppRevevealSideViewController = [[PPRevealSideViewController alloc]initWithRootViewController:homeNav];
    self.ppRevevealSideViewController.delegate = self;
    
    self.window.rootViewController = self.ppRevevealSideViewController;
    
    [self.window makeKeyAndVisible];
    
    if (PPSystemVersionGreaterOrEqualThan(7.0)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x34B085)];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    MSUserCenter *userCenter = [MSUserCenter sharedUserCenter];
    BOOL success = [userCenter saveSubscriptionSetting];
    NSLog(@"EnterBackground %d",success);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    MSUserCenter *userCenter = [MSUserCenter sharedUserCenter];
    BOOL success = [userCenter saveSubscriptionSetting];
    NSLog(@"terminate %d",success);
}



#pragma mark -
#pragma mark ppRevealSlideViewControllerDelegate Methods

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller willPushController:(UIViewController *)pushedController {
    PPRSLog(@"%@", pushedController);
    //    [UIView animateWithDuration:0.3
    //                     animations:^{
    //                         _iOS7UnderStatusBar.alpha = 1.0;
    //                     }];
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPushController:(UIViewController *)pushedController {
    PPRSLog(@"%@", pushedController);
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller willPopToController:(UIViewController *)centerController {
    PPRSLog(@"%@", centerController);
    //    [UIView animateWithDuration:0.3
    //                     animations:^{
    //                         _iOS7UnderStatusBar.alpha = 0.0;
    //                     }];
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController {
    PPRSLog(@"%@", centerController);
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didChangeCenterController:(UIViewController *)newCenterController {
    PPRSLog(@"%@", newCenterController);
}

- (BOOL)pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateDirectionGesture:(UIGestureRecognizer *)gesture forView:(UIView *)view {
    return NO;
}

- (PPRevealSideDirection)pprevealSideViewController:(PPRevealSideViewController *)controller directionsAllowedForPanningOnView:(UIView *)view {
    if ([view isKindOfClass:NSClassFromString(@"UIWebBrowserView")]) return PPRevealSideDirectionLeft | PPRevealSideDirectionRight;
    
    return PPRevealSideDirectionLeft | PPRevealSideDirectionRight | PPRevealSideDirectionTop | PPRevealSideDirectionBottom;
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didManuallyMoveCenterControllerWithOffset:(CGFloat)offset
{
}


@end
