//
//  MoreViewController.m
//  Pin5i-Client
//
//  Created by mamong on 14-3-16.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "BaiduLoginController.h"
#import "ASIFormDataRequest.h"
#import "JNJProgressButton.h"
#import "STKeychain.h"

#define kBaiduIDRequest                  100
#define kBaiduTokenRequest               101
#define kBaiduCodestringCheckRequest     102
#define kBaiduLoginRequest               103
#define kStateCheckRequest               104


#define kServiceName @"com.mamong.baidu_login"
#define kBaiduUserName @"baidu_username"
#define kBaiduSwitchState @"baidu_switch_state"
#define kLastBaiduToken   @"baidu_last_token"

#define keyCookiesArray @[@"BDUSS", @"PTOKEN", @"STOKEN", @"SAVEUSERID"]

@interface BaiduLoginController ()<UIAlertViewDelegate>{
   
    ASIHTTPRequest *stateCheckRequest;
}
// the login button
@property (weak, nonatomic) IBOutlet JNJProgressButton *loginButton;


@property (nonatomic, strong)NSURLConnection *connection;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *verifyPic;

// if isReady is yes,we send login request,we send prepare requests ,otherwise.
@property (nonatomic, assign) BOOL isReady;

// for both set and get methods
@property (nonatomic, assign) BOOL isOnBaidu;

@end

@implementation BaiduLoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isReady = NO;
        _isOnBaidu = NO;
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"登陆";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissLoginVC)];
    [self.navigationItem setRightBarButtonItem:rightItem];
//    UINavigationBar *topbar = [[UINavigationBar  alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
//    UINavigationItem *item = [[UINavigationItem alloc ]initWithTitle:NSLocalizedString(@"登陆", @"")];
//    item.rightBarButtonItem = rightItem;
//    [topbar pushNavigationItem:item animated:YES];
//    [self.view addSubview:topbar];
    
    BOOL isOn = [[[NSUserDefaults standardUserDefaults]objectForKey:kBaiduSwitchState]boolValue];
    [self.passkeySwitch setOn:isOn];
    
    [self addObserver:self forKeyPath:@"isOnBaidu" options:NSKeyValueObservingOptionNew context:NULL];
}


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isOnBaidu"];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.passkeySwitch isOn]) {
        NSError *error = nil;
        self.userNameTF.text = [[NSUserDefaults standardUserDefaults]objectForKey:kBaiduUserName];
        
        self.keyTF.text = [STKeychain getPasswordForUsername:self.userNameTF.text
                                              andServiceName:kServiceName
                                                       error:&error];
        if (error) {
            NSLog(@"error happens when read passkey from keychain:%@",[error description]);
        }
    }

     self.isReady = NO;
    [self sendStateCheckRequest];
    [self setupLoginButton];
}


- (void)setupLoginButton
{
        //self.loginButton.tintColor = [UIColor blueColor];
        self.loginButton.startButtonImage = [UIImage imageNamed:@"56-cloud"];
        
        self.loginButton.endButtonImage = [UIImage imageNamed:@"56-cloud"];
    
        
        __weak typeof(self) weak_self = self;
        self.loginButton.startButtonDidTapBlock = ^(JNJProgressButton *button){
            [weak_self startProgressWithButton:button];
        };
        self.loginButton.endButtonDidTapBlock = ^(JNJProgressButton *button){
            [weak_self endProgressWithButton:button];
        };
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.passkeySwitch isOn]) {
        [self saveLoginInfo];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [stateCheckRequest clearDelegatesAndCancel];
}


- (void)saveLoginInfo
{
    NSError *error = nil;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.userNameTF.text forKey:kBaiduUserName];
    
    BOOL success = [STKeychain storeUsername:self.userNameTF.text
                                 andPassword:self.keyTF.text
                              forServiceName:kServiceName
                              updateExisting:YES error:&error];
    if (!success) {
        NSLog(@"erro happens when save login information:%@",[error description]);
    }
}



