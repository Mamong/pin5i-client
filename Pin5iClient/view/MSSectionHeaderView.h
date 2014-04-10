//
//  MSSectionHeaderView.h
//  Pin5i-Client
//
//  Created by mamong on 14-3-30.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSSectionHeaderView : UIView


@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *accessoryView;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) UITableView *tableView;

- (IBAction)hit:(id)sender;
@end
