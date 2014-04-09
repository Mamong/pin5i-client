//
//  NSArray+DeleteNSNull.m
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-31.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "NSArray+DeleteNSNull.h"

@implementation NSArray (DeleteNSNull)


- (NSArray *)arrayWithoutNSNull{
    NSMutableArray *resultArray = [NSMutableArray array];
    id object;
    if ([self count]) {
        for (int i= 0; i < [self count]; i++) {
            object = [self objectAtIndex:i];
            if (![object isKindOfClass:[NSNull class]]) {
                [resultArray addObject:object];
            }
        }
        if ([resultArray count]) {
            return resultArray;
        }else{
            [resultArray addObject:[NSNull null]];
            return resultArray;
        }
    }else{
        [resultArray addObject:[NSNull null]];
        return resultArray;
    }
}
@end
