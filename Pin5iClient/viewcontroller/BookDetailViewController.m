//
//  BookDetailViewController.m
//  Pin5i-Client
//
//  Created by mamong on 14-3-17.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

// 提取密码  //*[@id='downloadinfo']/span/text()    sdfg
// 下载地址 href //*[@id='downloadinfo']/a/@href    href="attachment.aspx?eolink=7EF43148680DF9E54A
//
//.//*[@class='t_attach']/text()
//
//
//




#import "BookDetailViewController.h"
#import "HTMLParseHelp.h"
#import "NSString+MSExtend.h"
#import "CoverDownloader.h"
#import "LoginViewController.h"
#import "PPRevealSideViewController.h"
#import "MSIndicatorModal.h"

#define kCoverViewHeight     150
#define kCoverViewWidth      110
#define kIndicatorTag        100
#define kRequestTimeoutInterval 8.0
#define kShowIndicatorDelayInterval 0.5

static int lastIndex = -1;
static float _offset = 150;
static BOOL _animated = YES;

@interface BookDetailViewController ()<NSURLConnectionDataDelegate, UIScrollViewDelegate,
                                         SwipeViewDataSource, SwipeViewDelegate,
                                        UIGestureRecognizerDelegate>{

// for UIWebView Scroll and drag gesture
    UIScrollView *webScrollView;
    CGFloat contentOffsetY;
    CGFloat oldContentOffsetY;
    CGFloat newContentOffsetY;
// 控制tabbar的显示与隐藏标志
    BOOL flag;
    MSIndicatorModal *indicatorModal;
// state
    BOOL isLoading;
}
@property (nonatomic, strong) NSMutableDictionary *panlinkDict;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@end

@implementation BookDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _ebookDetail = [[EBookDetailItem alloc]init];
        _ebookDetail.coverArray = [NSMutableArray array];
        _ebookDetail.coverDownloadSizeArray = [NSMutableArray array];
        _panlinkDict = [NSMutableDictionary dictionaryWithCapacity:1];
        isLoading = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *rightRefreshButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDetailPage)];
    self.navigationItem.rightBarButtonItem = rightRefreshButtonItem;
    [self hookWebViewScrollView];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    //configure swipe view
    _swipeView.alignment = SwipeViewAlignmentCenter;
    _swipeView.pagingEnabled = YES;
    _swipeView.wrapEnabled = NO;
    _swipeView.itemsPerPage = 1;
    _swipeView.truncateFinalPage = YES;
    
    //configure page control
    _pageControl.numberOfPages = _swipeView.numberOfPages;
    _pageControl.defersCurrentPageDisplay = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    // for reuse, current page's title should be reset every time
    // it appears.
    self.title = self.ebookDetail.title;
    
    // if the hexbutton is nil,we should get one and add to our view.
    if (!_myButton) {
        [self addCustomElements];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    // when current VC's view appears,we should load the page's data,and show the network
    // indicator.
    NSString *pageURL = [NSString stringWithFormat:@"http://www.pin5i.com%@",self.ebookDetail.ebookURL];
    NSLog(@"webview is loading %@",pageURL);

    [self startDownLoadDetailPage];
}


- (void)viewWillDisappear:(BOOL)animated
{
    // when current VC is going to disapppear,we should reset some source for reuse.
    [_ebookDetail.coverArray removeAllObjects];
    [self.panlinkDict removeAllObjects];
    [self.imageDownloadsInProgress removeAllObjects];
    
    // hide the network indicator and the loading indicator
    isLoading = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self removeLoadingIndicator];

    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.5 animations:^(){
        weakself.baiduPanel.view.center = CGPointMake(weakself.baiduPanel.view.frame.size.width/2, weakself.view.bounds.size.height+weakself.baiduPanel.view.frame.size.height/2);
    }];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [self.baiduPanel.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView removeFromSuperview];
    self.webView = nil;
}

- (void)refreshDetailPage
{

    [self.ebookDetail.coverArray removeAllObjects];
    [self.ebookDetail.coverDownloadSizeArray removeAllObjects];
    [self.panlinkDict removeAllObjects];
// fix the selected index bug when refresh
    _pageControl.currentPage = 0;
    [self startDownLoadDetailPage];
}


