//
//  BookListViewController.m
//  Pin5i-Client
//
//  Created by mamong on 14-3-15.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "BookListViewController.h"
#import "BookDetailViewController.h"
#import "HTMLParseHelp.h"
#import "EbookListItem.h"
#import "AvatarDownloader.h"
#import "NSString+MSExtend.h"
#import "MJRefresh.h"



#define kCustomRowCount          9
#define kRequestTimeoutInterval 8.0
#define kWidthForCellTextLabel 260

@interface BookListViewController ()<UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate, UIScrollViewDelegate, MJRefreshBaseViewDelegate>{
    

    BookDetailViewController *bookDetailVC;
    
// MJRefresh footer view and header view
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    BOOL isRefresh;                // to distinguish refresh and download more
    
}

@property (nonatomic, strong)IBOutlet UITableView *ebookListTab;
@property (nonatomic, strong) NSString *eBookListURL;
@property (nonatomic, assign) int totalPageNum;
@property (nonatomic, assign) int requestPageIndex;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
// the set of IconDownloader objects for each app
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation BookListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentPage = 0;
        _totalPageNum = 0;
        _ebookList = [NSMutableArray array];
        isRefresh = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 下拉刷新
    _header = [[MJRefreshHeaderView alloc] init];
    _header.delegate = self;
    _header.scrollView = self.ebookListTab;
    
    // 上拉加载更多
    _footer = [[MJRefreshFooterView alloc] init];
    _footer.delegate = self;
    _footer.scrollView = self.ebookListTab;

    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.navigationController.navigationBar setTranslucent:NO];
}


- (void)dealloc
{
    // 释放资源
    [_footer free];
    [_header free];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self setTitle:self.columnName];
    if (self.needLoad) {
        _currentPage = 0;
        _totalPageNum = 0;
        _requestPageIndex = 0;
        _data = nil;
        [_ebookList removeAllObjects];
        [self.ebookListTab reloadData];
        [self startDownloadWithColumn:self.column page:1];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
   
}


- (void)viewWillDisappear:(BOOL)animated
{
//    if (self.needLoad) {
//        _currentPage = 0;
//        _totalPageNum = 0;
//        _requestPageIndex = 0;
//        [_ebookList removeAllObjects];
//    }
    _data = nil;
    [_connection cancel];
    [self setHidesBottomBarWhenPushed:NO];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self resetMJRefreshView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}


