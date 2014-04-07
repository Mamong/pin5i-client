//
//  MSUserCenter.h
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-31.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import <Foundation/Foundation.h>


#define mobileList  @[@"Android",         @"Symbian",    @"iPhone",\
               @"Windows Phone",                  @"BlackBerry"]

#define softList  @[@"Visual Studio.NET", @"Java",    @"C & C++",\
             @"C#",                @"WPF",     @"WCF",\
             @"Linq",              @"ADO.Net", @"WF",\
             @"F#",                @"Ruby",    @"Perl",     @"Python"]

#define webList @[@"Asp.Net",      @"Silverlight", @"JavaScript",\
            @"Ajax",         @"ExtJS",       @"jQuery",\
            @"Flash & Flex", @"Web",         @"HTML5",\
            @"PHP",          @"XML",         @"Web Service"]

#define databaseList  @[@"SQL", @"SQL Server", @"Oracle",\
                 @"DB2", @"MySQL",      @"NoSQL"]

#define applicationList  @[@"应用系统", @"框架设计", @"程序人生",  @"SEO编程",\
                    @"软件测试", @"算法解析", @"正则表达式", @"游戏编程",\
                    @"面试攻略", @"人生感悟", @"编程技巧",  @"软件工程",\
                    @"电脑原理", @"黑客帝国", @"学习认证",  @"分类编程",\
                    @"Unix & Linux", @"云计算", @"大数据", @"IT杂志"]

#define vipList  @[@"电子书(V)"]

#define sectionTitle  @[@"移动开发", @"软件编程" , @"Web编程",\
                 @"数据编程", @"编程应用",  @"Vip资源"]

#define titleToListDic  @{@"移动开发": mobileList,       @"软件编程":softList,\
                          @"Web编程": webList,          @"数据编程":databaseList,\
                   @"编程应用":applicationList,   @"Vip资源":vipList }

#define listToColumnDic  @{@"Android":@"Android",         @"Symbian":@"symbian",    @"iPhone":@"iphone",\
                    @"Windows Phone":@"windows-phone",          @"BlackBerry":@"BlackBerry" ,\
                    @"Visual Studio.NET":@"visual-studio-net",  @"Java":@"java",    @"C & C++":@"c",\
                    @"C#":@"csharp",          @"WPF":@"wpf",          @"WCF":@"wcf",\
                    @"Linq":@"linq",          @"ADO.Net":@"adonet",   @"WF":@"wf",\
                    @"F#":@"fsharp",          @"Ruby":@"ruby",        @"Perl":@"perl",\
                    @"Python":@"python",      @"Asp.Net":@"aspnet",   @"Silverlight":@"silverlight",\
                    @"JavaScript":@"js",\
                    @"Ajax":@"ajax",         @"ExtJS":@"extjs",        @"jQuery":@"jquery",\
                    @"Flash & Flex":@"flash-flex", @"Web":@"web",      @"HTML5":@"html5",\
                    @"PHP":@"php",          @"XML":@"xml",             @"Web Service":@"web-service",\
                    @"SQL":@"sql",          @"SQL Server":@"sqlserver",   @"Oracle":@"oracle",\
                    @"DB2":@"db2",          @"MySQL":@"mysql",         @"NoSQL":@"nosql",\
                    @"应用系统":@"application-system",   @"框架设计":@"frame-design",\
                    @"程序人生":@"programme-life",       @"SEO编程":@"seo-programme",\
                    @"软件测试":@"software-test",        @"算法解析":@"arithmetic",\
                    @"正则表达式":@"regular-expression", @"游戏编程":@"game-programming",\
                    @"面试攻略":@"interview",  @"人生感悟":@"life", @"编程技巧":@"programming-skills",\
                    @"软件工程":@"software-engineering",           @"电脑原理":@"computer-principles",\
                    @"黑客帝国":@"hackers",    @"学习认证":@"certification-study",\
                    @"分类编程":@"classification",    @"Unix & Linux":@"unix-linux", @"云计算":@"cloud",\
                    @"大数据":@"big-data",     @"IT杂志":@"it-magazine", @"电子书(V)":@"vip-ebooks"}




@interface MSUserCenter : NSObject

+ (MSUserCenter *)sharedUserCenter;


@property (nonatomic, strong) NSMutableArray *mobileListChosed;
@property (nonatomic, strong) NSMutableArray *softListChosed;
@property (nonatomic, strong) NSMutableArray *webListChosed;
@property (nonatomic, strong) NSMutableArray *databaseListChosed;
@property (nonatomic, strong) NSMutableArray *vipListChosed;
@property (nonatomic, strong) NSMutableArray *applicationListChosed;
@property (nonatomic, strong) NSDictionary *chosedTitleToListDic;

// should invocate initSubscriptionSetting when app lanches
- (BOOL)initSubscriptionSetting;

// should invocate saveSubscriptionSetting when app will terminate
- (BOOL)saveSubscriptionSetting;




// notification
#define MSNotificationSubscriptionChange @"MSNotificationSubscriptionChange"



@end
