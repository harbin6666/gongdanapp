//
//  GDLoginVC.m
//  gongdanApp
//
//  Created by 薛翔 on 14-3-2.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDLoginVC.h"
#import "AppDelegate.h"

@interface GDLoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *secretTF;
@property (weak, nonatomic) IBOutlet UIButton *rememberPassBtn;
@property (weak, nonatomic) IBOutlet UIButton *autoLoginBtn;

@property (nonatomic)BOOL isRememberPass;
@property (nonatomic)BOOL isAutoLogin;
@end

@implementation GDLoginVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:ges];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    if (userName) {
        self.userNameTF.text = userName;
    }
    NSString *passWord = [[NSUserDefaults standardUserDefaults] objectForKey:@"PassWord"];
    if (passWord) {
        self.secretTF.text = passWord;
        self.rememberPassBtn.selected = YES;
        self.isRememberPass = YES;
    }
    NSNumber *isAutoLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAutoLogin"];
    if (isAutoLogin.boolValue == YES) {
        self.autoLoginBtn.selected = YES;
        self.isAutoLogin = YES;
        //[self login];
    }
    
//    UIButton *exitBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 44, 44, 30)];
//    [exitBtn setImage:[UIImage imageNamed:@"quit"] forState:UIControlStateNormal];
//    [exitBtn setImage:[UIImage imageNamed:@"quit_sel"] forState:UIControlStateHighlighted];
//    [exitBtn addTarget:self action:@selector(exitApp) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:exitBtn];
}
- (void)exitApp {
    exit(0);
}
- (void)login {
    if (self.userNameTF.text == nil || [self.userNameTF.text isEqualToString:@""] || self.secretTF.text == nil || [self.secretTF.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请正确填写账号和密码" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"mq_pass" forKey:@"Function"];
    [dic setObject:@"authentication" forKey:@"ServiceName"];
    
//    [dic setObject:@"liuweiguo" forKey:@"Username"];
//    [dic setObject:@"Boco1234" forKey:@"Password"];
    
    
    [dic setObject:self.userNameTF.text forKey:@"Username"];
    [dic setObject:self.secretTF.text forKey:@"Password"];
    
    [self showLoading];
    [GDService requestWithFunctionName:@"mq_pass" pramaDic:dic requestMethod:@"POST" completion:^(id reObj){
        //
        
        NSLog(@"请求结束了");
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dic = reObj;
            NSString *result = [dic objectForKey:@"Result"];
            if ([result isEqualToString:@"0"]) {
                SharedDelegate.loginedUserName = self.userNameTF.text;
                SharedDelegate.userZhName=dic[@"userZhName"];
                SharedDelegate.userTelNum=[NSString stringWithFormat:@"%@",dic[@"userTelNum"]];
                [self saveInfoToLocal];
//                [self getTeamAndGroup:nil];
                //[self closeSelf];
                [self getCurrentGroup];
                [self getReject];
                [self getFreshTime];//只有代办有
//                [SharedDelegate mqtt];
            }else if ([result isEqualToString:@"1"]){
                [self hideLoading];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:@"用户不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
            else if ([result isEqualToString:@"2"]){
                [self hideLoading];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:@"密码不正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }else{
                [self hideLoading];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:@"其他原因" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }else{
            [self hideLoading];
        }
    }];
}

- (void)getCurrentGroup {
    [self showLoading];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    
    [GDService requestWithFunctionName:@"get_group_byuser" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            NSArray *arr = reObj;
            NSDictionary *dic = [arr safeObjectAtIndex:0];
            SharedDelegate.userGroup = [dic objectForKey:@"GroupName"];
            SharedDelegate.userGroupId = [dic objectForKey:@"GroupID"];
        }
        [self closeSelf];
    }];
    //http://10.19.116.148:8899/alarm/get_group_byuser/?{"Operator":"admin"}
}

- (void)getTeamAndGroup:(id)sender {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:__INT(0) forKey:@"Type"];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [dic setSafeObject:__INT(0) forKey:@"Flag"];
    [dic setSafeObject:__INT(-1) forKey:@"CityID"];
    [dic setSafeObject:@"1" forKey:@"Group"];
    
    [GDService requestWithFunctionName:@"get_user_group" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        NSDictionary *dic = reObj;
        SharedDelegate.userGroup = [dic objectForKey:@"Group"];
        SharedDelegate.userGroupId = [dic objectForKey:@"GroupNo"];
        SharedDelegate.dept=[dic objectForKey:@"Dept"];
        SharedDelegate.company=[dic objectForKey:@"Company"];
        [self closeSelf];
    }];
    
    //http://10.19.116.148:8899/alarm/get_user_group/?{"Type":0,"Operator":"dw2_jiaminggang","Flag":0,"CityID":-1,"Group":"1"}
}

-(void)getReject{
    [self showLoading];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [GDService requestWithFunctionName:@"get_user_info_reject" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*)reObj;
            SharedDelegate.reject=[dic[@"Flag"] boolValue];
        }
        [self closeSelf];
    }];

}

- (void)getFreshTime{
    [self showLoading];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:@1 forKey:@"FrontFlag"];
    [dic setSafeObject:@47 forKey:@"TypeID"];

    [GDService requestWithFunctionName:@"get_sys_dict" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            NSArray *arr = reObj;
            NSDictionary *dic = [arr safeObjectAtIndex:0];
            SharedDelegate.todoFreshTime = [dic objectForKey:@"ID"];
            [SharedDelegate freshTimer];
        }
        [self closeSelf];
    }];

}
#pragma mark - actions -
- (void)closeSelf {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (void)closeKeyBoard {
    [self.userNameTF resignFirstResponder];
    [self.secretTF resignFirstResponder];
}
- (IBAction)autoLoginClicked:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected) {
        btn.selected = NO;
        self.isAutoLogin = NO;
    }else{
        btn.selected = YES;
        self.isAutoLogin = YES;
    }
}
- (IBAction)rememberClicked:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected) {
        btn.selected = NO;
        self.isRememberPass = NO;
    }else{
        btn.selected = YES;
        self.isRememberPass = YES;
    }
}
- (IBAction)loginClicked:(id)sender {
    [self login];
}
- (void)saveInfoToLocal {
    if (self.isAutoLogin) {
        [[NSUserDefaults standardUserDefaults] setObject:__BOOL(YES) forKey:@"isAutoLogin"];
        NSLog(@"%d",YES);
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:__BOOL(NO) forKey:@"isAutoLogin"];
    }
    if (self.isRememberPass) {
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameTF.text forKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] setObject:self.secretTF.text forKey:@"PassWord"];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PassWord"];//setObject:__BOOL(YES) forKey:@"ISREMEMBERPASS"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.userNameTF resignFirstResponder];
    [self.secretTF resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
