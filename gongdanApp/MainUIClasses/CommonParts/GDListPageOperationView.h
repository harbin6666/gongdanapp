//
//  GDListPageOperationView.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-22.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _GDListPageOperationTypeTag {
    GDListPageOperationType_firstPage = 0,
    GDListPageOperationType_nextPage,
    GDListPageOperationType_formerPage,
    GDListPageOperationType_lastPage
}GDListPageOperationTypeTag;

@protocol GDListPageOperationDelegate;


@interface GDListPageOperationView : UIView
@property(nonatomic, weak)id<GDListPageOperationDelegate> delegate;
@property(nonatomic)int totalNum;
@property(nonatomic)int currentPageIndex;
- (void)listDidSrollWithScrollView:(UIScrollView*)scrollView;
- (id)initWithFrame:(CGRect)frame scrollViewFrame:(CGRect)sFrame;
- (void)updateWithCurrentPage:(int)currentPage;
@end

@protocol GDListPageOperationDelegate <NSObject>
@required
- (void)GDListPage:(GDListPageOperationView*)listPage operationAction:(GDListPageOperationTypeTag)tag;
@end