//
//  HomeViewController.h
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-14.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PPRevealSideViewController.h"


@interface HomeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    
    IBOutlet UITableView *IndexTableView;
    
}

@end
