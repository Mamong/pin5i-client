//
//  BaiduPanPanel.m
//  Pin5i-Client
//
//  Created by mamong on 14-3-19.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "BaiduPanPanel.h"
#import "ASIFormDataRequest.h"
#import "NSString+MSExtend.h"
#import "HTMLParseHelp.h"

#define kVerifyRequest    100
#define kSaveFileRequest  101

@interface BaiduPanPanel()<NSURLConnectionDataDelegate>

@property (nonatomic, copy) NSString *bdstoken;
@property (nonatomic, strong) NSMutableData *filePageData;
@property (nonatomic, strong) NSURLConnection *connection;
@end




@implementation BaiduPanPanel



- (void)startToExtractFile
{
    NSString *verifyLink = [self.panlink panLinkToVerifyLink];
    theRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:verifyLink]];
    theRequest.tag = kVerifyRequest;
    [theRequest setRequestMethod:@"Post"];
    [theRequest setPostValue:self.extractCode forKey:@"pwd"];
    [theRequest setPostValue:@"" forKey:@"vcode"];
    [theRequest setDelegate:self];
    
    [theRequest setDidFailSelector:@selector(requestFailed:)];
    [theRequest setDidFinishSelector:@selector(requestFinished:)];
    [theRequest startAsynchronous];
#ifdef MSDEBUG
    
    NSLog(@"current ====%@========",NSStringFromSelector(_cmd));
    
#endif

}


- (void)saveFileToMyBaiduPan:(id )sender{//转存
    NSLog(@"run");
    NSString *saveRequestURL = [NSString stringWithFormat:@"http://pan.baidu.com/share/transfer?%@&bdstoken=%@&channel=chunlei&clienttype=5&web=1",[self.panlink panLinkToSaveID],self.bdstoken];
#ifdef MSDEBUG
    
    NSLog(@"saveRequestURL ====%@========",saveRequestURL);
    
#endif
    theRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:saveRequestURL]];
    theRequest.tag = kSaveFileRequest;
    [theRequest setRequestMethod:@"Post"];
    [theRequest setDelegate:self];

    NSString *post = [NSString stringWithFormat:@"path=/&filelist=%@&async=1&r=0.6657245443941149",self.filePath];
    NSMutableData *postData = [NSMutableData dataWithData:[post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    [header setObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [header setObject:postLength forKey:@"Content-Length"];
    [theRequest setRequestHeaders:header];
    [theRequest setPostBody:postData];


    [theRequest setDidFinishSelector:@selector(requestFinished:)];
    [theRequest setDidFailSelector:@selector(requestFailed:)];
    [theRequest startAsynchronous];
    
}



- (void)requestFailed:(ASIHTTPRequest *)request{
    if (request.tag == kVerifyRequest) {
        [self handleError:@"failed to send verify request"];
    }
    else if (request.tag == kSaveFileRequest){
        [self handleError:@"failed to send save request"];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request{ //verify提交提取码之后 link发送请求
    
#ifdef MSDEBUG
    
    NSLog(@"===verify cookie ====");
    NSLog(@"%@",[[request responseCookies]description]);
#endif   
    
    if (request.tag == kVerifyRequest) {
        NSURLRequest *linkRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.panlink panLinkToFileLink]]];
        
        self.connection = [NSURLConnection connectionWithRequest:linkRequest delegate:self];

        NSData *responseData = [request responseData];
        NSError *error = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (!error) {
            int errnoNum = [[responseDict valueForKey:@"errno"]intValue];
            switch (errnoNum) {
                case 0:
                    NSLog(@"extract success");
                    break;
                case -62:
                    NSLog(@"extract code wrong");
                    break;
                case -63:
                    NSLog(@"verify code wrong");
                default:
                    NSLog(@"unknown error");
                    break;
            }
        }
        //如果提交的提取码错误，则会返回错误码，可以根据错误码区分是单次错误还是连续相同提取码错误，如果是后者则会返回验证图片
        //单次错误:
        //{"errno":0,"request_id":1722760965,"sekey":"KmZ2aFNZ6k32fkCw_QvxCuiBWfvoJiSbzkh4laMKXNM%7E"}
        //连续错误
        //{"errno":-62,"request_id":1727391373}
        //获取验证图片方法：
        //get http://pan.baidu.com/share/captchaip
        //返回：{"errno":0,"err_msg":"","request_id":1768754082,"captcha":"http:\/\/vcode.baidu.com\/genimage?0013951519140166730A2C0A02A7F2F5C6F085C9C331BB7F61A95A8E94FE6DC495AB3C4DB4EE58671C52A6F97845737E7AC6B161AE4C3866ECAF462C5682ED93B2AD5D82DBEE9560AD47C5D18878C2513168F9C19C0D109B76CC062041FB5F303517F8C550EEB12D8074AB0223A4CD815225FF1DC6CE7295BE62AB644A5A4D1946949047F505A8FF4C5AC6AE3CB7C4B9252927039651D552EFB3866786606B6DD941C717A778DC0DF43B66A777E3AF5CE51493BF0C202388"}
        //然后再get   http:\/\/vcode.baidu.com\/genimage?0013951519140166730A2C0A02A7F2F5C6F085C9C331BB7F61A95A8E94FE6DC495AB3C4DB4EE58671C52A6F97845737E7AC6B161AE4C3866ECAF462C5682ED93B2AD5D82DBEE9560AD47C5D18878C2513168F9C19C0D109B76CC062041FB5F303517F8C550EEB12D8074AB0223A4CD815225FF1DC6CE7295BE62AB644A5A4D1946949047F505A8FF4C5AC6AE3CB7C4B9252927039651D552EFB3866786606B6DD941C717A778DC0DF43B66A777E3AF5CE51493BF0C202388
        //因为一般是从发布网页直接抓取提取码 应该不会有问题 所以暂时这边先放着


    }else if (request.tag == kSaveFileRequest){
        NSData *responseData = [request responseData];
        NSError *error = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"response dict %@",responseDict);
        if (!error) {
            int errnoNum = [[responseDict valueForKey:@"errno"]intValue];
            switch (errnoNum) {
                case 0:
                {
                    NSLog(@"save success");
                    [self handleError:@"save success"];
                    break;
                }
                case 12:
                {
                    NSLog(@"file exists already");
                    [self handleError:@"file exists already"];
                    break;
                }
                case 2:
                    NSLog(@"file not exists");
                    [self handleError:@"file not exists"];
                    break;
                case -6:
                    NSLog(@"you haven't login");
                    [self handleError:@"you haven't login"];
                    break;
                default:
                    NSLog(@"unknown error");
                    [self handleError:@"uknown error"];
                    break;
            }

        }
        
    }
}