- (void)startDownloadWithColumn:(NSString *)url page:(int)pageNum
{
#ifdef MSDEBUG
    NSLog(@"=====download  begins=============");
#endif
    self.eBookListURL = [NSString stringWithFormat:@"http://www.pin5i.com/%@/%d/",url,pageNum];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
                                [NSURL URLWithString:self.eBookListURL]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kRequestTimeoutInterval];

    self.connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    if (self.connection) {
        self.data = [NSMutableData data];
        self.requestPageIndex = pageNum;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


-(void)handleError:(NSString *)errorInfo
{
    UIAlertView *alertView =
    [[UIAlertView alloc]initWithTitle:@"错误！" message:errorInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alertView.tag = 100;
    [alertView show];
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:@"您还没登陆！"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark NSURLConnectionData Delegate Methods
// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    [self handleError:@"下载失败"];
    [self performSelector:@selector(resetMJRefreshView) withObject:nil afterDelay:1];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
        __block NSMutableArray *list = [NSMutableArray array];
        __block NSArray *titleArray;
        __block NSArray *linkArray;
        __block NSArray *authorArray;
        __block NSArray *authorURLrray;
        __block NSArray *dateArray;
        __block NSArray *pages;
        __weak BookListViewController *weakSelf = self;
#ifdef MSDEBUG
            NSLog(@"=====download is finished,parser begins=============");
#endif
            dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            if (weakSelf.totalPageNum==0) {

                 dispatch_sync(aQueue, ^(void){
                    pages = [HTMLParseHelp basicTextParseFromData:self.data withXpath:@"//*[@id='footfilter']/div/a/@href" options:MSHTMLParseDefault alterItem:nil];
                    NSString *lastPageNum = [pages objectAtIndex:[pages count]-2];
                    NSArray *component = [lastPageNum componentsSeparatedByString:@"/"];
                    weakSelf.totalPageNum = [[component objectAtIndex:[component count]-2]intValue];                        if (weakSelf.totalPageNum == 0){
                            if([weakSelf.column isEqualToString:@"vip-ebooks"]){
                                [weakSelf handleError:@"您还没登陆！"];
                            }else
                                [weakSelf handleError:@"下载错误"];
                        }
#ifdef MSDEBUG
             NSLog(@"=========pageNum parse finished===================");
#endif
                 });
            }

            if (self.requestPageIndex <= weakSelf.totalPageNum) {

                dispatch_group_t aGroup = dispatch_group_create();
                dispatch_group_async(aGroup, aQueue, ^{
                    titleArray = [HTMLParseHelp basicTextParseFromData:self.data withXpath:@"//*[@id='threadlist']/tbody/tr/th/a" options:MSHTMLParseJointAll alterItem:nil];
                });
                dispatch_group_async(aGroup, aQueue, ^{
                    linkArray = [HTMLParseHelp basicTextParseFromData:self.data withXpath:@"//*[@id='threadlist']/tbody/tr/th/a/@href" options:MSHTMLParseDefault alterItem:nil];
                });
                dispatch_group_async(aGroup, aQueue, ^{
                    authorArray = [HTMLParseHelp basicTextParseFromData:self.data withXpath:@"//*[@id='threadlist']/tbody/tr/td[3]/cite/a/text()" options:MSHTMLParseDefault alterItem:nil];
                });
                dispatch_group_async(aGroup, aQueue, ^{
                    authorURLrray = [HTMLParseHelp basicTextParseFromData:self.data withXpath:@"//*[@id='threadlist']/tbody/tr/td[3]/cite/a/@href" options:MSHTMLParseDefault alterItem:nil];
                });
                dispatch_group_async(aGroup, aQueue, ^{
                    dateArray = [HTMLParseHelp basicTextParseFromData:self.data withXpath:@"//*[@id='threadlist']/tbody/tr/td[3]/em/text()" options:MSHTMLParseDefault alterItem:nil];
                });
                

                dispatch_group_wait(aGroup, DISPATCH_TIME_FOREVER);
//#ifdef MSDEBUG
                NSLog(@"=========item parse finished=============item count %d======",[titleArray count]);
//#endif
                
                if ([titleArray count]) {
                    dispatch_apply([titleArray count], aQueue, ^(size_t i){   
                        EbookListItem *item = [[EbookListItem alloc]init];
                        [item setTitle:[titleArray objectAtIndex:i]];
                        [item setAuthor:[authorArray objectAtIndex:i]];
                        [item setDate:[dateArray objectAtIndex:i]];
                        [item setAuthorURL:[authorURLrray objectAtIndex:i]];
                        [item setAvatarURL:[[authorURLrray objectAtIndex:i]userInfoStringToAvatarString]];
                        [item setLink:[linkArray objectAtIndex:i]];
                        [list addObject:item];NSLog(@"titleArray objectAtIndex:i is %@",[titleArray objectAtIndex:i]);
                    });
                    

// deal with refreshing and downloading
                    if (isRefresh == NO) {
                        [self.ebookList addObjectsFromArray:list];
                        self.currentPage ++;
                    }else {
                        [self.ebookList setArray:list];
// after refreshing,should reset the bool variable isRefresh to no
                        isRefresh = NO;
                    }
                    
                    [self.ebookListTab reloadData];
                }
            }else if(self.requestPageIndex > self.totalPageNum){
                [self handleError:@"没有更多了..."];
                [self performSelector:@selector(resetMJRefreshView) withObject:nil afterDelay:1];
            }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



#pragma mark -
#pragma mark UITableViewDataSource  Methods
// -------------------------------------------------------------------------------
//	method name
// -------------------------------------------------------------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self resetMJRefreshView];
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ebookList count]?[self.ebookList count]: kCustomRowCount ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.ebookList count]) {
        EbookListItem *item = [self.ebookList objectAtIndex:indexPath.row];
        CGFloat textLabelHeight = [self sizeForLabelWithTitle:[item title]].height;
        return textLabelHeight + 35 > 58?textLabelHeight+ 35:58;
    }else
        return 58;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"cell";
    NSMutableString *detailString = [NSMutableString stringWithString:@""];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    if ([self.ebookList count]) {
        EbookListItem *item = [self.ebookList objectAtIndex:indexPath.row];
        [detailString appendFormat:@"%@ 发布于 %@",[item author],[[item date]description]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        [cell.textLabel setNumberOfLines:0];
        [cell.textLabel setLineBreakMode:NSLineBreakByCharWrapping];
        CGRect framForLabel;
        framForLabel.origin = CGPointMake(80, 8);
        framForLabel.size = [self sizeForLabelWithTitle:[item title]];
        cell.frame = framForLabel;
        cell.textLabel.text = [item title];
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.text = detailString;
        
        if (!item.avatarIcon) {
            if (self.ebookListTab.dragging == NO && self.ebookListTab.decelerating == NO)
            {
                [self startIconDownload:item forIndexPath:indexPath];
            }
                cell.imageView.image = [UIImage imageNamed:@"AvatarPlaceholder.png"];
        }else
        {
            cell.imageView.image = item.avatarIcon;
        }
    }else{
        if (indexPath.row == 0) {
            cell.textLabel.text = @"我正在拼命下载中...";
            
        }else{
            cell.textLabel.text = @"";
        }
        cell.textLabel.font = [UIFont systemFontOfSize:20];
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageView.image = nil;
            
    }
    
    return cell;
}
// -------------------------------------------------------------------------------
//	sizeForLabelWithTitle
// -------------------------------------------------------------------------------
- (CGSize)sizeForLabelWithTitle:(NSString *)string
{
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize maximumSize = CGSizeMake(kWidthForCellTextLabel, MAXFLOAT);
    CGSize expectedSize = [string sizeWithFont:font
                             constrainedToSize:maximumSize
                                 lineBreakMode:NSLineBreakByCharWrapping];
    
    return expectedSize;
}

