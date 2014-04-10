//
//  EbookListItem.h
//  Pin5i-Client
//
//  Created by mamong on 14-3-15.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EbookListItem : NSObject


@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *authorURL;
@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, strong) UIImage *avatarIcon;
@property (nonatomic, copy) NSString *date;

@end
