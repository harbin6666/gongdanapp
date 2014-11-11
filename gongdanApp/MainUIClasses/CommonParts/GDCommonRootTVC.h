//
//  GDCommonRootTVC.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-23.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDCommonRootTVC : UITableViewCell
@property(nonatomic)int state;
- (void)updateWithDic:(NSMutableDictionary*)dic;
@end
