//
//  NSString+MSExtend.h
//  HTMLTestForCast
//
//  Created by mamong on 14-1-12.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MSExtend)

-(NSString *)substringFromHeader:(NSString *)header toTail:(NSString *)tail;

//from http://www.pin5i.com/userinfo-101327.html
//to   http://www.pin5i.com/avatars/upload/000/10/13/27_avatar_medium.jpg
- (NSString *)userInfoStringToAvatarString;

- (NSString *)smallAvatarToMedium;

- (NSString *)panLinkToVerifyLink;
- (NSString *)panLinkToFileLink;
- (NSString *)panLinkToSaveID;


// 34.56  vs 35388
// when (34.56-1)*1024 > 35288 return NO;
- (BOOL)evaluateWithSize:(NSNumber *)number;
@end
