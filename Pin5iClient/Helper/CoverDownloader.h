//
//  CoverDownloader.h
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-20.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EBookDetailItem;
@interface CoverDownloader : NSObject

@property (nonatomic, strong) EBookDetailItem *ebookDetail;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownloadWithIndex:(NSUInteger)index;
- (void)cancelDownload;

@end
