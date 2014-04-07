//
//  MoreViewController.h
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-16.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaiduLoginController : UIViewController

// required login information
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *verifycode;
@property (nonatomic, strong) id codeString;

// important information for further purpose
@property (nonatomic, readonly, strong) NSString *token;
@property (nonatomic, readonly, strong) NSString *verifyPic;
@property (nonatomic, readonly, assign) BOOL isOnBaidu;

// save cookie to file
@property (nonatomic, strong) NSString *cookieFileURL;




@property (strong, nonatomic) IBOutlet UITextField *userNameTF;
@property (strong, nonatomic) IBOutlet UITextField *keyTF;
@property (strong, nonatomic) IBOutlet UITextField *verifyTF;
@property (strong, nonatomic) IBOutlet UIImageView *verifyImg;
@property (strong, nonatomic) IBOutlet UISwitch    *passkeySwitch;

- (IBAction)login:(id)sender;
- (IBAction) textFieldDoneEditing:(id)sender;
- (IBAction) textFieldChanged:(id)sender;
- (IBAction)rememberOrForget:(id)sender;
@end
