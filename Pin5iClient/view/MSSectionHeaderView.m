//
//  MSSectionHeaderView.m
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-30.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "MSSectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MSSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isExpanded = YES;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    
    [[self layer] setShadowOffset:CGSizeMake(1, 1)];
    
    [[self layer] setShadowRadius:5];
    
    [[self layer] setShadowOpacity:1];
    
    [[self layer] setShadowColor:[UIColor blackColor].CGColor];

    
}



- (IBAction)hit:(id)sender
{
    
    if (self.isExpanded == YES) {
        self.isExpanded = NO;
    }else
        self.isExpanded = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        if (self.isExpanded) {
           
            self.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
           
        } else {
            self.accessoryView.transform = CGAffineTransformMakeRotation(0);
        }
       
    } completion:^(BOOL competition){
        NSRange range = NSMakeRange(self.section, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationBottom];

    }];
}
@end
