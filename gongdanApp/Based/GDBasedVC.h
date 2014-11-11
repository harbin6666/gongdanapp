//
//  GDBasedVC.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-21.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDService.h"
#import "NSString+Base64Decode.h"

@interface GDBasedVC : UIViewController
/**
 *  功能:左按钮点击行为，可在子类重写此方法
 */
- (void)leftBtnClicked:(id)sender;

/**
 *  功能:右按钮点击行为，可在子类重写此方法
 */
- (void)rightBtnClicked:(id)sender;

- (void)setLeftBtnImage:(UIImage*)image highLightImage:(UIImage*)hImage;
- (void)setRightBtnImage:(UIImage*)image highLightImage:(UIImage*)hImage;
- (void)showLoading;
- (void)hideLoading;
- (NSString*)dateToNSString:(NSDate*)date;
@end

@interface NSMutableDictionary (GD)
- (void)setSafeObject:(id)anObject forKey:(id<NSCopying>)aKey;
@end

@interface NSArray (GD)
- (id)safeObjectAtIndex:(NSUInteger)index;
@end

@interface NSMutableArray (GD)
- (id)safeObjectAtIndex:(NSUInteger)index;
@end