//
//  AccountManageViewController.m
//  Pin5i-Client
//
//  Created by mamong on 14-3-28.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "LeftViewController.h"
#import "LoginViewController.h"
#import "BaiduLoginController.h"

@interface LeftViewController ()

@end

@implementation LeftViewController

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
    UITabBarItem *thirdItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemMore tag:102];
    [self setTabBarItem:thirdItem];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark -
#pragma mark UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0?3:1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"个人管理";
            break;
        case 1:
            return @"网盘助手";
            break;
        case 2:
            return @"设置";
            break;
        case 3:
            return @"关于";
            break;
        default:
            return @"";
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Nil];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cell.imageView setImage:[UIImage imageNamed:@"account"]];
            [cell.textLabel setText:@"账户"];
        }else if (indexPath.row == 1){
            [cell.imageView setImage:[UIImage imageNamed:@"center"]];
            [cell.textLabel setText:@"个人中心"];
        }else if (indexPath.row == 2){
            [cell.imageView setImage:[UIImage imageNamed:@"inbox"]];
            [cell.textLabel setText:@"收件箱"];
        }

        cell.separatorInset = UIEdgeInsetsZero;
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }else if (indexPath.section == 1){
        
        [cell.textLabel setText:@"百度盘"];
        
    }else if (indexPath.section == 2){
        
        [cell.textLabel setText:@"设置"];
        
    }else if (indexPath.section == 3){
        
        [cell.textLabel setText:@"关于"];
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            LoginViewController *loginVC = [[LoginViewController alloc]init];
            [self presentViewController:loginVC animated:YES completion:nil];
        }
    }else if (indexPath.section == 1){
        BaiduLoginController *baiduLoginVC = [[BaiduLoginController alloc]init];
        [self presentViewController:baiduLoginVC animated:YES completion:nil];
    }
}





@end
