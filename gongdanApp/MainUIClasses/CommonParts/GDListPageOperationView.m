//
//  GDListPageOperationView.m
//  gongdanApp
//
//  Created by 薛翔 on 14-2-22.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDListPageOperationView.h"
@interface GDListPageOperationView ()
@property(nonatomic, strong)UILabel *totalNumLabel;
@property(nonatomic, strong)UILabel *currentPageLabel;

@property(nonatomic)CGRect scrollFrame;
@property(nonatomic)int totalPageNo;
@end

@implementation GDListPageOperationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initUIWithFrame:frame];
        self.currentPageIndex = 1;
        self.totalNum = 0;
        self.backgroundColor = [UIColor colorWithRed:108.0/255 green:208.0/255 blue:223.0/255 alpha:1.0];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame scrollViewFrame:(CGRect)sFrame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initUIWithFrame:frame];
        self.scrollFrame = sFrame;
        self.currentPageIndex = 1;
        self.totalNum = 0;
        self.backgroundColor = [UIColor colorWithRed:108.0/255 green:208.0/255 blue:223.0/255 alpha:1.0];
    }
    return self;
}

- (void)initUIWithFrame:(CGRect)frame {
    UIButton *firstPageBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, (frame.size.height-30)/2, 40, 30)];
    [firstPageBtn setTitle:@"首页" forState:UIControlStateNormal];
    firstPageBtn.backgroundColor = [UIColor clearColor];
    firstPageBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [firstPageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [firstPageBtn addTarget:self action:@selector(firstPageClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *formerPageBtn = [[UIButton alloc]initWithFrame:CGRectMake(10+40+10, (frame.size.height-30)/2, 60, 30)];
    [formerPageBtn setTitle:@"上一页" forState:UIControlStateNormal];
    formerPageBtn.backgroundColor = [UIColor clearColor];
    formerPageBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [formerPageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [formerPageBtn addTarget:self action:@selector(formerClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nextPageBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-10-40-70, (frame.size.height-30)/2, 60, 30)];
    [nextPageBtn setTitle:@"下一页" forState:UIControlStateNormal];
    nextPageBtn.backgroundColor = [UIColor clearColor];
    nextPageBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [nextPageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextPageBtn addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *lastPageBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-10-40, (frame.size.height-30)/2, 40, 30)];
    [lastPageBtn setTitle:@"末页" forState:UIControlStateNormal];
    lastPageBtn.backgroundColor = [UIColor clearColor];
    lastPageBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [lastPageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [lastPageBtn addTarget:self action:@selector(lastClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:firstPageBtn];
    [self addSubview:formerPageBtn];
    [self addSubview:nextPageBtn];
    [self addSubview:lastPageBtn];
    
    self.currentPageLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 5, 100, 18)];
    self.currentPageLabel.font = [UIFont systemFontOfSize:14.0];
    self.currentPageLabel.backgroundColor = [UIColor clearColor];
    self.currentPageLabel.textAlignment = NSTextAlignmentCenter;
    self.currentPageLabel.text = @"第0/0页";
    self.totalNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(125, frame.size.height-23, 70, 18)];
    self.totalNumLabel.backgroundColor = [UIColor clearColor];
    self.totalNumLabel.text = @"共0条";
    self.totalNumLabel.font = [UIFont systemFontOfSize:14.0];
    self.totalNumLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_currentPageLabel];
    [self addSubview:_totalNumLabel];
}
- (void)updateWithCurrentPage:(int)currentPage {
    self.currentPageIndex = currentPage;
    self.currentPageLabel.text = [NSString stringWithFormat:@"第%d/%d页",currentPage,_totalPageNo];
}
- (void)setTotalNum:(int)totalNum {
    //double height = totalNum*81;
    _totalNum = totalNum;// ceil(height/self.scrollFrame.size.height);
    self.totalPageNo = ceil(_totalNum/5.0);
    self.currentPageLabel.text = [NSString stringWithFormat:@"第%d/%d页",self.currentPageIndex,_totalPageNo];
    self.totalNumLabel.text = [NSString stringWithFormat:@"共%d条",totalNum];
}
- (void)firstPageClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(GDListPage:operationAction:)]) {
        [self.delegate GDListPage:self operationAction:GDListPageOperationType_firstPage];
    }
}
- (void)nextClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(GDListPage:operationAction:)]) {
        [self.delegate GDListPage:self operationAction:GDListPageOperationType_nextPage];
    }
}
- (void)formerClicked {
    if ([self.delegate respondsToSelector:@selector(GDListPage:operationAction:)]) {
        [self.delegate GDListPage:self operationAction:GDListPageOperationType_formerPage];
    }
}
- (void)lastClicked {
    if ([self.delegate respondsToSelector:@selector(GDListPage:operationAction:)]) {
        [self.delegate GDListPage:self operationAction:GDListPageOperationType_lastPage];
    }
}
- (void)listDidSrollWithScrollView:(UIScrollView*)scrollView {
//    int pageHeight = 5*80;
//    double offset = scrollView.contentOffset.y;
//    
//    int totalPage = ceil(_totalNum/5.0);
//    
//    int currentPage = 1+ceil(offset/pageHeight)==totalPage ? 1+ceil(offset/pageHeight) : 1+floor(offset/pageHeight);
//    
//    if (currentPage != self.currentPageIndex) {
//        if (currentPage > totalPage) {
//            totalPage = currentPage;
//        }
//        self.currentPageLabel.text = [NSString stringWithFormat:@"第%d/%d页",currentPage,totalPage];
//        self.currentPageIndex = currentPage;
//    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
