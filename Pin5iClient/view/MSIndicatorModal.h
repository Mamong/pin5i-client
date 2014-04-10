//
//  MSIndicatorModal.h
//  Pin5i-Client
//
//  Created by mamong on 14-4-1.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTSpinKitView.h"

@interface MSIndicatorModal : UIView

@property (strong, nonatomic)  UIView *containerView;
@property (strong, nonatomic)  RTSpinKitView *spinKitView;
@property (assign, nonatomic)  RTSpinKitViewStyle spinKitViewStyle;

// the margin between spinkit view and title Label
@property (assign, nonatomic) CGFloat marginLS;
@property (strong, nonatomic)  UILabel *titleLabel;
@property (assign, nonatomic) BOOL shouldBounce;


- (id)initWithFrame:(CGRect)frame;

- (void)show;
- (void)hide;
@end
