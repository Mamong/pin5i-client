//
//  HomeViewController.m
//  Pin5i-Client
//
//  Created by mamong on 14-3-14.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "HomeViewController.h"
#import "BookListViewController.h"
#import "BookDetailViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "MSSectionHeaderView.h"
#import "MSUserCenter.h"
#import "NSArray+DeleteNSNull.h"

static int _offset = 120;

@interface HomeViewController (){
    
    NSMutableArray *mobileListSubscribed;
    NSMutableArray *softListSubscribed;
    NSMutableArray *webListSubscribed;
    NSMutableArray *databaseListSubscribed;
    NSMutableArray *applicationListSubscribed;
    NSMutableArray *vipListSubscribed;
    NSDictionary *titleToListDicSubscribed;
    
    NSIndexPath *index;
    BookListViewController *bListVC;
    BookDetailViewController *bookDetailVC;
    NSMutableArray *headerViewArray;
}

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mobileListSubscribed = [NSMutableArray array];
        softListSubscribed = [NSMutableArray array];
        webListSubscribed = [NSMutableArray array];
        databaseListSubscribed = [NSMutableArray array];
        applicationListSubscribed = [NSMutableArray array];
        vipListSubscribed = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"首页"];

   
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"custom"] style:UIBarButtonItemStylePlain  target:self action:@selector(showUserCenter)];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"detailButton"] style:UIBarButtonItemStylePlain target:self action:@selector(showBookItem)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    headerViewArray = [[NSMutableArray alloc]init];
    for (int i =0; i<[sectionTitle count]; i++) {
        MSSectionHeaderView *sectionHeaderView=(MSSectionHeaderView*)[[[NSBundle mainBundle]loadNibNamed:@"SectionHeaderView" owner:nil options:nil]objectAtIndex:0];
        sectionHeaderView.isExpanded = NO;
        [headerViewArray addObject:sectionHeaderView];
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(updateSubscriptionDatasource:) name:MSNotificationSubscriptionChange object:nil];
    
    [self updateSubscriptionDatasource:nil];
    
    titleToListDicSubscribed = @{@"移动开发": mobileListSubscribed,       @"软件编程":softListSubscribed,
                                 @"Web编程": webListSubscribed,          @"数据编程":databaseListSubscribed,
                                 @"编程应用":applicationListSubscribed,   @"Vip资源":vipListSubscribed};
    [IndexTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IndexTableView deselectRowAtIndexPath:index animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(preloadView) object:nil];
    [self performSelector:@selector(preloadView) withObject:nil afterDelay:0.3];
}

/////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MSSectionHeaderView *sectionHeaderView=[headerViewArray objectAtIndex:section];
    sectionHeaderView.section = section;
    
    sectionHeaderView.tableView = tableView;
    sectionHeaderView.titleLabel.text = [sectionTitle objectAtIndex:section];
    return sectionHeaderView;
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    MSSectionHeaderView *sectionHeaderView=(MSSectionHeaderView*)[self tableView:tableView viewForHeaderInSection:section];
    if (sectionHeaderView.isExpanded) {
        id unknownArray = [titleToListDicSubscribed objectForKey:[sectionTitle objectAtIndex:section]];
        if ([[unknownArray objectAtIndex:0]isKindOfClass:[NSNull class]]) {
            return 0;
        }else
            return [unknownArray count];
    }else
        return 0;
    
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [sectionTitle objectAtIndex:section];
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"title";
    NSString *sectionName = [sectionTitle objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[titleToListDicSubscribed objectForKey:sectionName]objectAtIndex:indexPath.row];
    
    return cell;
}