- (void)login:(id)sender
{
    if ([stateCheckRequest isExecuting]) {
        [stateCheckRequest cancel];
    }

    self.username = self.userNameTF.text;
    self.password = self.keyTF.text;
    if([self.username length] == 0 ||
       [self.password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"密码或用户名不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [self cancelLoginButton];
    } else if([self.username length] &&[self.password length]){
        if (self.loginButton.JNJState == JNJProgressButtonStateProgressing) {
            // if is ready to login,send login request only
            if (self.isReady) {
                [self sendLoginRequest:nil];
            }else
            {
                // if cookies contain BDUSS,we send token request directly,it can shorten the cost of time
                if (![self containCookieWithName:@"BDUSS" forURL:[NSURL URLWithString:@"http://www.baidu.com"]]) {
                    //首次访问百度主页只是为了获得BAIDUID这个Cookie
                    ASIFormDataRequest *theRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
                    theRequest.useCookiePersistence = YES;
                    theRequest.tag = kBaiduIDRequest;
                    [theRequest setRequestMethod:@"Get"];
                    [self requestCommonSetup:theRequest];
                    [theRequest startAsynchronous];
                }else{
                    // send request for fetching token
                    ASIFormDataRequest *tokenRequest =[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://passport.baidu.com/v2/api/?getapi&class=login&tpl=pp&tangram=true"]];
                    tokenRequest.tag = kBaiduTokenRequest;
                    [tokenRequest setRequestMethod:@"Get"];
                    [self requestCommonSetup:tokenRequest];
                    [tokenRequest startAsynchronous];
                }
            }

        }
    }
}





- (void)requestCommonSetup:(ASIHTTPRequest *)request
{
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestFinished:)];
}



- (void)requestFailed:(ASIHTTPRequest *)request{
    
    if (request.tag == kBaiduIDRequest) {
        NSLog(@"error id");
        [self handleError:@"error id"];
        [self cancelLoginButton];
    }else if (request.tag == kBaiduTokenRequest){
        NSLog(@"error token");
        [self handleError:@"error token"];
        [self cancelLoginButton];
    }else if (request.tag == kBaiduCodestringCheckRequest){
        NSLog(@"error code");
        [self handleError:@"error code"];
        [self cancelLoginButton];
    }else if (request.tag == kBaiduLoginRequest){
        NSLog(@"error login");
        [self handleError:@"error login"];
        [self cancelLoginButton];
    }else if (request.tag == kStateCheckRequest){
        NSLog(@"error check state");
// check request is sent automatically,so we do not need to send action to cancel it
    }
    self.isOnBaidu = NO;
}