#pragma mark - 
#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.ebookList count]>1) {
        if (bookDetailVC==nil) {
            bookDetailVC = [[BookDetailViewController alloc]
                            initWithNibName:@"BookDetailViewController" bundle:nil];
        }
        EbookListItem *item = [self.ebookList objectAtIndex:indexPath.row];
        if (bookDetailVC.ebookDetail==nil) {
            bookDetailVC.ebookDetail = [[EBookDetailItem alloc]init];
        }
        [bookDetailVC.ebookDetail setEbookURL:[NSString stringWithFormat:@"http://www.pin5i.com%@",item.link]];
        [bookDetailVC.ebookDetail setAuthorMediumAvatarURL:[item.avatarURL smallAvatarToMedium]];
        [bookDetailVC.ebookDetail setAuthor:[item author]];
        [bookDetailVC.ebookDetail setTitle:[item title]];
        self.needLoad = NO;
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:bookDetailVC animated:YES];

    }
}









#pragma mark - Table cell image support

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(EbookListItem *)item forIndexPath:(NSIndexPath *)indexPath
{
    AvatarDownloader *avatarDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (avatarDownloader == nil)
    {
        avatarDownloader = [[AvatarDownloader alloc] init];
        avatarDownloader.ebookItem = item;
        [avatarDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = [self.ebookListTab cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.imageView.image = item.avatarIcon;
            
            // Remove the avatarDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        [self.imageDownloadsInProgress setObject:avatarDownloader forKey:indexPath];
        [avatarDownloader startDownload];
    }
}


// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if ([self.ebookList count] > 0)
    {
        NSArray *visiblePaths = [self.ebookListTab indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            EbookListItem *item = [self.ebookList objectAtIndex:indexPath.row];
            
            if (!item.avatarIcon)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:item forIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}





#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (_header == refreshView) {
        isRefresh = YES;
        [self startDownloadWithColumn:self.column page:1];
    }else{
        isRefresh = NO;
        int page = self.currentPage;
        [self startDownloadWithColumn:self.column page:++page];
    }
}

#pragma mark reset refresh view
- (void)resetMJRefreshView
{
    // 让刷新控件恢复默认的状态
    [_header endRefreshing];
    [_footer endRefreshing];
}




@end
