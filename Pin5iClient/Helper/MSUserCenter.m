//
//  MSUserCenter.m
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-31.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "MSUserCenter.h"

#define kFilename @"subscription.plist"
#define kDataKey @"Data"

@interface MSUserCenter (){
    NSMutableArray *_mobileListChosed;
    NSMutableArray *_softListChosed;
    NSMutableArray *_webListChosed;
    NSMutableArray *_databaseListChosed;
    NSMutableArray *_vipListChosed;
    NSMutableArray *_applicationListChosed;
    NSDictionary *_chosedTitleToListDic;
}

@end

@implementation MSUserCenter


+ (MSUserCenter *)sharedUserCenter
{
    static id sharedUserCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUserCenter = [[super allocWithZone:NULL]init];
        
    });
    return sharedUserCenter;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [self sharedUserCenter];
}



- (BOOL)initSubscriptionSetting{
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        NSData *data = [[NSMutableData alloc]initWithContentsOfFile:filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        _chosedTitleToListDic = [unarchiver decodeObjectForKey:kDataKey];
        if (_chosedTitleToListDic) {
            _mobileListChosed = [_chosedTitleToListDic objectForKey:@"移动开发"];
            _softListChosed = [_chosedTitleToListDic objectForKey:@"软件编程"];
            _webListChosed = [_chosedTitleToListDic objectForKey:@"Web编程"];
            _databaseListChosed = [_chosedTitleToListDic objectForKey:@"数据编程"];
            _applicationListChosed = [_chosedTitleToListDic objectForKey:@"编程应用"];
            _vipListChosed = [_chosedTitleToListDic objectForKey:@"Vip资源"];
            return YES;
        }else
            return NO;
    }else{
        _mobileListChosed = [NSMutableArray arrayWithArray:mobileList];
        _softListChosed = [NSMutableArray arrayWithArray:softList];
        _webListChosed = [NSMutableArray arrayWithArray:webList];
        _databaseListChosed = [NSMutableArray arrayWithArray:databaseList];
        _applicationListChosed = [NSMutableArray arrayWithArray:applicationList];
        _vipListChosed = [NSMutableArray arrayWithArray:vipList];
        _chosedTitleToListDic = @{@"移动开发": _mobileListChosed,       @"软件编程":_softListChosed,
                                  @"Web编程": _webListChosed,          @"数据编程":_databaseListChosed,
                                  @"编程应用":_applicationListChosed,   @"Vip资源":_vipListChosed };
        return YES;
    }
}


- (BOOL)saveSubscriptionSetting{
    NSString *filePath = [self dataFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        BOOL success =[fileManager createFileAtPath:filePath contents:nil attributes:nil];
        if (!success) {
            return NO;
        }
    }
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data
                                 ];
    [archiver encodeObject:_chosedTitleToListDic forKey:kDataKey];
    [archiver finishEncoding];
    BOOL success = [data writeToFile:filePath atomically:YES];
    return success;
}



- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}


@end
