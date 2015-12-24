//
//  OTSViewPoper.m
//  OneStore
//
//  Created by huangjiming on 8/27/14.
//  Copyright (c) 2014 OneStore. All rights reserved.
//

#import "OTSViewPoper.h"

@interface OTSViewPoper()

@end

@implementation OTSViewPoper

#pragma mark - Property
- (UIView *)bgView
{
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _bgView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgClicked:)];
        [_bgView addGestureRecognizer:tapGesture];
    }
    
    return _bgView;
}

- (UIView *)popView
{
    if (_popView == nil) {
        _popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 250)];
        
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 250)];
        subView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        subView.layer.cornerRadius = 5.0;
        [_popView addSubview:subView];
    }
    
    return _popView;
}

#pragma mark - Action
- (void)bgClicked:(UIGestureRecognizer *)aGesture
{
    [self hidePopView];
}

#pragma mark - API
/**
 *  功能:显示pop view
 */
- (void)showPopView
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    for (UIView *sub in window.subviews)
    {
        [sub resignFirstResponder];
    }
    
    [window addSubview:self.bgView];
    self.bgView.alpha = 0.1;
    
    [window addSubview:self.popView];
    CGRect rect = [UIScreen mainScreen].bounds;
    self.popView.frame = CGRectMake(self.popView.frame.origin.x, rect.size.height, self.popView.frame.size.width, self.popView.frame.size.height);
    
    [UIView animateWithDuration:.3f animations:^{
        self.popView.frame = CGRectMake(self.popView.frame.origin.x, rect.size.height-self.popView.frame.size.height, self.popView.frame.size.width, self.popView.frame.size.height);
        self.bgView.alpha = 1.0;
    }];
}

/**
 *  功能:隐藏pop view
 */
- (void)hidePopView
{
    CGRect rect = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:.3f animations:^{
        self.popView.frame = CGRectMake(self.popView.frame.origin.x, rect.size.height, self.popView.frame.size.width, self.popView.frame.size.height);
        self.bgView.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self.popView removeFromSuperview];
        [self.bgView removeFromSuperview];
    }];
}

@end
