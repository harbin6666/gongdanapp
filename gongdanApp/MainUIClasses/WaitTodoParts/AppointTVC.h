//
//  AppointTVC.h
//  gongdanApp
//
//  Created by 薛翔 on 14-3-4.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppointTVC : UITableViewCell
- (void)updaeWithDic:(NSDictionary*)dic type:(int)type isSel:(BOOL)isSel;
@end