- (void)startDownLoadDetailPage
{
    isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

// delay
    [self performSelector:@selector(showLoadingIndicator) withObject:nil afterDelay:kShowIndicatorDelayInterval];
    
    __block NSArray *eolinkArray;
    __block NSArray *extractCodeArray;
    __block NSArray *coverArray;
    __block NSArray *sizeArray;
    __block NSMutableString *description;
    __weak BookDetailViewController *weakSelf = self;
    
    NSString *encodeURL = [self.ebookDetail.ebookURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeURL]cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:kRequestTimeoutInterval];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        isLoading = NO;
        if (data) {
            
// start to parse the html data
            dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_group_t aGroup = dispatch_group_create();
            dispatch_group_async(aGroup, aQueue, ^{
                eolinkArray = [HTMLParseHelp basicTextParseFromData:data withXpath:@"//*[@id='downloadinfo']/a/@href" options:MSHTMLParseDefault alterItem:nil];
                weakSelf.ebookDetail.eoLinkArray = eolinkArray;
            });
            dispatch_group_async(aGroup, aQueue, ^{
                extractCodeArray = [HTMLParseHelp basicTextParseFromData:data withXpath:@"//*[@id='downloadinfo']/span/text()" options:MSHTMLParseDefault alterItem:nil];
                weakSelf.ebookDetail.extractCodeArray = extractCodeArray;
#ifdef MSDEBUG
                NSLog(@"extract array is %@",[extractCodeArray description]);
#endif
            });
            dispatch_group_async(aGroup, aQueue, ^{
                coverArray = [HTMLParseHelp basicTextParseFromData:data withXpath:@"//*[@class='t_attach']/a/@href" options:MSHTMLParseDefault alterItem:nil];
                weakSelf.ebookDetail.coverURLArray = coverArray;
                
            });
            
            dispatch_group_async(aGroup, aQueue, ^{
                sizeArray = [HTMLParseHelp basicTextParseFromData:data withXpath:@"//*[@class='t_attach']/text()" options:MSHTMLParseDefault alterItem:^NSString *(NSString *item) {
                    NSLog(@"item is %@",item);
                    if ([item length]>3) {
                        return [item substringWithRange:NSMakeRange(1, [item length]-3)];//skip (__k)
                    }else
                        return item;
                }];
                weakSelf.ebookDetail.coverURLArray = coverArray;
                
            });
            
            dispatch_group_async(aGroup, aQueue, ^{
                NSString *raw = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                
                NSString *target = [raw substringFromHeader:@"<!-- google_ad_section_start -->" toTail:@"<!-- google_ad_section_end -->"];
                description = [NSMutableString stringWithString:target];
                [description replaceOccurrencesOfString:@"<img src=\"/attachment.*(</div>){2}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [target length])];
                description =[NSMutableString stringWithFormat:@"<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><script type=\"text/javascript\" src=\"/javascript/common.js\"></script><script type=\"text/javascript\" src=\"javascript/showtopic.js\"></script></head><body><div>\n%@</div></body></html>",description];
#ifdef MSDEBUG
                NSLog(@"description is %@",description);
#endif
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.webView loadHTMLString:description baseURL:[NSURL URLWithString:@"http://www.pin5i.com"]];
                });
            });
            
            dispatch_group_wait(aGroup, DISPATCH_TIME_FOREVER);
            if ([weakSelf.ebookDetail.coverURLArray count]) {
                dispatch_apply([weakSelf.ebookDetail.coverURLArray count], aQueue, ^(size_t i) {
                    [weakSelf.ebookDetail.coverArray addObject:[NSNull null]];
                    [weakSelf.ebookDetail.coverDownloadSizeArray addObject:[NSNull null]];
                });
            }
            
            if ([weakSelf.ebookDetail.eoLinkArray count]) {
                
                dispatch_apply([weakSelf.ebookDetail.eoLinkArray count], aQueue, ^(size_t i) {
                    [weakSelf.panlinkDict setObject:[NSNull null] forKey:[NSString stringWithFormat:@"%zd",i]];
                    
                });
            }
            weakSelf.ebookDetail.extractCodeArray = extractCodeArray;
            weakSelf.ebookDetail.descriptions = description;
            weakSelf.ebookDetail.coverURLArray = coverArray;
            weakSelf.ebookDetail.coverSizeArray = sizeArray;
            weakSelf.ebookDetail.eoLinkArray = eolinkArray;
            

            dispatch_async(dispatch_get_main_queue(), ^{
               [weakSelf.swipeView reloadData];
            });
            
