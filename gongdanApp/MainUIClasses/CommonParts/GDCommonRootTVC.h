//
//  GDCommonRootTVC.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-23.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDCommonRootTVC : UITableViewCell
@property(nonatomic, strong)UILabel *themeLabel;
@property(nonatomic, strong)UILabel *codeLabel;
@property(nonatomic, strong)UILabel *timeLabel;

@property(nonatomic)int state;
@property(nonatomic, strong)UIImageView *stateImgV;
- (NSArray*)getTheShowInfoWithDic:(NSMutableDictionary*)dic;
- (void)updateWithDic:(NSMutableDictionary*)dic;
@end
