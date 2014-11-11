//
//  SearchResultVC.m
//  gongdanApp
//
//  Created by 薛翔 on 14-3-4.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "SearchResultVC.h"
#import "GDCommonRootTVC.h"
#import "GDMainHandleVC.h"

@interface SearchResultVC ()
@property(nonatomic, strong)GDListPageOperationView *operationView;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *dataArr;
@property(nonatomic, strong)NSMutableDictionary *pramaDic;

@property(nonatomic)int currentPageIndex;
@end

@implementation SearchResultVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"搜索结果";
    }
    return self;
}
- (id)initWithPramaDic:(NSMutableDictionary*)dic dataArr:(NSMutableArray*)dataArr {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"搜索结果";
        self.dataArr = dataArr;
        self.pramaDic = dic;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGRect rec = self.view.bounds;
    rec.size.height -= 50;
    self.tableView = [[UITableView alloc]initWithFrame:rec];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    //[_tableView registerClass:[GDCommonRootTVC class] forCellReuseIdentifier:@"resultCell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    //
    rec.origin.y = rec.size.height;
    rec.size.height = 50;
    self.operationView = [[GDListPageOperationView alloc]initWithFrame:rec scrollViewFrame:_tableView.frame];
    _operationView.delegate = self;
    [self.view addSubview:_operationView];
    self.currentPageIndex = 1;
    
    if (self.dataArr.count > 0) {
        NSMutableDictionary* dic = [self.dataArr objectAtIndex:0];
        NSNumber *totalCount = [dic objectForKey:@"Count"];
        self.operationView.totalNum = totalCount.intValue;
    }else{
        self.operationView.totalNum = 0;
    }
}

- (void)doSearch {
    NSNumber *startNo = __INT(1+(_currentPageIndex-1)*5);
    NSNumber *endNo = __INT(startNo.intValue+4);
    if (endNo.intValue >= _operationView.totalNum && _operationView.totalNum > 0) {
        endNo = __INT(_operationView.totalNum);
    }
    
    NSMutableDictionary *dic = self.pramaDic;
    [dic setSafeObject:startNo forKey:@"StartNo"];
    [dic setSafeObject:endNo forKey:@"EndNo"];
    [self showLoading];
    [GDService requestWithFunctionName:@"get_form_query" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        NSLog(@"请求结束了");
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.dataArr = reObj;
            if (self.dataArr.count > 0 && startNo.intValue == 1) {
                NSMutableDictionary* dic = [self.dataArr safeObjectAtIndex:0];
                NSNumber *totalCount = [dic objectForKey:@"Count"];
                self.operationView.totalNum = totalCount.intValue;
            }
            // 出错提示,出错了则不往下面走了
            NSDictionary *dic1 = [self.dataArr safeObjectAtIndex:0];
            NSString *desc = [dic1 objectForKey:@"Desc"];
            if (desc) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"失败" message:desc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            [self.operationView updateWithCurrentPage:self.currentPageIndex];
            [self.tableView reloadData];
        }
    }];
    //{"NetTypeOne":"101010401","GroupName":"8a9982f2222d2030012231a4252110ab","Operator":"inspur","FormState":2,"FormLevel":1,"StartTime":"2013-11-01 00:00:00","EndTime":"2013-11-01 23:59:59","StartNo":1,"EndNo":5}
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
    [self doSearch];
}
#pragma mark - tableview delegate/datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //GDCommonRootTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell" forIndexPath:indexPath];
    
    GDCommonRootTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell"];
    
    if (!cell) {
        cell = [[GDCommonRootTVC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"resultCell"];
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
    
    GDMainHandleVC *hvc = [[GDMainHandleVC alloc]initWithFormNo:formNo formType:FormType_todo formsearchState:FormSearchState_TodoAndDoing formState:formState.intValue];
    hvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:hvc animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
