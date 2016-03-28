//
//  GDWaitTodoVC.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-20.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDBasedVC.h"
#import "GDListPageOperationView.h"
#import "NSString+Base64Decode.h"
#import "GDUpSearchView.h"

#import "ASIHTTPRequest.h"

@interface GDWaitTodoVC : GDBasedVC<UITableViewDataSource,UITableViewDelegate, GDListPageOperationDelegate, ASIHTTPRequestDelegate, GDUpSearchDelegate>
- (void)getData;
- (void)getClientStatus;
@end
