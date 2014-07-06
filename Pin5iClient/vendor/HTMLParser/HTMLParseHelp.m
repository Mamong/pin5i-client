//
//  HTMLParseHelp.m
//  HTMLTestForCast
//
//  Created by mamong on 14-1-14.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "HTMLParseHelp.h"
#import "TFHpple.h"




@implementation HTMLParseHelp



+(NSArray *)basicTextParseFromData:(NSData *)data
                         withXpath:(NSString *)xpath
                           options:(MSHTMLParseType)parseType
                         alterItem:(NSString *(^)(NSString *item))alterBlock
{   
    TFHpple *xpathParser;
    NSArray *elementArray;
    NSArray *childrenArray;
    NSArray *textNodeArray;
    TFHppleElement *textChild;
    NSString *tmp;
        
    NSMutableArray *resultArray = [[NSMutableArray alloc]initWithCapacity:2];
        
    if (data) {
        xpathParser = [[TFHpple alloc]initWithHTMLData:data];
        elementArray = [xpathParser searchWithXPathQuery:xpath];
        if([elementArray count]==0)
            return nil;
        TFHppleElement *aChild = [elementArray objectAtIndex:0];
        if(parseType == MSHTMLParseDefault||[[aChild tagName]isEqualToString:@"text"]){
            @autoreleasepool {
                for (TFHppleElement *elem in elementArray) {
                    tmp = [[elem content]?[elem content]:[[[elem childrenWithTagName:@"text"]objectAtIndex:0]content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([tmp length]) {
                        if (alterBlock) {
                            tmp = alterBlock(tmp);
                        }
                        [resultArray addObject:tmp];
                    }
                }
            }
            return resultArray;
        }
        else
        {
            if (parseType == MSHTMLParseJointCurrent) {
                @autoreleasepool {
                    for (TFHppleElement *elem in elementArray) {
                        NSMutableString *mString = [NSMutableString string];
                        textNodeArray = [elem childrenWithTagName:@"text"];
                        for (TFHppleElement *child in textNodeArray) {
                            tmp = [[child content]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if ([tmp length]) {
                                if (alterBlock) {
                                    tmp = alterBlock(tmp);
                                }
                                [mString appendString:tmp];
                            }
                        }
                        if ([mString length]) {
                            [resultArray addObject:mString];
                        }
                    }
                    return resultArray;
                }
            }
            else if (parseType == MSHTMLParseJointAll)
            {
                 @autoreleasepool {
                     for (TFHppleElement *elem in elementArray) {
                        NSMutableString *mString = [NSMutableString string];
                        childrenArray = [elem children];
                        for (TFHppleElement *child in childrenArray) {
                            if([child isTextNode]){
                                textChild= child;
                            }else{
                                textChild = [child firstChildWithTagName:@"text"];
                            }
                            tmp = [[textChild content]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if ([tmp length]) {
                                if (alterBlock) {
                                    tmp = alterBlock(tmp);
                                }
                                [mString appendString:tmp];
                            }
                        }
                        if ([mString length]) {
                            [resultArray addObject:mString];
                        }
                    }
                 }
                return resultArray;
            }
            else if (parseType == MSHTMLParseIntoComponents)
            {
                @autoreleasepool {
                    for (TFHppleElement *elem in elementArray) {
                        childrenArray = [elem children];
                        for (TFHppleElement *child in childrenArray) {
                            if([child isTextNode]){
                                textChild = child;
                            }else{
                                textChild = [child firstChildWithTagName:@"text"];
                            }
                            tmp = [[textChild content]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if ([tmp length]) {
                                if (alterBlock) {
                                    tmp = alterBlock(tmp);
                                }
                                [resultArray addObject:tmp];
                            }
                        }
                    }
                }
                return resultArray;
            }
        }
    }
    return nil;
}

@end
