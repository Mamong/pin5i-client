//
//  ExchangeViewController.m
//  Pin5iClient
//
//  Created by mamong on 14-4-23.
//  Copyright (c) 2014年 wander. All rights reserved.
//

#import "ExchangeViewController.h"

@interface ExchangeViewController ()

@end

@implementation ExchangeViewController

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

@end

/*
 http://pin5i.com/usercpcreditspay.aspx
 
paynum=10&extcredits1=1&extcredits2=2&password=***&Submit=

 <div class="msgbox">
 <h1>拼吾爱 提示信息</h1>
 <p>积分兑换完毕, 正在返回积分兑换与转帐记录</p>
 <p><a href="usercpcreaditstransferlog.aspx">如果浏览器没有转向, 请点击这里.</a></p>
 </div>
 </div>
 </div>


*/