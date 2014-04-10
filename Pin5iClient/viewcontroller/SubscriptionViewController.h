//
//  SubscriptionViewController.h
//  Pin5i-Client
//
//  Created by mamong on 14-3-30.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscriptionViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UITableView *IndexTableView;
    NSMutableArray *mobileListChosed;
    NSMutableArray *softListChosed;
    NSMutableArray *webListChosed;
    NSMutableArray *databaseListChosed;
    NSMutableArray *applicationListChosed;
    NSMutableArray *vipListChosed;
    NSMutableArray *sectionTitleChosed;
    
}


@end