- (void)requestFinished:(ASIHTTPRequest *)request{
    
#ifdef MSDEBUG
        NSLog(@"===get cookie ====");
        NSLog(@"%@",[[request responseCookies]description]);
        NSLog(@"===request cookie ====");
        NSLog(@"%@",[[request requestCookies]description]);
#endif
        if (request.tag == kBaiduIDRequest) {
            //首次访问百度主页只是为了获得BAIDUID这个Cookie，方便起见，不手动管理.接着发起下一个请求。
            ASIFormDataRequest *tokenRequest =[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://passport.baidu.com/v2/api/?getapi&class=login&tpl=pp&tangram=true"]];
            tokenRequest.tag = kBaiduTokenRequest;
            [tokenRequest setRequestMethod:@"Get"];
            [self requestCommonSetup:tokenRequest];
            [tokenRequest startAsynchronous];
            
        }else if (request.tag == kBaiduTokenRequest){
            //从请求到的字符串中解析出token
            NSString *responseString = [request responseString];
#ifdef MSDEBUG
            NSLog(@"responseString ====%@========",responseString);
#endif
            
// get token from response string
            NSRange tokenRange = [responseString rangeOfString:@"login_token=\'(.+)\'"
                                                       options:NSRegularExpressionSearch];
            
            NSString *supposeContent = [[[responseString substringWithRange:tokenRange]
                                         componentsSeparatedByString:@"'"]objectAtIndex:1];
            if ([supposeContent hasPrefix:@";"]) {
                self.token = nil;
                NSLog(@"token is nil");
            }else if ([supposeContent hasPrefix:@"the fisrt two args should be string type"]){
                NSLog(@"warning:you see this warning"\
                      "mostly because the cookie 'BAIDUID' is not available before"\
                      "request has been sent");
                self.token = nil;
            }else {
                self.token = supposeContent;
                [self saveLastToken];
                //接着发起下一次请求,用于检查是否要验证码
                ASIFormDataRequest *codeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://passport.baidu.com/v2/api/?logincheck&callback=bdPass.api.login._needCodestringCheckCallback&tpl=pp&charset=utf-8&index=0&username=%@&time=1345429566039",self.username]]];
                codeRequest.tag = kBaiduCodestringCheckRequest;
                [codeRequest setRequestMethod:@"Get"];//must explict set get method,or asi will fetch connect method data
                [self requestCommonSetup:codeRequest];
                [codeRequest startAsynchronous];
            }
            
        }else if (request.tag == kBaiduCodestringCheckRequest){
            
            // -------------------------------------------------------------------------------
            //	check for code string's value,to see it's null or other a complex string
            // -------------------------------------------------------------------------------
            NSString *responseString = [request responseString];
//#ifdef MSDEBUG
            NSLog(@"responseString ====%@=====",responseString);
//#endif
            NSRange jsonRange;
            jsonRange.location = [@"bdPass.api.login._needCodestringCheckCallback(" length];
            jsonRange.length = [responseString length] - jsonRange.location - 1;
            NSString *jsonString = [responseString substringWithRange:jsonRange];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *serializationEror = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&serializationEror];
            id codeString = [dict objectForKey:@"codestring"];
            self.codeString = codeString;
            if ([self.codeString isKindOfClass:[NSNull class]]) {
                
                // now,it's time to login baidu.
                [self sendLoginRequest:nil];
            }else{
                [self handleError:@"need verify code"];
                [self setVerifyImgWithCodeString];
            }
            

//            NSRange codeStringRange = [responseString rangeOfString:@"codestring\":(.+),"
//                                                            options:NSRegularExpressionSearch];
//            NSRange tmpRange;
//            tmpRange.location = codeStringRange.location;
//            tmpRange.length = codeStringRange.length -1;         //skip the last character","
//            // you should use id type to receive the result,it works well when the result is
//            // null or other complex string.
//            NSString *codeString = [[[responseString substringWithRange:tmpRange]
//                                     componentsSeparatedByString:@":"]objectAtIndex:1];
//#ifdef MSDEBUG
//            NSLog(@"codeString ====%@",[codeString class]);
//#endif
//            if (![codeString isEqualToString:@"null"]) {
//                self.codeString = codeString;
//                [self setVerifyImgWithCodeString];
//                
//            }
            
        }else if (request.tag == kBaiduLoginRequest){
            NSString *responseString = [request responseString];
#ifdef MSDEBUG
            NSLog(@"responseString ====%@=====",responseString);
#endif
            NSRange tmpRange = [responseString rangeOfString:@"err_no=(.+)&callback"
                                                     options:NSRegularExpressionSearch];
            NSRange errorRange;
            errorRange.location = tmpRange.location + [@"err_no=" length];
            errorRange.length = tmpRange.length - [@"err_no=&callback" length];
#ifdef MSDEBUG
            NSLog(@"error:%@",[responseString substringWithRange:errorRange]);
#endif
            int error_no = [[responseString substringWithRange:errorRange]intValue];
            if (error_no) {
                [self checkForCodeStringfromResponseString:responseString];
                if (self.codeString) {
                    [self setVerifyImgWithCodeString];
                }
            }
            
            switch (error_no) {
                case 0:
                {
                    if([self isOnBaiduCheck]){
                        NSLog(@"login success");
                        [self.loginButton setProgress:1.0 animated:NO];
                        [self handleError:@"login success"];
                    }else
                        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                    break;
                }
                case 1:
                {    NSLog(@"ilegal request");
                    [self handleError:@"ilegal request"];
                    break;
                }
                case 4:
                {
                    NSLog(@"username or password wrong");
                    [self handleError:@"username or password wrong"];
                    break;
                }
                case 6:
                {
                    NSLog(@"verify code wrong");
                    [self handleError:@"verify code wrong"];
                    break;
                }
                case 257:
                {
                    NSLog(@"need verify code");
                    [self handleError:@"need verify code"];
                    break;
                }
                case 100023:
                {
                    NSLog(@"you need login again");
                    [self handleError:@"you have logined already"];
                    [self cancelLoginButton];
                    break;
                }
                case 119998:
                {
                    NSLog(@"token verify failed");
                    [self handleError:@"token verify failed"];
                    break;
                }
                default:
                {
                    NSLog(@"unknown error");
                    [self handleError:@"unknown error"];
                    [self cancelLoginButton]; 
                    break;
                }
            }
    }else if (request.tag == kStateCheckRequest){
        NSLog(@"response string:%@",[request responseString]);
        NSError *error = nil;
        NSString *string = [[request responseString] stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
        //fuck baidu,using unstandard json format
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            NSDictionary *errInfo = [resultDict objectForKey:@"errInfo"];
            NSDictionary *dataDict = [resultDict objectForKey:@"data"];
            NSString *erro_no = [errInfo objectForKey:@"no"];
            NSString *username = [dataDict objectForKey:@"rememberedUserName"];
            id token = [dataDict objectForKey:@"token"];
            id lastToken = [[NSUserDefaults standardUserDefaults]objectForKey:kLastBaiduToken];NSLog(@"lastToken is %@",lastToken);
            BOOL tokenChange = YES;
            if (token&&lastToken) {
                tokenChange = [lastToken isEqualToString:token]?NO:YES;
            }
// we check the error number and the remembered username to confirm our state
// usually,the user name is the key factor.
            if (!tokenChange&&[erro_no isEqualToString:@"0"]&&
                       [self.userNameTF.text isEqualToString:username]&&[self isOnBaiduCheck])
            {
                self.isOnBaidu = YES;
            }else
                self.isOnBaidu = NO;
        }else
            NSLog(@"error is %@",[error description]);
        
    }
    
}



