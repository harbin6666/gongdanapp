//
//  GDTextView.m
//  gongdanApp
//
//  Created by yuan jun on 14/12/26.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDTextView.h"

@implementation GDTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/* 选中文字后是否能够呼出菜单 */
- (BOOL)canBecameFirstResponder {
    return YES;
}

/* 选中文字后的菜单响应的选项 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
        
    return NO;
}

@end
