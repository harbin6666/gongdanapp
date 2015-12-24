//
//  GDCopyVC.m
//  gongdanApp
//
//  Created by 薛翔 on 14-2-20.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDCopyVC.h"
#import "GDCommonRootTVC.h"
#import "GDMainHandleVC.h"
#import "GDServiceV2.h"
@interface GDCopyVC ()
@property(nonatomic, strong)GDListPageOperationView *operationView;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *dataArr;

@property(nonatomic, strong)NSString *startDate;
@property(nonatomic, strong)NSString *endDate;

@property(nonatomic)int currentPageIndex;
@property(nonatomic, strong)GDUpSearchView *topSearchView;
@end

@implementation GDCopyVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"抄送工单";
        self.navigationItem.leftBarButtonItem = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initTtitle];
    CGRect rec = self.view.bounds;
    rec.size.height -= 50;
    self.tableView = [[UITableView alloc]initWithFrame:rec];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    //[_tableView registerClass:[GDCommonRootTVC class] forCellReuseIdentifier:@"copyCell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    //
    rec.origin.y = rec.size.height;
    rec.size.height = 50;
    self.operationView = [[GDListPageOperationView alloc]initWithFrame:rec scrollViewFrame:_tableView.frame];
    _operationView.delegate = self;
    [self.view addSubview:_operationView];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    self.startDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-8*60*60]];
    self.endDate = [dateFormatter stringFromDate:[NSDate date]];
    self.dataArr = [NSMutableArray array];
    self.currentPageIndex = 1;
}
- (void)initTtitle {
    UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 11, 22, 22)];
    [searchBtn setImage:[UIImage imageNamed:@"searchBtn"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:searchBtn];
    
    UIButton *refreshBtn = [[UIButton alloc]initWithFrame:CGRectMake(270, 11, 22, 22)];
    [refreshBtn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(getData) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:refreshBtn];
    CGRect rec = refreshBtn.frame;
    rec.origin.x -= 20;
    self.navigationItem.rightBarButtonItem.customView.frame = rec;
    //[self.navigationController.navigationBar addSubview:refreshBtn];
}
- (void)searchBtnClicked {
    if (self.topSearchView) {
        [self.topSearchView closeTopSearchViewWithBlock:^{
            self.topSearchView = nil;
        }];
    }else{
        self.topSearchView = [[GDUpSearchView alloc]initWithFrame:CGRectMake(0, 0, 320, 230)];
        self.topSearchView.delegate = self;
        [self.view addSubview:self.topSearchView];
        [self.topSearchView popTopSearchView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self getData];
}
- (void)getData{
    NSNumber *startNo = __INT(1+(_currentPageIndex-1)*5);
    NSNumber *endNo = __INT(startNo.intValue+4);
    if (endNo.intValue >= _operationView.totalNum && _operationView.totalNum > 0) {
        endNo = __INT(_operationView.totalNum);
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:__INT(1) forKey:@"FormState"];
    [dic setSafeObject:__INT(3) forKey:@"FormStateType"];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Dealor"];
    [dic setSafeObject:self.startDate forKey:@"StartTime"]; //@"2013-02-01 12:39:10" forKey:@"StartTime"];//
    [dic setSafeObject:self.endDate forKey:@"EndTime"];
    [dic setSafeObject:startNo forKey:@"StartNo"];
    [dic setSafeObject:endNo forKey:@"EndNo"];
    [dic setSafeObject:@(-1) forKey:@"NetType"];
    [dic setSafeObject:@(-1) forKey:@"Subject"];
    [dic setSafeObject:@"" forKey:@"FormNo"];
    [dic setSafeObject:@"" forKey:@"FormTitle"];
    if (SharedDelegate.loginedUserName!=nil) {
        [dic setObject:SharedDelegate.loginedUserName forKey:@"Dealor"];
    }

    
    
    [self showLoading];
    [GDServiceV2 requestFunc:@"wo_get_form_list" WithParam:dic withCompletBlcok:^(id reObj,NSError* error) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            // 正常返回
            self.dataArr = reObj;
            if (self.dataArr.count > 0 && startNo.intValue == 1) {  // 加载第一页的时候初始化获取总数据
                NSMutableDictionary* dic = [self.dataArr safeObjectAtIndex:0];
                NSNumber *totalCount = [dic objectForKey:@"Count"];
                self.operationView.totalNum = totalCount.intValue;
            }
            [self.operationView updateWithCurrentPage:self.currentPageIndex];
            [self.tableView reloadData];
        }
    }];
}

