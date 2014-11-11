//
//  SearchResultVC.h
//  gongdanApp
//
//  Created by 薛翔 on 14-3-4.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDBasedVC.h"
#import "GDListPageOperationView.h"

@interface SearchResultVC : GDBasedVC<UITableViewDataSource, UITableViewDelegate, GDListPageOperationDelegate>
- (id)initWithPramaDic:(NSMutableDictionary*)dic dataArr:(NSMutableArray*)dataArr;
@end