-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response//重定向检查 如果没有返回init页面 表示成功
{
#ifdef MSDEBUG
    NSLog(@"==============");
    NSLog(@"will send request\n%@",[request URL]);
    NSLog(@"redirect response\n%@",[response URL]);
#endif
    if (response == nil) {
        NSLog(@"go to file page");
    }
    return request;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.filePageData = [NSMutableData data];
#ifdef MSDEBUG
    NSLog(@"=====didReceiveResponse=========%@",[response URL]);
#endif
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.filePageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    __block NSString *fileName;
    __block NSString *bdstoken;
    
    __weak BaiduPanPanel *weakSelf = self;
#ifdef MSDEBUG
    NSLog(@"=====download is finished,parser begins=============");
    if (!self.filePageData) {
        NSLog(@"no data");
    }
#endif
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(aQueue, ^(void){
        fileName = [[HTMLParseHelp basicTextParseFromData:self.filePageData withXpath:@"//*[@id='fileName']/@data-fn" options:MSHTMLParseDefault alterItem:nil]objectAtIndex:0];
        if ([fileName length]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize maximumSize = CGSizeMake(220, MAXFLOAT);
                CGSize expectedSize = [fileName sizeWithFont:font
                                           constrainedToSize:maximumSize
                                               lineBreakMode:NSLineBreakByWordWrapping];
                CGRect newFrame ;
                newFrame.origin = weakSelf.fileNameTF.frame.origin;
                newFrame.size = expectedSize;
                weakSelf.fileNameTF.frame = newFrame;
                [weakSelf.fileNameTF setLineBreakMode:NSLineBreakByWordWrapping];
                [weakSelf.fileNameTF setNumberOfLines:0];
                weakSelf.fileNameTF.text = fileName;
            });

        }
        
#ifdef MSDEBUG
        NSLog(@"=====weakSelf.fileNameTF.text ==%@",fileName);
#endif
    });
    
    dispatch_async(aQueue, ^(void){
        NSString *raw = [[NSString alloc]initWithData:self.filePageData encoding:NSUTF8StringEncoding];
#ifdef MSDEBUG
        NSLog(@"=====raw string is====%@",raw);
        NSLog(@"path is %d,root is %d",[raw rangeOfString:@"\\\"path\\\""].location,[raw rangeOfString:@",\\\"root_ns"].location);
#endif
//        NSString *tmp = [raw substringFromHeader:@"\\\"path\\\":" toTail:@",\\\"root_ns"];
//        filePath = [tmp substringFromIndex:[@"\\\"path\\\":" length]];
//        NSLog(@"file path %@",filePath);
        
        NSRange targetRange = [raw rangeOfString:@"mpan.viewsingle_param.list=JSON.parse(.+);mpan.viewsingle_param.username" options:NSRegularExpressionSearch];
        NSLog(@"targetRange location is %d,length is %d",targetRange.location,targetRange.length);
        if (targetRange.location != NSNotFound) {
            NSRange jsonRange;
            jsonRange.location = targetRange.location + [@"mpan.viewsingle_param.list=JSON.parse(\"" length];
            jsonRange.length = targetRange.length - [@"mpan.viewsingle_param.list=JSON.parse(\"" length] - [@"\");mpan.viewsingle_param.username" length];
            NSString *jsonString = [raw substringWithRange:jsonRange];
#ifdef MSDEBUG
            NSLog(@"json string is %@",jsonString);
#endif            
// delete escape character'\'
            NSMutableString *noESCString = [NSMutableString stringWithString:jsonString];
            NSString *character = nil;
            for (int i = 0; i < noESCString.length; i ++) {
                character = [noESCString substringWithRange:NSMakeRange(i, 1)];
                if ([character isEqualToString:@"\\"])
                    [noESCString deleteCharactersInRange:NSMakeRange(i, 1)];
            }
            NSError *error= nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[noESCString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] options:NSJSONReadingMutableContainers error:&error];
            NSString *filepath = [[jsonArray objectAtIndex:0] objectForKey:@"path"];
            
            weakSelf.filePath = [NSString stringWithFormat:@"[\"%@\"]",filepath];
#ifdef MSDEBUG
            
            NSLog(@"=====eakSelf.filePath is====%@",weakSelf.filePath);
#endif

        }else
            [weakSelf handleError:@"failed to get file info"];
        
    });

    
    dispatch_async(aQueue, ^(void){
        NSString *raw = [[NSString alloc]initWithData:self.filePageData encoding:NSUTF8StringEncoding];

        NSString *tmp = [raw substringFromHeader:@"FileUtils.bdstoken=\"" toTail:@"\";FileUtils.mobileModel"];
        bdstoken = [tmp substringFromIndex:[@"FileUtils.bdstoken=\"" length]];
        weakSelf.bdstoken = bdstoken;
#ifdef MSDEBUG
        NSLog(@"=====weakSelf.bdstoken is====%@",weakSelf.bdstoken);
#endif
        if ([weakSelf.bdstoken isEqualToString:@"null"]) {
            NSLog(@"您尚未登陆百度");
        }
    });
    

}


