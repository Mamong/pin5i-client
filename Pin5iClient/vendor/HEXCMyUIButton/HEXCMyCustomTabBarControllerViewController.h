//
//  HEXCMyCustomTabBarControllerViewController.h
//  ReAssistiveTouch
//
//  Created by clq on 13-8-12.
//  Copyright (c) 2013年 hexc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HEXCMyUIButton.h"

@interface HEXCMyCustomTabBarControllerViewController : UIViewController
{
    UIView *tabBarView;
    HEXCMyUIButton *myButton;
    UIButton *btn1;
    UIButton *btn2;
    UIButton *btn3;
    UIButton *btn4;
    UIButton *btnh;
    UIView *newview;
}

@property(nonatomic,strong)UIView *tabBarView;
@property(nonatomic,strong)UIButton *btn1;
@property(nonatomic,strong)UIButton *btn2;
@property(nonatomic,strong)UIButton *btn3;
@property(nonatomic,strong)UIButton *btn4;
@property(nonatomic,strong)UIButton *btnh;
@end
