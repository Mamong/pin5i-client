//
//  BaiduPanPanel.h
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-19.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIFormDataRequest;




@interface BaiduPanPanel : NSObject{
    ASIFormDataRequest *theRequest;
    
    
}
@property (nonatomic, copy) NSString *panlink;

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *extractCode;
@property (nonatomic, strong) IBOutlet UILabel *fileNameTF;
@property (nonatomic, strong) IBOutlet UILabel *extractCodeTF;
@property (nonatomic, strong) IBOutlet UIView *view;

- (void)startToExtractFile;
- (IBAction)saveFileToMyBaiduPan:(id )sender;
@end






/* Notifications
 */

static NSString *BaiduPanPanelWillAppearNotification;
static NSString *BaiduPanPanelDidAppearNotification;
static NSString *BaiduPanPanelSuccessAccessNotification;
extern NSString *BaiduPanPanelFailedAccessNotification;
extern NSString *BaiduPanPanelSuccessSaveNotification;
extern NSString *BaiduPAnpanelFailedSaveNotification;



