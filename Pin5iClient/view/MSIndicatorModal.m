//
//  MSIndicatorModal.m
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-4-1.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "MSIndicatorModal.h"
#import "RTSpinKitView.h"

@interface MSIndicatorModal (){
    CGPoint		startEndPoint;
}

@end


@implementation MSIndicatorModal

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		self.autoresizesSubviews = YES;
        self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
		self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		self.containerView.autoresizesSubviews = YES;
        [self.containerView setBackgroundColor:[UIColor colorWithRed:0.827 green:0.329 blue:0 alpha:0.7]];
        [self addSubview:self.containerView];
		
		[self setBackgroundColor:[UIColor clearColor]]; // Fixed value, the bacground mask.
        _spinKitView = nil;
        _titleLabel = nil;
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)show
{
    [self showAnimationStarting];

    self.alpha = 0.0;
    self.containerView.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
    void (^animationBlock)(BOOL) = ^(BOOL finished) {
		// Wait one second and then fade in the view
		[UIView animateWithDuration:0.1
						 animations:^{
							 self.containerView.transform = CGAffineTransformMakeScale(0.95, 0.95);
						 }
						 completion:^(BOOL finished){
							 
							 // Wait one second and then fade in the view
							 [UIView animateWithDuration:0.1
											  animations:^{
												  self.containerView.transform = CGAffineTransformMakeScale(1.02, 1.02);
											  }
											  completion:^(BOOL finished){
												  
												  // Wait one second and then fade in the view
												  [UIView animateWithDuration:0.1
																   animations:^{
																	   self.containerView.transform = CGAffineTransformIdentity;
																   }
																   completion:^(BOOL finished){
                                                                       [self showAnimationFinished];
																   }];
											  }];
						 }];
	};
	
	// Show the view right away
    [UIView animateWithDuration:0.4
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 self.alpha = 1.0;
						 self.containerView.center = self.center;
						 self.containerView.transform = CGAffineTransformMakeScale((_shouldBounce ? 1.05 : 1.0), (_shouldBounce ? 1.05 : 1.0));
					 }
					 completion:(_shouldBounce ? animationBlock : ^(BOOL finished) {
       
    })];

}





- (void)hide {
	// Hide the view right away
		
    [UIView animateWithDuration:0.3
					 animations:^{
						 self.alpha = 0;
						 self.containerView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
					 }
					 completion:^(BOOL finished){
						 
						 [self removeFromSuperview];
                         [self.spinKitView removeFromSuperview];
                         self.spinKitView = nil;
					 }];
}

- (CGPoint)spinKitViewCenter
{
    CGRect containerViewBounds = [self.containerView bounds];
    return CGPointMake(containerViewBounds.size.width/2,
                       (containerViewBounds.size.height - self.titleLabel.bounds.size.height - self.marginLS)/2);
}


- (CGPoint)titleLabelCenter
{
    CGRect containerViewBounds = [self.containerView bounds];
    return CGPointMake(containerViewBounds.size.width/2,
                       (containerViewBounds.size.height + self.spinKitView.bounds.size.height + self.marginLS)/2);

}


- (RTSpinKitView *)spinKitView
{
    if (!_spinKitView) {
        _spinKitView = [[RTSpinKitView alloc]initWithStyle:self.spinKitViewStyle];
        _spinKitView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _spinKitView.autoresizesSubviews = YES;
        [self.containerView addSubview:_spinKitView];
    }
    return _spinKitView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setText:@"Loading..."];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
        [self.containerView addSubview:_titleLabel];
    }
    return _titleLabel;
}



- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.spinKitView.center = [self spinKitViewCenter];NSLog(@"[self spinKitViewCenter](%f,%f)",[self spinKitViewCenter].x,[self spinKitViewCenter].y);NSLog(@"self.spinKitView frame(%f,%f)",self.spinKitView.frame.origin.x,self.spinKitView.frame.origin.y);
	self.titleLabel.center = [self titleLabelCenter];
}


- (void)showAnimationStarting {
    self.spinKitView.alpha = 0.0;
    self.titleLabel.alpha = 0.0;
}

- (void)showAnimationFinished {
	[UIView animateWithDuration:0.2
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 self.spinKitView.alpha = 1.0;
						 self.titleLabel.alpha = 1.0;
					 }
					 completion:nil];
}



@end
