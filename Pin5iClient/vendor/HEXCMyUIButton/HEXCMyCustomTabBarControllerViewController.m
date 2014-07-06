//
//  HEXCMyCustomTabBarControllerViewController.m
//  ReAssistiveTouch
//
//  Created by clq on 13-8-12.
//  Copyright (c) 2013年 hexc QQ: 727021292 . All rights reserved.
//

#import "HEXCMyCustomTabBarControllerViewController.h"

@interface HEXCMyCustomTabBarControllerViewController ()
{
    BOOL flag; //控制tabbar的显示与隐藏标志
}


@end

@implementation HEXCMyCustomTabBarControllerViewController
@synthesize btn1, btn2, btn3, btn4, btnh;
@synthesize tabBarView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bj_bg.jpg"]]];
}

//做了修改 设置tab bar
- (void)addCustomElements
{
    myButton = [HEXCMyUIButton buttonWithType:UIButtonTypeCustom];
    myButton.MoveEnable = YES;
    myButton.frame = CGRectMake(280, 300, 40, 40);
    
    //TabBar上按键图标设置
    [myButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"40.png"]] forState:UIControlStateNormal];
    [myButton setTag:10];
    flag = NO;//控制tabbar的显示与隐藏标志 NO为隐藏
    
    [myButton addTarget:self action:@selector(tabbarbtn:) forControlEvents:UIControlEventTouchUpInside];

    
    [self.view addSubview:myButton];
    
    [self _initTabBar];
}

//初始化tabbar
-(void)_initTabBar
{
    //tab bar view  始终居中显示    
    tabBarView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-100, 200 , 200)] ;
    
    //view 设置半透明 圆角样式
    tabBarView.layer.cornerRadius = 10;//设置圆角的大小
    tabBarView.layer.backgroundColor = [[UIColor blackColor] CGColor];
    tabBarView.alpha = 0.8f;//设置透明
    tabBarView.layer.masksToBounds = YES;

    [self.view addSubview:tabBarView];
    
    //循环设置tabbar上的button
    NSArray *imgNames = [[NSArray alloc]initWithObjects:@"download.png",@"block.png",@"bluetooth.png",@"file.png", nil];
    NSArray *tabTitle = [[NSArray alloc]initWithObjects:@"download",@"block",@"bluetooth",@"file", nil];
    
    for (int i=0; i<4; i++) {
        CGRect rect;
        rect.size.width = 60;
        rect.size.height = 60;
        switch (i) {
            case 0:
                rect.origin.x = 100-30;
                rect.origin.y = 40-30;
                break;
            case 1:
                rect.origin.x = 160-30;
                rect.origin.y = 100-30;
                break;
            case 2:
                rect.origin.x = 100-30;
                rect.origin.y = 160-30;
                break;
            case 3:
                rect.origin.x = 40-30;
                rect.origin.y = 100-30;
                break;
        }
        
        //设置每个tabView
        UIView *tabView = [[UIView alloc] initWithFrame:rect];
        [self.tabBarView addSubview:tabView];
        
        //设置tabView的图标
        UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tabButton.frame = CGRectMake(15, 0, 30, 30);
        [tabButton setBackgroundImage:[UIImage imageNamed:[imgNames objectAtIndex:i]] forState:UIControlStateNormal];
        [tabButton setTag:i];
        [tabButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [tabView addSubview:tabButton];
        
        //设置标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, 60, 15)];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = [tabTitle objectAtIndex:i];
        [tabView addSubview:titleLabel];
    }
    
    [tabBarView setHidden:YES];
}

//显示 隐藏tabbar
- (void)tabbarbtn:(HEXCMyUIButton*)btn
{
    //在移动的时候不触发点击事件
    if (!btn.MoveEnabled) {
        if(!flag){
            tabBarView.hidden = NO;
            flag = YES;
        }else{
            tabBarView.hidden = YES;
            flag = NO;
        }
    }

}

- (void)buttonClicked:(id)sender
{
    NSLog(@"%d",[sender tag]);
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self addCustomElements];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
