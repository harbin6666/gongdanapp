//
//  GDMutilVC.m
//  gongdanApp
//
//  Created by yj on 16/3/28.
//  Copyright © 2016年 xuexiang. All rights reserved.
//

#import "GDMutilVC.h"
#import "GDServiceV2.h"
#import "GDMutilCell.h"
#import "GDWaitTodoTVC.h"

@interface GDMutilVC ()<UIAlertViewDelegate>
@property(nonatomic, strong)NSString *startDate;
@property(nonatomic, strong)NSString *endDate;
@property(nonatomic, strong)NSMutableArray *dataArr;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *selectArray;
@end

@implementation GDMutilVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"批量处理";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    self.startDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-8*60*60]];
    self.endDate = [dateFormatter stringFromDate:[NSDate date]];
    CGRect rec = self.view.bounds;
    rec.size.height -= 40;
    self.tableView = [[UITableView alloc]initWithFrame:rec];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    self.selectArray=[[NSMutableArray alloc] init];
    self.dataArr=[[NSMutableArray alloc] init];
    UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0, rec.size.height, rec.size.width, 40)];
    v.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]];
    [self.view addSubview:v];
    
    UIButton *bu=[UIButton buttonWithType:UIButtonTypeCustom];
    [bu addTarget:self action:@selector(clickAcept) forControlEvents:UIControlEventTouchUpInside];
    bu.frame=CGRectMake(rec.size.width-100, 0, 80, 30);
    [bu setTitle:@"批量接单" forState:UIControlStateNormal];
    [bu setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [v addSubview:bu];
    [self getData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        [self dealOrder];
    }
}

-(void)clickAcept{
    
    if (self.selectArray.count==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"没有选择工单" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"确定要批量提交受理吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"受理",nil];
    [alert show];

}

-(void)dealOrder{
    
    [self showLoading];
    NSMutableString *formNum=@"".mutableCopy;
    for (NSIndexPath*indexP in self.selectArray) {
        NSDictionary *form=[self.dataArr objectAtIndex:indexP.row];
        [formNum appendFormat:@"%@,",form[@"FormNo"]];
    }
    NSString*subStr=[formNum substringToIndex:formNum.length-1];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Dealor"];
    [dic setSafeObject:subStr forKey:@"FormNo"];
    [dic setSafeObject:__INT(3) forKey:@"FormState"];
    [dic setSafeObject:[self dateToNSString:[NSDate date]] forKey:@"StartTime"];
    [dic setSafeObject:@"2" forKey:@"PfType"];
    
    [self showLoading];
    [GDService requestWithFunctionName:@"set_form_state" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = reObj;
            [self getData];
            //int state = ((NSNumber*)[dic objectForKey:@"Flag"]).intValue;
            NSString *str = [dic objectForKey:@"Flag"];
            if ([str isEqualToString:@"成功"]){//(state == 0) {
                //NSString *desc = [dic objectForKey:@"Desc"];
                //[self.navigationController popToRootViewControllerAnimated:YES];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"受理成功" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"受理失败" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];

}

- (void)getData{

    if (SharedDelegate.userZhName==nil||[SharedDelegate.userZhName isEqualToString:@""]) {
        return;
    }
    NSNumber *startNo = __INT(1);
    NSNumber *endNo = __INT(50);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:__INT(1) forKey:@"FormState"];
    [dic setSafeObject:__INT(1) forKey:@"FormStateType"];
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
            NSArray*temp = reObj;
            [self.dataArr removeAllObjects];
            [self.selectArray removeAllObjects];
            for (NSDictionary *dic in temp) {
                if ([dic[@"FormStatus"] integerValue]==2) {
                    [self.dataArr addObject:dic];
                }
            }
            [self.tableView reloadData];
        }
    }];
}


-(BOOL)selectIndex:(NSIndexPath*)indexPath{
    for (NSIndexPath*index in self.selectArray) {
        if (index.row==indexPath.row) {
            return YES;
        }
    }
    return NO;
}
#pragma mark - tableview delegate/datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //GDCommonRootTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"waittodotvc" forIndexPath:indexPath];
    
    GDMutilCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cel"];
    if (!cell) {
        cell = [[GDMutilCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cel"];
    }
    
    
    NSMutableDictionary *dic = [self.dataArr safeObjectAtIndex:indexPath.row];
    [cell updateWithDic:dic];
    if ([self selectIndex:indexPath]) {
        cell.stateImgV.image=[UIImage imageNamed:@"login_auto_sel"];
    }else{
        cell.stateImgV.image=[UIImage imageNamed:@"login_auto"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    if ([self selectIndex:indexPath]) {
        [self.selectArray removeObject:indexPath];
    }else{
        if (self.selectArray.count==5) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"批量提交一次最多选择5条" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
        [self.selectArray addObject:indexPath];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
