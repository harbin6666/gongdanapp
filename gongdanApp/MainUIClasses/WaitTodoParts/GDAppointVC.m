//
//  GDAppointVC.m
//  gongdanApp
//
//  Created by 薛翔 on 14-2-25.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDAppointVC.h"
#import <QuartzCore/QuartzCore.h>
#import "AppointTVC.h"

@interface GDAppointVC ()

@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tipsView;
@property (weak, nonatomic) IBOutlet UIView *textTFBG;
@property (nonatomic, strong)UITextView *noteTV;

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (nonatomic, strong) NSString *keyWord;

@property (nonatomic)int selectedIndex;
@property (nonatomic, strong)NSArray *personArr;
@property (nonatomic, strong)NSArray *groupArr;
@property (nonatomic, strong)NSString *formNo;

@property (nonatomic, strong)NSDictionary *selPersonDic;
@property (nonatomic, strong)NSDictionary *selGroupDic;
@end

@implementation GDAppointVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFormNo:(NSString*)formNo type:(int)type {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.type = type;
        self.formNo = formNo;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.type == 1) {
        self.title = @"工单抄送";
        self.typeLabel.text = @"班组名：";
        self.searchTF.placeholder = @"请输入班组名称";
        [self searchGroup];
        
    }else{
        self.title = @"工单指定";
        self.typeLabel.text = @"姓名：";
        self.searchTF.placeholder = @"请填写姓名";
        [self getRelationPerson];
    }
    self.selectedIndex = -1;
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor colorWithRed:67.0/255 green:149.0/255 blue:195.0/255 alpha:1.0].CGColor;
    
    self.tipsView.layer.borderColor = [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0].CGColor;
    self.tipsView.layer.borderWidth = 1.0;
    
    self.textTFBG.layer.borderColor = [UIColor colorWithRed:131.0/255 green:167.0/255 blue:182.0/255 alpha:1.0].CGColor;
    self.textTFBG.layer.borderWidth = 1.0;
    
    self.noteTV = [[UITextView alloc]initWithFrame:self.tipsView.bounds];
    self.noteTV.backgroundColor = [UIColor clearColor];
    [self.tipsView addSubview:_noteTV];
//    
//    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyboard)];
//    [self.view addGestureRecognizer:ges];
    
//    [self.tableView registerClass:[AppointTVC class] forCellReuseIdentifier:@"appointCell"];
}
- (IBAction)submitClicked:(id)sender {
    if (self.type == 0) {
        [self appointToPerson];
    }else{
        [self copyToTeam];
    }
}
- (IBAction)cancelClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)closeKeyboard {
    [self.noteTV resignFirstResponder];
    [self.searchTF resignFirstResponder];
}
- (void)getRelationPerson {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [self showLoading];
    [GDService requestWithFunctionName:@"get_user_byoperator" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.personArr = reObj;
            [self.tableView reloadData];
        }
    }];
    //http://10.19.116.148:8899/alarm/get_user_byoperator/?{"Operator":"fangmin"}
}
- (void)searchPerson:(id)sender {
    
    if (self.keyWord == nil || [self.keyWord isEqualToString:@""]) {
        [self getRelationPerson];
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:self.keyWord forKey:@"UserName"];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [self showLoading];
    [GDService requestWithFunctionName:@"get_user_bycuruser" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.personArr = reObj;
            [self.tableView reloadData];
        }
    }];
    
    //http://10.19.116.148:8899/alarm/get_user_bycuruser/?{"Operator":"fangmin","UserName":"吴"}
}
- (void)searchGroup {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:self.keyWord forKey:@"Group"];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [dic setSafeObject:__INT(3) forKey:@"Type"];
    [self showLoading];
    [GDService requestWithFunctionName:@"get_group_info" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.groupArr = reObj;
            [self.tableView reloadData];
        }
    }];
    //http://10.19.116.148:8899/alarm/get_group_info/?{"Type":3,"Operator":"admin","Group":"无线"}
}

