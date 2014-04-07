//
//  EBookDetail.h
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-18.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBookDetailItem : NSObject

// the title is associated to the page url
@property (nonatomic, copy) NSString *title;

// the page url
@property (nonatomic, copy) NSString *ebookURL;

// the author who releases the book
@property (nonatomic, copy) NSString *author;

// the url of the author's medium avatar
@property (nonatomic, copy) NSString *authorMediumAvatarURL;

// the eolink of the download link
// eolink is uesd to redirect to the the book's true download link
@property (nonatomic, strong) NSArray *eoLinkArray;

// the extract code to extract file
@property (nonatomic, strong) NSArray *extractCodeArray;

// an array of covers' url
@property (nonatomic, strong) NSArray *coverURLArray;

// the coverArray is an array of imageview,its content may change when refresh.
@property (nonatomic, strong) NSMutableArray *coverArray;

// the cover size array contain the sizes of the covers,paresed from the html data
@property (nonatomic, strong) NSArray *coverSizeArray;

// this property records the downloaded covers' size,evaluating with the size got from
// the html to judge it has been fully downloaded or not
@property (nonatomic, strong) NSMutableArray *coverDownloadSizeArray;

// the string describles the book,showing in the webview
@property (nonatomic, copy) NSString *descriptions;
@end
