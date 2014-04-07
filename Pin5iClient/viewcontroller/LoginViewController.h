//
//  ViewController.h
//  LoadCocoaChinaTest
//
//  Created by mamong on 13-12-15.
//  Copyright (c) 2013年 mamong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"

@interface LoginViewController : UIViewController<ASIHTTPRequestDelegate >{
    NSString *username;
    NSString *key;
    NSString *verify;
    ASIFormDataRequest *theRequest;
    
}


@property (strong, nonatomic) IBOutlet UITextField *userNameTF;
@property (strong, nonatomic) IBOutlet UITextField *keyTF;
@property (strong, nonatomic) IBOutlet UITextField *verifyTF;
@property (strong, nonatomic) IBOutlet UIImageView *verifyImg;
@property (strong, nonatomic) IBOutlet UISwitch    *passkeySwitch;

- (IBAction)load:(id)sender;
- (IBAction)rememberOrForget:(id)sender;

- (IBAction)getVerifyImg:(id)sender;
- (IBAction) textFieldDoneEditing:(id)sender;
@end
