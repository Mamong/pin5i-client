//
//  ViewController.m
//  LoadCocoaChinaTest
//
//  Created by mamong on 13-12-15.
//  Copyright (c) 2013年 mamong. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "STKeychain.h"
#import "NSString+MSExtend.h"

#define kRequestTimeoutInterval 8.0
#define kServiceName @"com.mamong.pin5i_login"
#define kPin5iUserName @"pin5i_username"
#define kPin5iSwitchState @"pin5i_switch_state"

@interface LoginViewController ()<UIAlertViewDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.verifyImg.image = [UIImage imageNamed:@"placeholder"];
    [(UIControl *)self.view addTarget:self action:@selector(resignKeyBoard) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissLoginVC)];
    UINavigationBar *topbar = [[UINavigationBar  alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
    UINavigationItem *item = [[UINavigationItem alloc ]initWithTitle:NSLocalizedString(@"Pin5i登陆", @"")];
    item.rightBarButtonItem = rightItem;
    [topbar pushNavigationItem:item animated:YES];
    [self.view addSubview:topbar];
    
// get switch state from userdefaults
    BOOL isOn = [[[NSUserDefaults standardUserDefaults]objectForKey:kPin5iSwitchState]boolValue];
    [self.passkeySwitch setOn:isOn];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([self.passkeySwitch isOn]) {
        NSError *error = nil;
        self.userNameTF.text = [[NSUserDefaults standardUserDefaults]objectForKey:kPin5iUserName];
        
        self.keyTF.text = [STKeychain getPasswordForUsername:self.userNameTF.text
                                                   andServiceName:kServiceName
                                                            error:&error];
        if (error) {
            NSLog(@"error happens when read passkey from keychain:%@",[error description]);
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.passkeySwitch isOn]) {
        [self saveLoginInfo];
    }
}


- (void)saveLoginInfo
{
    NSError *error = nil;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.userNameTF.text forKey:kPin5iUserName];
    
    BOOL success = [STKeychain storeUsername:self.userNameTF.text
                                 andPassword:self.keyTF.text
                              forServiceName:kServiceName
                              updateExisting:YES error:&error];
    if (!success) {
        NSLog(@"erro happens when save login information:%@",[error description]);
    }
}

- (IBAction)load:(id)sender {
    username = self.userNameTF.text;
    key= self.keyTF.text;NSLog(@"user name is %@,key is %@",username,key);
    verify = self.verifyTF.text;
    //判断用户名、密码是否为空
    if([username length] == 0 ||
       [key length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"密码或用户名不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        //1.提交数据到服务器
        theRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://www.pin5i.com/login.aspx?infloat=1&&inajax=1"]];
        [ASIFormDataRequest setDefaultTimeOutSeconds:kRequestTimeoutInterval];
        [theRequest setUseCookiePersistence:YES];
        
        [theRequest setPostValue:username forKey:@"username"];
        [theRequest setPostValue:key forKey:@"password"];
        [theRequest setPostValue:verify forKey:@"vcode"];
        [theRequest setPostValue:verify forKey:@"vcodetext"];
        
        [theRequest setRequestMethod:@"Post"];

        [theRequest setDelegate:self];
        [theRequest setDidFailSelector:@selector(requestFailed:)];
        [theRequest setDidFinishSelector:@selector(requestLogin:)];
        [theRequest startAsynchronous];
    }
    
}

- (IBAction)getVerifyImg:(id)sender { 
    [self.verifyTF setText:@""];
    self.verifyImg.image = [UIImage imageNamed:@"loading"];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:
                                   [NSURL URLWithString:@"http://www.pin5i.com/tools/VerifyImagePage.aspx"]cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kRequestTimeoutInterval];
    __weak LoginViewController *weakself = self;
   [NSURLConnection sendAsynchronousRequest:request
                                      queue:[NSOperationQueue currentQueue]
                          completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                [weakself.verifyImg setImage:[UIImage imageWithData:data]];
            }else
                [weakself.verifyImg setImage:[UIImage imageNamed:@"verifyOutOfTime"]];
        });
       
    }];
    
}


- (void)requestFailed:(ASIHTTPRequest *)request{
    [self handleError:@"验证失败"];
}

- (void)requestLogin:(ASIHTTPRequest *)request{ //登录验证成功
    NSString *resultString = [request responseString];
    NSString *substring = [resultString substringFromHeader:@"<p>" toTail:@"</p>"];
    NSString *infoString = [substring substringFromIndex:[@"<p>" length]];
    [self handleError:infoString];
// 正则不稳定
//    NSRange range = [resultString rangeOfString:@"<p>[^]*?</p>" options:NSRegularExpressionSearch];
//    if (range.location != NSNotFound) {
//        range.location =range.location +3;
//        range.length = range.length - 7;
//        NSString *error = [[resultString substringWithRange:range]stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//        [self handleError:error];
//    }else
//        NSLog(@"result string is %@",resultString);
    

#ifdef MSDEBUG
    NSString *str = [request responseString];
    NSLog(@"xml=%@",str);
    NSLog(@"登录代码%@",[request responseStatusMessage]);
#endif
}

-(void)handleError:(NSString *)errorInfo
{
    UIAlertView *alertView =
    [[UIAlertView alloc]initWithTitle:@"验证结果" message:errorInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alertView.tag = 100;
    [alertView show];
}


-(void)resignKeyBoard
{
    [self.userNameTF resignFirstResponder];
    [self.keyTF resignFirstResponder];
    [self.verifyTF resignFirstResponder];
}

- (IBAction) textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}


- (void)rememberOrForget:(id)sender
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:[NSNumber numberWithBool:self.passkeySwitch.on] forKey:kPin5iSwitchState];
}

///////////////////////////////////////////////////////////////////

#pragma mark UIAlertView Delegate Methods

//---------------------------------------------------------
//     didPresentAlertView:
//---------------------------------------------------------
-(void)didPresentAlertView:(UIAlertView *)alertView
{
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:alertView selector:@selector(dismissAnimated:) userInfo:nil repeats:NO];
}


//---------------------------------------------------------
//     alertView:didDismissWithButtonIndex:
//---------------------------------------------------------
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        NSRange range = [alertView.message rangeOfString:@"登录成功"];
        if (range.location != NSNotFound ) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else
            [self getVerifyImg:nil];
    }
    
}


///////////////////////////////////////////////////////////////////

- (void)dismissLoginVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}





@end