// -------------------------------------------------------------------------------
//	method name
// -------------------------------------------------------------------------------
-(void)handleError:(NSString *)errorInfo
{
    UIAlertView *alertView =
    [[UIAlertView alloc]initWithTitle:@"通知" message:errorInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alertView.tag = 100;
    [alertView show];
}
//---------------------------------------------------------
//     alertView:didDismissWithButtonIndex:
//---------------------------------------------------------
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    
}

-(void)didPresentAlertView:(UIAlertView *)alertView
{
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:alertView selector:@selector(dismissAnimated:) userInfo:nil repeats:NO];
}


@end




 









//////////////////////////////////
//wap页面解析获取bdtoken
// FileUtils.bdstoken="a73de05d63203570c8c2b96336ff1b03"
//POST /share/transfer?from=1093492205&shareid=2863655745&bdstoken=a73de05d63203570c8c2b96336ff1b03&channel=chunlei&clienttype=5&web=1
//即可完成转存功能
//post data
//path=%2F&filelist=%5B%22%2F002-Ebooks%2FiOS%2FLearn+iOS+7+App+Development.pdf%22%5D&async=1&r=0.6511591490898647
//\"path\":\"\\/002-Ebooks\\/iOS\\/Learn iOS 7 App Development.pdf\",\"root_ns\":
//["/002-Ebooks/iOS/Learn iOS 7 App Development.pdf"]


//成功 HTTP/1.1 200 OK
//成功内容  {"errno":0,"task_id":0,"info":[{"path":"\/002-Ebooks\/iOS\/Learn iOS 7 App Development.pdf","errno":0}]}
//已存在 {"errno":12,"task_id":0,"info":[{"path":"\/002-Ebooks\/iOS\/Learn iOS 7 App Development.pdf","errno":-30}]}
//未登陆 {"errno":-6,"request_id":4051429016}
//不存在 {"errno":2,"request_id":247265074}
//FileUtils.bdstoken="null" 表示还没登陆





//登陆
//bdcm <input type="hidden" name="bdcm" value="a596ff997bcb0a46811fbe096b63f6246b60af7d"/>
//引用页   http://wappass.baidu.com/passport?login&authsite=1&tpl=netdisk&display=mobile&u=http%3A%2F%2Fpan.baidu.com%2Fwap%2Flink%3Fshareid%3D2863655745%26uk%3D1093492205%26uid%3D1395156119439_187%26ssid%3Dda52e1eb7777fb94121e9ec66adbbb83.3.1395156129.1.jk9fkAhbVV4W
//username=chyy.meng%40163.com&passwodr=xxxxx&submit=%E7%99%BB%E5%BD%95&quick_user=0&isphone=0&sp_login=waprate&uname_login=&loginmerge=1&vcodestr=&u=http%253A%252F%252Fpan.baidu.com%252Fwap%252Flink%253Fshareid%253D2863655745%2526uk%253D1093492205%2526uid%253D1395156393376_456%2526ssid%253Dda52e1eb7777fb94121e9ec66adbbb83.3.1395156129.1.jk9fkAhbVV4W&skin=default_v2&tpl=netdisk&ssid=&from=&uid=1395156393376_456&pu=&tn=&bdcm=a596ff997bcb0a46811fbe096b63f6246b60af7d&type=&bd_page_type=

