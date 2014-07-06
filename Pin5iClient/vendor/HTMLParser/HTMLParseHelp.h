//
//  HTMLParseHelp.h
//  HTMLParseHelp
//
//  version 1.1
//
//  fix two errors
//
//  version 1.2
//  add alterBlock, remove separetor parameter 
//
//  Created by mamong on 14-1-14.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    MSHTMLParseDefault = 0,         //for text() and @href etc,single target
    MSHTMLParseJointCurrent = 1,    //joint current label's text only
    MSHTMLParseJointAll = 2,        //joint current and children labels' text
    MSHTMLParseIntoComponents = 3   //get every node' text by order into an array
}MSHTMLParseType;

@interface HTMLParseHelp : NSObject


/*      *方法描述：parse text from htlm data         *
        * @param data
        * @param xpath          
        * @param options        parse type defined 
        * @param alterBlock      do something to alter the item found
        * @return result array
*/
+(NSArray *)basicTextParseFromData:(NSData *)data
                         withXpath:(NSString *)xpath
                           options:(MSHTMLParseType)parseType
                        alterItem:(NSString *(^)(NSString *item))alterBlock;


@end
