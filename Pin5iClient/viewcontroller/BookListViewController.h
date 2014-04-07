//
//  BookListViewController.h
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-15.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "EGORefreshTableHeaderView.h"


@interface BookListViewController : UIViewController{

}
@property (nonatomic, copy) NSString *columnName;
@property (nonatomic, copy) NSString *column;
@property (nonatomic, strong) NSMutableArray *ebookList;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) BOOL needLoad;


- (void)startDownloadWithColumn:(NSString *)url page:(int)pageNum;
@end
