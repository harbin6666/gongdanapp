//
//  GDAppointVC.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-25.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDBasedVC.h"

@interface GDAppointVC : GDBasedVC<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property(nonatomic)int type; // 0默认为指定，1为抄送
- (id)initWithFormNo:(NSString*)formNo type:(int)type;
@end
