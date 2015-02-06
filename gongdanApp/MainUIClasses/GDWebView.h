//
//  GDWebView.h
//  gongdanApp
//
//  Created by yuan jun on 14/12/17.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^loadhtmlBlock)(CGFloat webHeight);

@interface GDWebView : UIView
-(void)loadHTMLString:(NSString *)string withCompletBlock:(loadhtmlBlock)finishblock;
@end
