//
//  GDCopyVC.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-20.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDBasedVC.h"
#import "GDListPageOperationView.h"
#import "GDUpSearchView.h"

@interface GDCopyVC : GDBasedVC<UITableViewDataSource, UITableViewDelegate, GDListPageOperationDelegate, GDUpSearchDelegate>

@end
