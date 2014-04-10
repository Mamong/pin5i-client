//
//  BookDetailViewController.h
//  Pin5i-Client
//
//  Created by mamong on 14-3-17.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEXCMyUIButton.h"
#import "SwipeView.h"
#import "BaiduPanPanel.h"
#import "EBookDetailItem.h"

@interface BookDetailViewController : UIViewController<UIWebViewDelegate>{
// property below for button
    UIView *_tabBarView;
    HEXCMyUIButton *_myButton;
    UIButton *_btn1;
    UIButton *_btn2;
    UIButton *_btn3;
    UIButton *_btn4;
    UIButton *_btnh;
    UIView *_newview;
    
}
@property(nonatomic,strong)UIView *tabBarView;
@property(nonatomic,strong)UIButton *btn1;
@property(nonatomic,strong)UIButton *btn2;
@property(nonatomic,strong)UIButton *btn3;
@property(nonatomic,strong)UIButton *btn4;
@property(nonatomic,strong)UIButton *btnh;



@property (nonatomic, strong) IBOutlet BaiduPanPanel *baiduPanel;
@property (nonatomic, strong) EBookDetailItem *ebookDetail;
@property (nonatomic, copy)   NSString *ebookURL;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

- (IBAction)pageControlTapped;
- (IBAction)showUp:(id)sender;

// for webview goback and goforward
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;

@end