#pragma mark -
#pragma mark UITableView Delegate Methods
// -------------------------------------------------------------------------------
//	-tableView:didSelectRowAtIndexPath:
// -------------------------------------------------------------------------------
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    index = indexPath;
    NSString *sectionName = [sectionTitle objectAtIndex:indexPath.section];
    NSString *listName = [[titleToListDicSubscribed objectForKey:sectionName]objectAtIndex:indexPath.row];
    if (bListVC == nil) {
        bListVC = [[BookListViewController alloc]initWithNibName:@"BookListViewController" bundle:nil];
    }
    bListVC.needLoad = YES;
    [bListVC setColumnName:listName];
    [bListVC setColumn:[listToColumnDic objectForKey:listName]];
    [self.navigationController pushViewController:bListVC animated:YES];
     
  
}


// -------------------------------------------------------------------------------
//	pprevealSideViewController start
// -------------------------------------------------------------------------------
- (void)showUserCenter{
    LeftViewController *leftVC = [[LeftViewController alloc]initWithNibName:@"LeftViewController" bundle:nil];
    UINavigationController *leftNavVC = [[UINavigationController alloc]initWithRootViewController:leftVC];
    [self.revealSideViewController pushViewController:leftNavVC onDirection:PPRevealSideDirectionLeft withOffset:_offset animated:YES];
    leftNavVC = nil;
}

- (void)showBookItem{
    RightViewController *rightVC = [[RightViewController alloc]initWithNibName:@"RightViewController" bundle:nil];
    UINavigationController *rightNavVC = [[UINavigationController alloc]initWithRootViewController:rightVC];
    [self.revealSideViewController pushViewController:rightNavVC onDirection:PPRevealSideDirectionRight withOffset:_offset animated:YES];
    rightNavVC = nil;
}



- (void)preloadView
{
    LeftViewController *leftVC = [[LeftViewController alloc]initWithNibName:@"LeftViewController" bundle:nil];
    UINavigationController *leftNav = [[UINavigationController alloc]initWithRootViewController:leftVC];
    [self.revealSideViewController preloadViewController:leftNav
                                                 forSide:PPRevealSideDirectionLeft
                                              withOffset:_offset];
    
    RightViewController *rightVC = [[RightViewController alloc]initWithNibName:@"RightViewController" bundle:nil];
    UINavigationController *rightNav = [[UINavigationController alloc]initWithRootViewController:rightVC];
    [self.revealSideViewController preloadViewController:rightNav
                                                 forSide:PPRevealSideDirectionRight
                                              withOffset:_offset];
    leftNav = nil;
    rightNav= nil;
}

// -------------------------------------------------------------------------------
//	pprevealSideViewController end
// -------------------------------------------------------------------------------




- (void)updateSubscriptionDatasource:(NSNotification *)notification
{
    MSUserCenter *userCenter = [MSUserCenter sharedUserCenter];

    if (notification == nil) {
        
        [mobileListSubscribed setArray:[[userCenter mobileListChosed]arrayWithoutNSNull]];
        [softListSubscribed setArray:[[userCenter softListChosed]arrayWithoutNSNull]];
        [webListSubscribed setArray:[[userCenter webListChosed]arrayWithoutNSNull]];
        [databaseListSubscribed setArray:[[userCenter databaseListChosed]arrayWithoutNSNull]];
        [applicationListSubscribed setArray:[[userCenter applicationListChosed]arrayWithoutNSNull]];
        [vipListSubscribed setArray:[[userCenter vipListChosed]arrayWithoutNSNull]];
        
    }else{
        
        NSDictionary *notificationInfo = [notification userInfo];
        NSIndexPath *indexpath = (NSIndexPath *)[notificationInfo objectForKey:@"indexpath"];
        NSUInteger whichSectionToUpdate = indexpath.section;
        NSString *sectionName = [sectionTitle objectAtIndex:whichSectionToUpdate];
        NSMutableArray *selectArray = [titleToListDicSubscribed objectForKey:sectionName];
        NSMutableArray *rawArray = [[userCenter chosedTitleToListDic] objectForKey:sectionName];
        [selectArray setArray:[rawArray arrayWithoutNSNull]];
        
        NSRange range = NSMakeRange(whichSectionToUpdate, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [IndexTableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}





- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}
@end
