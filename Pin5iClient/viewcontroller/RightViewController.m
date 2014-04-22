//
//  HistoryViewController.m
//  Pin5i-Client
//
//  Created by mamong on 14-3-28.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "RightViewController.h"
#import "SubscriptionViewController.h"
#import "PPRevealSideViewController.h"

@interface RightViewController ()

@end

@implementation RightViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (IBAction)subscribe:(id)sender
{
    SubscriptionViewController *subscription = [[SubscriptionViewController alloc]init];
    [self.revealSideViewController openCompletelyAnimated:YES completion:nil];
    [self.navigationController pushViewController:subscription animated:YES];
}


- (IBAction)edit:(id)sender
{
    
}




@end
