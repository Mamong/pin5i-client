//
//  UserInfoViewController.m
//  Pin5iClient
//
//  Created by mamong on 14-4-23.
//  Copyright (c) 2014年 wander. All rights reserved.
//

#import "UserInfoViewController.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

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

/*
 http://pin5i.com/usercp.aspx
 
 
 .//*[@id='wrap']/div[@class='cpmain']/div/div[@class='cpuser s_clear']/ul[@class='cprate']
 <ul class="cprate">
 <li>
 <li>积分: 4986</li>
 <li>拼元: 2420.9</li>
 <li>贡献: 23.15</li>
 <li>信誉(B): 0</li>
 <li>信誉(S): 0</li>
 </ul>
 
 <ul class="cpinfo">
 <li>
 新短消息数:
 <script> document.write(0*-1); </script>
 0
 </li>
 <li>新通知数: 0 </li>
 </ul>
 
 
 .//*[@id='list_memcp_main']/table/tbody/tr/td[1]/strong/u/text() 系统分析师
 .//*[@id='list_memcp_main']/table/tbody/tr/td[3]/text() 会员组 类型
 .//*[@id='list_memcp_main']/table/tbody/tr/td[2]/img/@src 等级标志
 .//*[@id='list_memcp_main']/table/tbody/tr/td[4]/text() 等级积分起点
 .//*[@id='list_memcp_main']/table/tbody/tr/td[5]/text() 操作权限
 
 */


@end
