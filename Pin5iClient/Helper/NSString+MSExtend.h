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


- (NSString *)userInfoStringToAvatarString;

- (NSString *)smallAvatarToMedium;

- (NSString *)panLinkToVerifyLink;
- (NSString *)panLinkToFileLink;
- (NSString *)panLinkToSaveID;



- (BOOL)evaluateWithSize:(NSNumber *)number;
@end