- (void)refreshData {
    NSNumber *startNo = __INT(1+(_currentPageIndex-1)*5);
    NSNumber *endNo = __INT(startNo.intValue+4);
    if (endNo.intValue >= _operationView.totalNum && _operationView.totalNum > 0) {
        endNo = __INT(_operationView.totalNum);
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:__INT(1) forKey:@"FormState"];
    [dic setObject:__INT(3) forKey:@"FormStateType"];
    [dic setObject:SharedDelegate.loginedUserName forKey:@"Dealor"];
    [dic setObject:self.startDate forKey:@"StartTime"];
    [dic setObject:self.endDate forKey:@"EndTime"];
    [dic setObject:startNo forKey:@"StartNo"];
    [dic setObject:endNo forKey:@"EndNo"];
    
    [self showLoading];
    [GDService requestWithFunctionName:@"get_form_list" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        NSLog(@"请求结束了");
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.dataArr = reObj;
            if (self.dataArr.count > 0 && startNo.intValue == 1) {
                NSMutableDictionary* dic = [self.dataArr safeObjectAtIndex:0];
                NSNumber *totalCount = [dic objectForKey:@"Count"];
                self.operationView.totalNum = totalCount.intValue;
            }
            [self.operationView updateWithCurrentPage:self.currentPageIndex];
            [self.tableView reloadData];
        }
    }];
}
- (void)getListDateWithStartNo:(NSNumber*)startNo endNo:(NSNumber*)endNo {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:__INT(1) forKey:@"FormState"];
    [dic setObject:__INT(3) forKey:@"FormStateType"];
    [dic setObject:SharedDelegate.loginedUserName forKey:@"Dealor"];
    [dic setObject:self.startDate forKey:@"StartTime"];//@"2014-02-01 12:39:10" forKey:@"StartTime"];//
    [dic setObject:self.endDate forKey:@"EndTime"];//@"2014-03-01 12:39:10" forKey:@"EndTime"];//
    [dic setObject:startNo forKey:@"StartNo"];
    [dic setObject:endNo forKey:@"EndNo"];
    
    [self showLoading];
    [GDService requestWithFunctionName:@"get_form_list" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        NSLog(@"请求结束了");
        [self hideLoading];
        NSArray *arr = reObj;
        if (arr.count > 0) {
            [self.dataArr addObjectsFromArray:arr];
        }
        //self.dataArr = reObj;
        [self.tableView reloadData];
    }];
}
- (void)upSearchWithStartDate:(NSString*)startDate endDate:(NSString*)endDate {
    self.startDate = startDate;
    self.endDate = endDate;
    [self getData];
}
- (void)GDListPage:(GDListPageOperationView*)listPage operationAction:(GDListPageOperationTypeTag)tag {
    int totalPage = ceil(listPage.totalNum/5.0);
    self.currentPageIndex = listPage.currentPageIndex;
    switch (tag) {
        case GDListPageOperationType_firstPage:
            self.currentPageIndex = 1;
            break;
        case GDListPageOperationType_formerPage: {
            self.currentPageIndex = _currentPageIndex-1>=1 ? _currentPageIndex-1 : 1;
            break;
        }
        case GDListPageOperationType_nextPage: {
            self.currentPageIndex = _currentPageIndex+1<=totalPage ? _currentPageIndex+1 : totalPage;
            break;
        }
        case GDListPageOperationType_lastPage: {
            self.currentPageIndex = totalPage;
            break;
        }
        default:
            break;
    }
    self.currentPageIndex = self.currentPageIndex >= 1 ? _currentPageIndex : 1;
    [self getData];
}
#pragma mark - tableview delegate/datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //GDCommonRootTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"copyCell" forIndexPath:indexPath];
    
    GDCommonRootTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"copyCell"];
    if (!cell) {
        cell = [[GDCommonRootTVC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"copyCell"];
    }
    
    NSMutableDictionary *dic = [self.dataArr objectAtIndex:indexPath.row];
    [cell updateWithDic:dic];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *dic = [self.dataArr objectAtIndex:indexPath.row];
    NSString *formNo = [dic objectForKey:@"FormNo"];
    NSNumber *formState = [dic objectForKey:@"FormStatus"];
    
    GDMainHandleVC *hvc = [[GDMainHandleVC alloc]initWithFormNo:formNo formType:FormType_copy formsearchState:FormSearchState_Copy formState:formState.intValue];
    hvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:hvc animated:YES];
}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self.operationView listDidSrollWithScrollView:scrollView];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