#ifdef MSDEBUG
            NSLog(@"weakSelf.ebookDetail.extractCodeArray is %@",[weakSelf.ebookDetail.extractCodeArray description]);
#endif
            // if data is available, set the indicator label text "success"
            [indicatorModal.titleLabel setTextColor:[UIColor yellowColor]];
            [indicatorModal.titleLabel setText:@"Success!"];
        }else{
            NSLog(@"error is %@",[error description]);
            [indicatorModal.titleLabel setTextColor:[UIColor yellowColor]];
            [indicatorModal.titleLabel setText:@"Failure!"];
        }
    
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
# warning there exists a bug
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf removeLoadingIndicator];
        });
        
    }];
}


#pragma mark -
#pragma mark hook webview and detect scrolling derection

- (void)hookWebViewScrollView
{
    for (id subview in self.webView.subviews){
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])  {
            UIScrollView * s = (UIScrollView*)subview;
            s.delegate = self;
            webScrollView = s;
        }
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView

{
    contentOffsetY = scrollView.contentOffset.y;
}


// 滚动时调用此方法(手指离开屏幕后)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView

{
    newContentOffsetY = scrollView.contentOffset.y;
    if (newContentOffsetY > oldContentOffsetY && oldContentOffsetY > contentOffsetY) {  // 向上滚动
        
        NSLog(@"up");
    } else if (newContentOffsetY < oldContentOffsetY && oldContentOffsetY < contentOffsetY) { // 向下滚动
        NSLog(@"down");
    } else {
        NSLog(@"dragging");
    }
    
    if (scrollView.dragging) {  // 拖拽
        
        NSLog(@"scrollView.dragging");
        
        NSLog(@"contentOffsetY: %f", contentOffsetY);
        
        NSLog(@"newContentOffsetY: %f", scrollView.contentOffset.y);
        
        if ((scrollView.contentOffset.y - contentOffsetY) > 5.0f) {  // 向上拖拽
            [self.navigationController setNavigationBarHidden:YES animated:YES];
          
        } else if ((contentOffsetY - scrollView.contentOffset.y) > 5.0f) {   // 向下拖拽
            [self.navigationController setNavigationBarHidden:NO animated:YES];
           
        } else {
            
        }
    }
}

// 完成拖拽(滚动停止时调用此方法，手指离开屏幕前)

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    oldContentOffsetY = scrollView.contentOffset.y;
}



#pragma mark - 
#pragma mark UIWebViewDelegate Methods
// -------------------------------------------------------------------------------
//	method name
// -------------------------------------------------------------------------------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        if ([self.self.ebookDetail.extractCodeArray count]) {
            NSRange target;
            NSString *url = [[request URL]absoluteString];
            target = [url rangeOfString:@"http://www.pin5i.com/showtopic"];
            //////////////////////////////////////////////////
            // bug 汇报：
            /*
             条件：帖子内有修复的下砸地址，本方法会识别出该网址进行加载：
             http://www.pin5i.com/showtopic.aspx?page=end&forumpage=1&topicid=39732#210051
             
             但是本网址非帖子地址，不符合合法请求条件，因为我们不对回帖进行分析。
             处理意见：彻底封锁非法请求或者处理该请求，后者有更好的体验，前者比较简单。
             */
            //////////////////////////////////////////////////
#ifdef MSDEBUG
            NSLog(@"[[request URL]absoluteString] is %@",[[request URL]absoluteString]);
