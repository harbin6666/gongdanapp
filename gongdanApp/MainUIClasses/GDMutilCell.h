//
//  GDMutilCell.h
//  gongdanApp
//
//  Created by yj on 16/3/29.
//  Copyright © 2016年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDMutilCell :UITableViewCell
@property(nonatomic, strong)UIImageView *stateImgV;

- (void)updateWithDic:(NSMutableDictionary*)dic;

@end
