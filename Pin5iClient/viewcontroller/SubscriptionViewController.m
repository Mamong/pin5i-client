//
//  SubscriptionViewController.m
//  Pin5i-Client
//
//  Created by mamong on 14-3-30.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "SubscriptionViewController.h"
#import "PPRevealSideViewController.h"
#import  "RightViewController.h"
#import "MSSectionHeaderView.h"
#import "SubscriptionCell.h"
#import "MSUserCenter.h"

@interface SubscriptionViewController (){
    UINib *nib;
    NSMutableArray *headerViewArray;
}

@end

@implementation SubscriptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(popSubscriptionVC)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    headerViewArray = [[NSMutableArray alloc]init];
    for (int i =0; i<[sectionTitle count]; i++) {
        MSSectionHeaderView *sectionHeaderView=(MSSectionHeaderView*)[[[NSBundle mainBundle]loadNibNamed:@"SectionHeaderView" owner:nil options:nil]objectAtIndex:0];
        sectionHeaderView.isExpanded = NO;
        [headerViewArray addObject:sectionHeaderView];
    }

}


-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// -------------------------------------------------------------------------------
//	method name
// -------------------------------------------------------------------------------
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
        return [[titleToListDic objectForKey:[sectionTitle objectAtIndex:section]]count];
    }else
        return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"CustomCellIdentifier";
    NSString *sectionName = [sectionTitle objectAtIndex:indexPath.section];
    NSString *title;
    if (!nib) {
        nib = [UINib nibWithNibName:@"SubscriptionCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        NSLog(@"fuck nib is nil");
    }
    
    SubscriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    title = [[titleToListDic objectForKey:sectionName]objectAtIndex:indexPath.row];
    cell.titleLabel.text = title;
    MSUserCenter *userCenter = [MSUserCenter sharedUserCenter];
    if ([[userCenter.chosedTitleToListDic objectForKey:sectionName]containsObject:title]) {
        [cell.indicatorView setImage:[UIImage imageNamed:@"blueLedSmall"]];
    }else
        [cell.indicatorView setImage:[UIImage imageNamed:@"blueLedSmallOff"]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSUserCenter *userCenter = [MSUserCenter sharedUserCenter];
    NSString *sectionName = [sectionTitle objectAtIndex:indexPath.section];
    NSMutableArray *array = [[userCenter chosedTitleToListDic] objectForKey:sectionName];
    id currentCell = [array objectAtIndex:indexPath.row];
    if ([currentCell isKindOfClass:[NSNull class]]) {
        [array replaceObjectAtIndex:indexPath.row withObject:[[titleToListDic objectForKey:sectionName] objectAtIndex:indexPath.row]];
    }else{
        [array replaceObjectAtIndex:indexPath.row withObject:[NSNull null]];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSDictionary *subscriptionChangeInfo = @{@"indexpath": indexPath};
    [[NSNotificationCenter defaultCenter]postNotificationName:MSNotificationSubscriptionChange object:self userInfo:subscriptionChangeInfo];
}





- (void)popSubscriptionVC
{
    [self.revealSideViewController replaceAfterOpenedCompletelyWithOffset:120 animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    

}
@end