#endif
            if (target.location != NSNotFound) {
                self.ebookDetail.ebookURL = url;
                [self startDownLoadDetailPage];
                return NO;
            }
            
            target = [url rangeOfString:@"attachment.aspx?eolink="];
            if (target.location != NSNotFound) {
                self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
                return NO;
            }
            return YES;
        }
     
    }
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
}
// -------------------------------------------------------------------------------
//	method name
// -------------------------------------------------------------------------------











#pragma mark -
#pragma mark NSURLConnectionData Delegate Methods
// -------------------------------------------------------------------------------
//	method name
// -------------------------------------------------------------------------------
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
#ifdef MSDEBUG
    NSLog(@"==============");
    NSLog(@"will send request\n%@",[request URL]);
    NSLog(@"redirect response\n%@",[response URL]);
#endif
    if ([self.self.ebookDetail.extractCodeArray count]) {
        int clickIndex = 0;
        NSString *url = [[request URL]absoluteString];
        NSRange range1 = [url rangeOfString:@"attachment.aspx?eolink="];
        if ((range1.location != NSNotFound)&&[self.self.ebookDetail.extractCodeArray count]) {
            for (int i = 0; i<[self.ebookDetail.eoLinkArray count]; i++) {
                NSString *requestEolink = [[url componentsSeparatedByString:@"eolink="]objectAtIndex:1];
                NSString *compareEolink = [[[self.ebookDetail.eoLinkArray objectAtIndex:i]
                                            componentsSeparatedByString:@"eolink="]objectAtIndex:1];
                
                if ([requestEolink isEqualToString:compareEolink]) {
                    clickIndex = i;
                    if (!self.baiduPanel) {
                        [[NSBundle mainBundle]loadNibNamed:@"BaiduPanPanel" owner:self options:nil];
                        
                        self.baiduPanel.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BaiduPanPanel"]];
                        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGetureToCloseBaiduPanel:)];
                        [self.baiduPanel.view addGestureRecognizer:tapgesture];
                    }
                    self.baiduPanel.view.center = CGPointMake(self.baiduPanel.view.frame.size.width/2, self.view.bounds.size.height+self.baiduPanel.view.frame.size.height/2);
                    [self.view addSubview:self.baiduPanel.view];
                    self.baiduPanel.extractCode = [self.ebookDetail.extractCodeArray objectAtIndex:i];
                }
                
            }
        }
        
        // if there are two eolink,click some link several times,will redirect once,
        // so baidupan panel only has one chance to set its content.if click another link
        // the content will reset by this link.so it won't cause any confusion.
        // fix the problem,redirect to pan.baidu.com/wap/ only once,so panel only show once
        NSRange target = [url rangeOfString:@"http://pan.baidu.com/wap/"];
        if (target.location != NSNotFound) {
            [connection cancel];
            lastIndex = clickIndex;
            [self.panlinkDict setObject:[[request URL]absoluteString] forKey:[NSString stringWithFormat:@"%d",clickIndex]];
#ifdef MSDEBUG
            NSLog(@"self.baiduPanel.extractCode is %@",self.baiduPanel.extractCode);
#endif
        }
        
        id panlink = [self.panlinkDict objectForKey:[NSString stringWithFormat:@"%d",clickIndex]];
        if (lastIndex == clickIndex&&[panlink isKindOfClass:[NSString class]]&&!self.baiduPanel.isExtracting) {
            [[self.baiduPanel extractCodeTF] setText:self.baiduPanel.extractCode];
            self.baiduPanel.panlink = panlink;
            __weak typeof(self) weakself = self;
            [UIView animateWithDuration:2 animations:^(){
                
                weakself.baiduPanel.view.center = CGPointMake(self.baiduPanel.view.frame.size.width/2, weakself.view.bounds.size.height-weakself.baiduPanel.view.frame.size.height/2);
            }];
            [self.baiduPanel startToExtractFile];
        }

    }
    
    return request;
}