- (void)requestSetPostData:(ASIFormDataRequest *)request
{
    NSMutableString *post = [NSMutableString stringWithFormat:@"staticpage=%@&charset=UTF-8&token=%@&tpl=pp&apiver=v3&tt=1395580577183&safeflg=0&u=%@&isPhone=true&quick_user=0&logintype=basicLogin&logLoginType=wap_loginTouch&loginmerge=true&username=%@&password=%@&mem_pass=on&ppui_logintime=33860&callback=parent.bd__pcbs__kzby57",[@"http://passport.baidu.com/static/passpc-account/html/v3Jump.html" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],self.token,[@"https://passport.baidu.com/" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],self.password];
    
    if (self.codeString) {
        [post appendFormat:@"&codestring=%@&verifycode=%@",self.codeString,self.verifyTF.text];
    }
    NSMutableData *postData = [NSMutableData dataWithData:[post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    [request setPostBody:postData];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:postLength forKey:@"Content-Length"];
    [dict setObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [request setRequestHeaders:dict];
}





- (void)sendLoginRequest:(id)sender{
    ASIFormDataRequest *loginRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://passport.baidu.com/v2/api/?login"]];
    loginRequest.tag = kBaiduLoginRequest;
    [loginRequest setRequestMethod:@"Post"];
    [self requestSetPostData:loginRequest];
    [self requestCommonSetup:loginRequest];
    [loginRequest startAsynchronous];
}



- (void)setVerifyImgWithCodeString
{
    self.verifyPic = [NSString stringWithFormat:@"https://passport.baidu.com/cgi-bin/genimage?%@",self.codeString];
    __weak BaiduLoginController *weakself = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.verifyPic]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:data];
            [weakself.verifyImg setImage:image];
// every time,the verify image is ready,login request is ready to send.
             weakself.isReady = YES;
            [weakself.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
    }];
}



- (BOOL)containCookieWithName:(NSString *)cookieName forURL:(NSURL *)url
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *currentCookies = [cookieStorage cookiesForURL:url];
    for (NSHTTPCookie *cookie in currentCookies) {
        if ([cookie.name isEqualToString:cookieName]) {
            return YES;
        }
    }
    return NO;
}

- (void)checkForCodeStringfromResponseString:(NSString *)responseString
{
    NSRange tmpRange = [responseString rangeOfString:@"captchaservice(.+)&userName"
                                             options:NSRegularExpressionSearch];
    if (tmpRange.location != NSNotFound) {
        NSRange captchaRange;
        captchaRange.location = tmpRange.location;
        captchaRange.length = tmpRange.length - [@"&userName" length];
        self.codeString = [responseString substringWithRange:captchaRange];
    }else{
        self.codeString = nil;
    }
}


- (void)sendStateCheckRequest
{
    stateCheckRequest = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:@"https://passport.baidu.com/v2/api/?getapi&tpl=ik&apiver=v3&tt=1371883487&class=login"]];
    stateCheckRequest.tag = kStateCheckRequest;
    [stateCheckRequest setRequestMethod:@"Get"];
    [self requestCommonSetup:stateCheckRequest];
    [stateCheckRequest startAsynchronous];NSLog(@"is on baidu %d",[self isOnBaiduCheck]);
}

// used after login request has been sent,to check login success or not
// in most case,you can judge it by the response data
- (BOOL)isOnBaiduCheck
{
    BOOL contain = NO;
    for (NSString *cookie in keyCookiesArray) {
        contain = [self containCookieWithName:cookie
                                       forURL:[NSURL URLWithString:@"https://passport.baidu.com"]];
        if (!contain) {
            return self.isOnBaidu = NO;
        }
    }
    return self.isOnBaidu = YES;
}