- (void)appointToPerson {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [dic setSafeObject:SharedDelegate.userGroupId forKey:@"Group"];
    [dic setSafeObject:__INT(8) forKey:@"OperateType"];
    [dic setSafeObject:[self dateToNSString:[NSDate date]] forKey:@"OperateTime"];
    [dic setSafeObject:[self.selPersonDic objectForKey:@"UserID"] forKey:@"Appointor"];
    [dic setSafeObject:self.noteTV.text forKey:@"Note"];
    [self showLoading];
    [GDService requestWithFunctionName:@"set_appoint_state" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = reObj;
            NSNumber *flag = [dic objectForKey:@"Flag"];
            NSString *desc = [dic objectForKey:@"Desc"];
            if (flag.intValue == 0) {
                UIAlertView *alert  = [[UIAlertView alloc]initWithTitle:@"操作成功" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"指定失败" message:desc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
    //http://10.19.116.148:8899/alarm/set_appoint_state/?{"FormNo":"ID-051-130910-00852","OperateType":8,"OperateTime":"2013-08-16 13:15:26","Operator":"admin","Group":"2001","Appointor":"200003","Note":"test2"}
}

- (void)copyToTeam {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [dic setSafeObject:__INT(9) forKey:@"OperateType"];
    [dic setSafeObject:[self dateToNSString:[NSDate date]] forKey:@"OperateTime"];
    [dic setSafeObject:[self.selGroupDic objectForKey:@"GroupID"] forKey:@"CopyAccount"];
    [dic setSafeObject:self.noteTV.text forKey:@"Note"];
    [self showLoading];
    [GDService requestWithFunctionName:@"set_copy_state" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = reObj;
            NSNumber *flag = [dic objectForKey:@"Flag"];
            NSString *desc = [dic objectForKey:@"Desc"];
            if (flag.intValue == 0) {
                UIAlertView *alert  = [[UIAlertView alloc]initWithTitle:@"操作成功" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"抄送失败" message:desc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
    //http://10.19.116.148:8899/alarm/set_copy_state/?{"FormNo":"ID-051-130910-00852","OperateType":9,"OperateTime":"2013-08-16 13:15:26","Operator":"test","CopyAccount":"2001","Note":"test2"}
}

- (IBAction)searchBtnClicked:(id)sender {
    self.keyWord = self.searchTF.text;
    [self closeKeyboard];
    if (self.type == 0) {
        [self searchPerson:nil];
    }else{
        [self searchGroup];
    }
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.keyWord = nil;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self closeKeyboard];
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - tableview delegate/datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.type == 0) {
        return self.personArr.count;
    }else{
        return self.groupArr.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *av = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 44)];
    av.backgroundColor = [UIColor whiteColor];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 110, 44)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = @"姓名";
    nameLabel.backgroundColor = [UIColor clearColor];
    [av addSubview:nameLabel];
    if (self.type == 1) {
        nameLabel.frame = CGRectMake(50, 0, 250, 44);
        nameLabel.text = @"部门班组名";
    }

    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(55, 0, 1, 44)];
    line1.backgroundColor = [UIColor colorWithRed:67.0/255 green:149.0/255 blue:195.0/255 alpha:1.0];
    [av addSubview:line1];
    
    if (self.type == 0) {
        UILabel *accountLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, 0, 115, 44)];
        accountLabel.textAlignment = NSTextAlignmentCenter;
        accountLabel.text = @"账户";
        accountLabel.backgroundColor = [UIColor clearColor];
        [av addSubview:accountLabel];
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(175, 0, 1, 44)];
        line2.backgroundColor = [UIColor colorWithRed:67.0/255 green:149.0/255 blue:195.0/255 alpha:1.0];
        [av addSubview:line2];
    }
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43, 300, 1)];
    line.backgroundColor = [UIColor colorWithRed:67.0/255 green:149.0/255 blue:195.0/255 alpha:1.0];
    [av addSubview:line];
    return av;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //AppointTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"appointCell" forIndexPath:indexPath];
    
    AppointTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"appointCell"];
    if (!cell) {
        cell = [[AppointTVC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"appointCell"];
    }
    
    NSDictionary *dic;
    if (self.type == 0) {
        dic = [self.personArr safeObjectAtIndex:indexPath.row];
        self.selPersonDic = dic;
    }else{
        dic = [self.groupArr safeObjectAtIndex:indexPath.row];
        self.selGroupDic = dic;
    }
    int isSel = self.selectedIndex == indexPath.row+1 ? YES : NO;
    [cell updaeWithDic:dic type:self.type isSel:isSel];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedIndex == indexPath.row+1) {
        self.selectedIndex = -1;
    }else{
        self.selectedIndex = indexPath.row + 1;
    }
    [self closeKeyboard];
    [self.tableView reloadData];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self closeKeyboard];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