#pragma mark -
#pragma mark SwipeViewDataSource Methods
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    _pageControl.numberOfPages = [self.ebookDetail.coverArray count]?[self.ebookDetail.coverArray count]:1;
    return [self.ebookDetail.coverArray count]?[self.ebookDetail.coverArray count]:1;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (!view)
    {
    	//load new item view instance from nib
        //control events are bound to view controller in nib file
        //note that it is only safe to use the reusingView if we return the same nib for each
        //item view, if different items have different contents, ignore the reusingView value
    	view = [[[NSBundle mainBundle] loadNibNamed:@"ItemView" owner:self options:nil] lastObject];

        UIImageView  *imageView = (UIImageView  *)[view viewWithTag:100];
        if(![self.ebookDetail.coverArray count]) {
            [imageView setImage:[UIImage imageNamed:@"cover"]];}
         else  {
              if ([[self.ebookDetail.coverArray objectAtIndex:index]isKindOfClass:[NSNull class]]) {
                  [imageView setImage:[UIImage imageNamed:@"cover"]];
                  [self startCoverDownload:self.ebookDetail forIndex:(int)index];
                        NSLog(@"start cover");
              }else if([[self.ebookDetail.coverArray objectAtIndex:index]isKindOfClass:[NSString class]]){
                  [imageView setImage:[UIImage imageNamed:@"outoftime"]];
              }
              else{
                   [imageView setImage:[self.ebookDetail.coverArray objectAtIndex:index]];
               }
         }
    }
    return view;
}

#pragma mark -
#pragma mark SwipeViewDelegate Methods
- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    //update page control page
    _pageControl.currentPage = swipeView.currentPage;
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    if ([self.ebookDetail.coverArray count]) {
        if ([[self.ebookDetail.coverArray objectAtIndex:index]isKindOfClass:[NSNull class]]||
            [[self.ebookDetail.coverArray objectAtIndex:index]isKindOfClass:[NSString class]]||
            [[self.ebookDetail.coverSizeArray objectAtIndex:index] evaluateWithSize:[self.ebookDetail.coverDownloadSizeArray objectAtIndex:index]]) {

            [self startCoverDownload:self.ebookDetail forIndex:(int)index];
        }else
            NSLog(@"enlarge");
    }
}



- (IBAction)pageControlTapped
{
    //update swipe view page
    [_swipeView scrollToPage:_pageControl.currentPage duration:0.4];
}



// -------------------------------------------------------------------------------
//	startCoverDownload:forIndex
// -------------------------------------------------------------------------------
- (void)startCoverDownload:(EBookDetailItem *)item forIndex:(int)index
{ 
    CoverDownloader *coverDownloader = [self.imageDownloadsInProgress objectForKey:[NSNumber numberWithInt:index]];
    if (coverDownloader == nil)
    {   NSLog(@"down pic");
        coverDownloader = [[CoverDownloader alloc] init];
        coverDownloader.ebookDetail = item;
        [coverDownloader setCompletionHandler:^{
            
            UIView *view = (UIView *)[self.swipeView itemViewAtIndex:index];
            
            // Display the newly loaded image
            UIImageView *itemView = ( UIImageView *)[view viewWithTag:100];
            id picOrNot = [item.coverArray objectAtIndex:index];
            if ([picOrNot isKindOfClass:[NSString class]]) {
                itemView.image = [UIImage imageNamed:@"outoftime"];
            }else
                itemView.image =picOrNot;

            
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:[NSNumber numberWithInt:index]];
            
        }];
        [self.imageDownloadsInProgress setObject:coverDownloader forKey:[NSNumber numberWithInt:index]];
        [coverDownloader startDownloadWithIndex:index];
    }
}



- (void)tapGetureToCloseBaiduPanel:(UIPanGestureRecognizer *)pangesture
{
    [UIView animateWithDuration:1 animations:^(){
        self.baiduPanel.view.center = CGPointMake(self.baiduPanel.view.frame.size.width/2, self.view.bounds.size.height+self.baiduPanel.view.frame.size.height/2);
    }];
}


- (IBAction)showUp:(id)sender {
    LoginViewController *c = [[LoginViewController alloc] init];
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
    [self.revealSideViewController pushViewController:n onDirection:PPRevealSideDirectionTop withOffset:_offset animated:_animated];
    
}


