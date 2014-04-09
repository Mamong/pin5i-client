//
//  NSString+MSExtend.m
//  HTMLTestForCast
//
//  Created by mamong on 14-1-12.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "NSString+MSExtend.h"

@implementation NSString (MSExtend)


-(NSString *)substringFromHeader:(NSString *)header toTail:(NSString *)tail
{
    NSRange headRange = [self rangeOfString:header];
    NSString *temp = [self substringFromIndex:headRange.location];
    NSRange tailRange = [temp rangeOfString:tail];
    NSRange selectedRange;
    selectedRange.location = headRange.location;
    selectedRange.length = tailRange.location;
    NSString *selectedString = [self substringWithRange:selectedRange];
    return selectedString;
}

//from http://www.pin5i.com/userinfo-101327.html
//to   http://www.pin5i.com/avatars/upload/000/10/13/27_avatar_medium.jpg
-(NSString *)userInfoStringToAvatarString
{
    NSString *result;
    NSString *userNmu = [[self substringFromHeader:@"-" toTail:@"."]substringFromIndex:1];
    NSMutableString *temp= [NSMutableString stringWithString:userNmu];
    int i = 6 - [userNmu length];
    while (i --) {
        [temp insertString:@"0" atIndex:0];
    }
    [temp insertString:@"/" atIndex:2];
    [temp insertString:@"/" atIndex:5];
    result = [NSString stringWithFormat:@"http://www.pin5i.com/avatars/upload/000/%@_avatar_small.jpg",temp];
    return result;
}



// from http://www.pin5i.com/avatars/upload/000/10/13/27_avatar_small.jpg
// to   http://www.pin5i.com/avatars/upload/000/10/13/27_avatar_medium.jpg
- (NSString *)smallAvatarToMedium
{
    NSMutableString *saw = [NSMutableString stringWithString:self];
    [saw replaceOccurrencesOfString:@"small" withString:@"medium"
                                               options:NSBackwardsSearch
                                                 range:NSMakeRange(0, [self length])];
    NSString *result = [saw copy];
    return result;
}







//from http://pan.baidu.com/wap/init?shareid=2656188430&uk=3154721401
//to   http://pan.baidu.com/wap/verify?shareid=3113200247&uk=3154721401&t=1395149815214&channel=chunlei&clienttype=0&web=1

- (NSString *)panLinkToVerifyLink
{
    NSString *suffix = [[self componentsSeparatedByString:@"init?"]objectAtIndex:1];
    NSString *verifyLink = [NSString stringWithFormat:@"http://pan.baidu.com/wap/verify?%@&t=1395149815214&channel=chunlei&clienttype=0&web=1",suffix];
    return verifyLink;
}

//from  http://pan.baidu.com/wap/init?shareid=2656188430&uk=3154721401
//to    http://pan.baidu.com/wap/link?shareid=3477660253&uk=3154721401
- (NSString *)panLinkToFileLink
{
    NSMutableString *mutString = [NSMutableString stringWithString:self];
    [mutString replaceCharactersInRange:NSMakeRange([@"http://pan.baidu.com/wap/" length], 4) withString:@"link"];
    return [NSString stringWithString:mutString];
}

//from http://pan.baidu.com/wap/init?shareid=2656188430&uk=3154721401
//to   from=1093492205&shareid=2863655745
- (NSString *)panLinkToSaveID
{
    NSString *shareid = [self substringFromHeader:@"shareid" toTail:@"&uk"];
    NSString *from = [self substringFromIndex:[self rangeOfString:@"uk="].location+3];
    return [NSString stringWithFormat:@"from=%@&%@",from,shareid];
}


// 34.56  vs 35388
// when (34.56-1)*1024 > 35288 return NO;
- (BOOL)evaluateWithSize:(NSNumber *)number
{
    float sizeFloat = ([self floatValue]-1)*1024;
    return sizeFloat > [number unsignedIntValue];
}

@end