// just to clear cookies and make you offline with baidu
- (void)clearCookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *currentCookies = [cookieStorage cookiesForURL:[NSURL URLWithString:@"https://passport.baidu.com"]];
    for (NSHTTPCookie *cookie in currentCookies) {
        [cookieStorage deleteCookie:cookie];
    }
    [self isOnBaiduCheck];
}


//
- (void)saveLastToken
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:self.token forKey:kLastBaiduToken];
}



// -------------------------------------------------------------------------------
//	method name
// -------------------------------------------------------------------------------

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 3;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    if (indexPath.row == 0) {
//        UITextField *inputTF = [[UITextField alloc]initWithFrame:CGRectMake(60, 10, 100., 20)];
//        inputTF.borderStyle = UITextBorderStyleRoundedRect;
//        [cell.contentView addSubview:inputTF];
//        cell.textLabel.text = @"邮箱：";
//    }else if (indexPath.row == 1){
//        UITextField *inputTF = [[UITextField alloc]initWithFrame:CGRectMake(60, 10, 100., 20)];
//        inputTF.borderStyle = UITextBorderStyleRoundedRect;
//        [cell.contentView addSubview:inputTF];
//        inputTF.secureTextEntry = YES;
//        cell.textLabel.text = @"密码：";
//    }else if (indexPath.row == 2){
//        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(80, 5, 150, 30)];
//        [button setTitle:@"登陆" forState:UIControlStateNormal];
//        [cell.contentView addSubview:button];
//    }
//    return cell;
//        
//}




#pragma mark - Sample Progress

- (void)startProgressWithButton:(JNJProgressButton *)button
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //[NSThread sleepForTimeInterval:1];
        NSInteger index = 0;
        NSInteger direction = 1;
        while (index <= 100) {
            [NSThread sleepForTimeInterval:0.02];
            dispatch_async(dispatch_get_main_queue(), ^{
                button.progress = (index / 100.0f);
            });
            index += direction;
            if (index== 99) direction = -1;
            else if (index == 0) direction = 1;
            if (!button.progressing) return;
        }
    });
}


- (void)endProgressWithButton:(JNJProgressButton *)button
{
    [self handleError:@"您已成功登陆百度"];
}






#pragma mark -
#pragma mark switch,textfield and alert task
-(void)handleError:(NSString *)errorInfo
{
    UIAlertView *alertView =
    [[UIAlertView alloc]initWithTitle:@"验证结果" message:errorInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alertView.tag = 100;
    [alertView show];
}



- (IBAction) textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
    
}

- (IBAction) textFieldChanged:(id)sender{
// if current sate is on,while we do some change to our login infomation
// we should check the state right now.on the other hand,we do not need
// check too frequently.
    if (self.isOnBaidu) {
        [self sendStateCheckRequest];
    }
}



- (void)rememberOrForget:(id)sender
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:[NSNumber numberWithBool:self.passkeySwitch.on] forKey:kBaiduSwitchState];
}


- (void)cancelLoginButton
{
    if (self.loginButton.JNJState == JNJProgressButtonStateProgressing) {
        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark -
#pragma mark alert delegate
//---------------------------------------------------------
//     didPresentAlertView:
//---------------------------------------------------------
-(void)didPresentAlertView:(UIAlertView *)alertView
{
    [NSTimer scheduledTimerWithTimeInterval:13.5 target:alertView selector:@selector(dismissAnimated:) userInfo:nil repeats:NO];
}


//---------------------------------------------------------
//     alertView:didDismissWithButtonIndex:
//---------------------------------------------------------
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        NSRange range = [alertView.message rangeOfString:@"login success"];
        if (range.location != NSNotFound ) {
            //[self dismissViewControllerAnimated:YES completion:nil];
            
        }
    }
}



- (void)dismissLoginVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark -
#pragma mark keyValueObserve for the state of the switch
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isOnBaidu"]) {
        if ([self isOnBaidu]) {
            [self.loginButton setNeedsProgress:NO];
            self.loginButton.backgroundColor = [UIColor orangeColor];
        }else{
            [self.loginButton setNeedsProgress:YES];
            self.loginButton.backgroundColor = [UIColor whiteColor];
        }

    }
}



@end