-(void)goBack:(id)sender
{
    if (_webView.canGoBack)
        [_webView goBack];
    else
        [self refreshDetailPage];
}

- (void)goForward:(id)sender
{
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}

#pragma mark -
#pragma mark HEXCMyUIButton methods
// -------------------------------------------------------------------------------
//	method name
// -------------------------------------------------------------------------------

//做了修改 设置tab bar
- (void)addCustomElements
{
    _myButton = [HEXCMyUIButton buttonWithType:UIButtonTypeCustom];
    _myButton.MoveEnable = YES;
    _myButton.frame = CGRectMake(280, 300, 40, 40);
    
    //TabBar上按键图标设置
    [_myButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"40.png"]] forState:UIControlStateNormal];
    [_myButton setTag:10];
    flag = NO;//控制tabbar的显示与隐藏标志 NO为隐藏
    
    [_myButton addTarget:self action:@selector(tabbarbtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:_myButton];
    
    [self _initTabBar];
}

//初始化tabbar
-(void)_initTabBar
{
    //tab bar view  始终居中显示
    _tabBarView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-100, 200 , 200)] ;
    
    //view 设置半透明 圆角样式
    _tabBarView.layer.cornerRadius = 10;//设置圆角的大小
    _tabBarView.layer.backgroundColor = [[UIColor blackColor] CGColor];
    _tabBarView.alpha = 0.8f;//设置透明
    _tabBarView.layer.masksToBounds = YES;
    
    [self.view addSubview:_tabBarView];
    
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
    
    [_tabBarView setHidden:YES];
}

//显示 隐藏tabbar
- (void)tabbarbtn:(HEXCMyUIButton*)btn
{
    //在移动的时候不触发点击事件
    if (!btn.MoveEnabled) {
        if(!flag){
            _tabBarView.hidden = NO;
            flag = YES;
        }else{
            _tabBarView.hidden = YES;
            flag = NO;
        }
    }
    
}

- (void)buttonClicked:(id)sender
{
    NSLog(@"%ld",[sender tag]);
    UIButton *button = sender;
    NSInteger index = button.tag;
    switch (index) {
        case 0:
        {
            [self downloadCurrentFile];
            break;
        }
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        default:
            break;
    }
    
}

#pragma mark HEXCMyUIButton tasks for each button
- (void)downloadCurrentFile
{
    
}

#pragma mark indicator
// -------------------------------------------------------------------------------
//	show loading indicator
// -------------------------------------------------------------------------------
- (void)showLoadingIndicator
{
    if (isLoading) {
        // generate a dynamic style for indicator view
        RTSpinKitViewStyle dynamicRTSpinKitViewStyle = (RTSpinKitViewStyle)(arc4random()%5);
        
        //// set the panel to add indicator view
        CGRect screenBounds = [[UIScreen mainScreen] bounds];

        if (!indicatorModal) {
            indicatorModal = [[MSIndicatorModal alloc]initWithFrame:screenBounds];
        }
        indicatorModal.tag = kIndicatorTag;
        CGFloat fixY = self.navigationController.navigationBar.translucent?0:44;
        indicatorModal.center = CGPointMake(CGRectGetMidX(screenBounds), CGRectGetMidY(screenBounds)-fixY);
        indicatorModal.spinKitViewStyle = dynamicRTSpinKitViewStyle;
        indicatorModal.marginLS = 20.0;
        indicatorModal.shouldBounce = YES;
        
       
        [indicatorModal.spinKitView setColor:[UIColor greenColor]];
        
  
        [indicatorModal.titleLabel setText:@"Loading..."];
        [indicatorModal.titleLabel setTextColor:[UIColor colorWithRed:0.102 green:0.337 blue:0.912 alpha:1.0]];
        
        // add the panel with indicator view to the current viewcontroller's view
        [self.view addSubview:indicatorModal];
        [indicatorModal show];

    }
}


- (void)removeLoadingIndicator
{
    
    if (indicatorModal != nil) {
        [indicatorModal hide];
    }
}


@end

