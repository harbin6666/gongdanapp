//
//  OTSViewPoper.h
//  OneStore
//
//  Created by huangjiming on 8/27/14.
//  Copyright (c) 2014 OneStore. All rights reserved.
//

#import <Foundation/Foundation.h>
//屏幕宽度
#define UI_SCREEN_HEIGHT                ([[UIScreen mainScreen] bounds].size.height)

//屏幕高度
#define UI_SCREEN_WIDTH                ([[UIScreen mainScreen] bounds].size.width)
@interface OTSViewPoper : NSObject

@property(nonatomic, strong) UIView *bgView;//背景，默认黑色，alpha为0.1
@property(nonatomic, strong) UIView *popView;

/**
 *  功能:显示pop view
 */
- (void)showPopView;

/**
 *  功能:隐藏pop view
 */
- (void)hidePopView;

@end
