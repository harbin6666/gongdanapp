//
//  GDMainHandleVC.m
//  gongdanApp
//
//  Created by 薛翔 on 14-2-25.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDMainHandleVC.h"
#import "GDAppointVC.h"
#import "RBCustomDatePickerView.h"
#import "GDServiceV2.h"
#import "GDWebView.h"
#import "FlySpeech.h"
#import "PhoneViewPoper.h"
#import "GDUpSearchView.h"
#import "GDTextView.h"
@interface GDMainHandleVC ()<UIWebViewDelegate,PhoneViewPoperDelegate>
@property (weak, nonatomic) IBOutlet UIButton *topbarBaseInfoBtn;//基本信息
@property (weak, nonatomic) IBOutlet UIButton *topbarDetailInfoBtn;//预处理
@property (weak, nonatomic) IBOutlet UIButton *topBarHistoryBtn;//追单
@property (weak, nonatomic) IBOutlet UIButton *topBarAlermBtn;//告警百科
@property (nonatomic,weak)  IBOutlet UIView *topbar;
@property (weak, nonatomic) IBOutlet UIButton *bottomDetailBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomProgressRecordBtn;//进程记录


@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *formFlowView;
@property (weak, nonatomic) IBOutlet UIScrollView *followScrollView;
@property(nonatomic, strong) PhoneViewPoper *viewPoper;//picker
@property (nonatomic,strong) NSMutableDictionary *detailDic;//订单详情结果


@property (nonatomic, strong) NSMutableDictionary *basedInfoDic;
@property (nonatomic, strong) NSString *T2Time;
@property (nonatomic, strong) NSArray *detailInfoArr;
@property (nonatomic, strong) NSMutableDictionary *dealDic;
@property (nonatomic, strong) NSString *handleExpStr;
@property (nonatomic, strong) NSArray *formFlowArr,*alarmBKArr;

@property (nonatomic, strong)UIImagePickerController *imagePickerController;
//@property (nonatomic, strong)UIPickerView *picker;
@property (nonatomic, strong)NSString *formNo;
@property (nonatomic, strong)UIButton *handleTimeBtn;
@property (nonatomic, strong)UITextField *handlerTF;

// 处理工单部分
@property (nonatomic, strong)NSMutableArray *causeOneArr;
@property (nonatomic, strong)NSMutableArray *causeTwoArr;
@property (nonatomic, strong)NSMutableArray *causeThreeArr;
@property (nonatomic, strong)NSArray *reasonIdArr;
@property (nonatomic, strong)NSMutableArray *handleMethodIdArr;
@property (nonatomic, strong)NSArray *dealWaySortArr; // 获取故障大类
@property (nonatomic, strong)NSArray *mutableInfoArr; // 带了一二三及归因信息的ARR
//
@property (nonatomic, strong)NSDictionary *selReasonOneDic;
@property (nonatomic, strong)NSDictionary *selReasonTwoDic;
@property (nonatomic, strong)NSDictionary *selReasonThreeDic;
@property (nonatomic, strong)NSDictionary *selHandleMethodDic;
@property (nonatomic, strong)NSDictionary *selDealWaySortDic;
@property (nonatomic, strong)NSString *selHandleTime;
@property (nonatomic, strong)NSString *handlerName;
//
@property (nonatomic, strong)UIButton *reasonCateBtn;
@property (nonatomic, strong)UIButton *detailReasonCateBtn;
@property (nonatomic, strong)UIButton *reasonBtn;
@property (nonatomic, strong)UIButton *dealWaySortBtn;
@property (nonatomic, strong)UITextView *reasonTF;//故障原因
@property (nonatomic, strong)UITextView* gaojinTV;//告警核实的理由
@property (nonatomic, strong)UIView* newb;//告警核实浮层
@property (nonatomic, strong)UIButton *handleMethodBtn;
@property (nonatomic, strong)UITextView *methodTV;//处理措施
@property (nonatomic, strong)UIButton *yuyingBtn;
@property (nonatomic)BOOL isLeader;
@property (nonatomic)FormState formState;
@property (nonatomic)FormSearchState formSearchState;
@property (nonatomic)FormType formType;
@property (nonatomic,strong)NSString *isFullClear;

@property (weak, nonatomic) IBOutlet UITextView *rejectTF;
@property (nonatomic, strong)NSString *alarmId;
@property (nonatomic)CGSize handleMethodStrSize;

@property (nonatomic, strong)UIView *photoPopView;
@property (nonatomic, strong)UIImageView *prePhotoImageView;
@property (nonatomic, strong)UIImage *selPhotoImage;

@property (nonatomic, strong)RBCustomDatePickerView *datePicker;
@property (strong, nonatomic) IBOutlet UIView *rejectView;
@property (nonatomic, strong)OTSViewPoper *popBg;
@property (nonatomic, strong)UIButton *vendorBtn,*equiltBtn;
@property (nonatomic, strong) NSMutableArray *equitArr ,*vendorHubResultArr,*vendorArr,*btsArr;
@property (nonatomic, assign) BOOL donghuan;//动环类型工单

@property (nonatomic, strong) UIView *searchview;
@property (nonatomic, strong) NSString *btsName;
@property (nonatomic) NSInteger isPowerAlarmId;
@property (nonatomic,strong) UITextView*btsTxtV;
@property (nonatomic, strong)NSString *cleartime;
@end

@implementation GDMainHandleVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
- (id)initWithFormNo:(NSString*)formNo formType:(FormType)formType formsearchState:(FormSearchState)formsearchState formState:(FormState)formeState {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.formNo = formNo;
        self.formType = formType;
        self.formState = formeState;
        self.formSearchState = formsearchState;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"故障工单处理";
    [self bottomBarBtnClicked:self.bottomDetailBtn];
    [self topBarBtnClicked:self.topbarBaseInfoBtn];
    [self.mainScrollView setAlwaysBounceVertical:YES];
    self.handleMethodStrSize = CGSizeMake(184, 50);
    self.handlerName = [NSString stringWithFormat:@"%@ %@",SharedDelegate.userZhName,SharedDelegate.userTelNum] ;
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer:ges];
    
    [self getTheUserIsLeader];
}

#pragma mark - service -
- (void)readTheForm {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    [dic setSafeObject:__INT(10) forKey:@"OperateType"];
    [dic setSafeObject:[self dateToNSString:[NSDate date]] forKey:@"OperateTime"];
#warning 不晓得传啥值
    [dic setSafeObject:@"11111111111" forKey:@"MessageId"];
    
    [self showLoading];
    [GDService requestWithFunctionName:@"set_read_state" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = reObj;
            if (((NSNumber*)[dic objectForKey:@"Flag"]).intValue != 0) {
                NSString *desc = [dic objectForKey:@"Desc"];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"失败" message:desc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }else{
               // [self.navigationController popToRootViewControllerAnimated:YES];
                [self showOperateOKAlert];
            }
        }
    }];
    //http://10.19.116.148:8899/alarm/set_read_state/?{"FormNo":"ID-051-130910-00852","OperateType":10,"OperateTime":"2013-08-16 13:15:26","Operator":"test","MessageId":"11111111111"}
}
- (void)acceptTheForm {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Dealor"];
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    [dic setSafeObject:__INT(3) forKey:@"FormState"];
    [dic setSafeObject:[self dateToNSString:[NSDate date]] forKey:@"StartTime"];
    [dic setSafeObject:@"2" forKey:@"PfType"];

    [self showLoading];
    [GDService requestWithFunctionName:@"set_form_state" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = reObj;
            //int state = ((NSNumber*)[dic objectForKey:@"Flag"]).intValue;
            NSString *str = [dic objectForKey:@"Flag"];
            if ([str isEqualToString:@"成功"]){//(state == 0) {
                //NSString *desc = [dic objectForKey:@"Desc"];
                //[self.navigationController popToRootViewControllerAnimated:YES];
                [self showOperateOKAlert];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"受理失败" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
    //http://10.19.116.148:8899/alarm/set_form_state/?{"FormNo":"SD-051-130815-1643","StartTime":"2013-08-16 09:00:00","Dealor":"dd"," FormState":0}
}

//flag：1阶段回复2告警核实、3获取清除时间4延时申请 返回结果（失败 成功）；清除时间（Flag=3）
- (void)gaojingAction:(NSString *)flag doc:(NSString*)doc{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Dealor"];
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    [dic setSafeObject:flag forKey:@"Flag"];
    [dic setSafeObject:[self dateToNSString:[NSDate date]] forKey:@"StartTime"];
    [dic setSafeObject:@"2" forKey:@"PfType"];
    [dic setSafeObject:doc forKey:@"Doc"];
    [dic setSafeObject:SharedDelegate.userTelNum forKey:@"Tel"];
    [dic setSafeObject:SharedDelegate.company forKey:@"CompName"];
    [dic setSafeObject:SharedDelegate.dept forKey:@"UnitName"];
    
    
    [self showLoading];
    [GDService requestWithFunctionName:@"set_commit_ext" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = reObj;
            //3是清除时间
            if (flag.intValue!=3) {
                [self showResAlert:dic[@"Res"]];
            }else{
#warning 获取清除时间
                NSString *time=dic[@"Res"];
            }
        }
    }];

}
- (void)rejectTheForm {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    [dic setSafeObject:__INT(7) forKey:@"OperateType"];
    [dic setSafeObject:[self dateToNSString:[NSDate date]] forKey:@"OperateTime"];
    [dic setSafeObject:self.rejectTF.text forKey:@"Cause"];
    
    [self showLoading];
    [GDService requestWithFunctionName:@"set_reject_state" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = reObj;
            if (((NSNumber*)[dic objectForKey:@"Flag"]).intValue != 0) {
                NSString *desc = [dic objectForKey:@"Desc"];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"驳回失败" message:desc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }else{
                //[self.navigationController popToRootViewControllerAnimated:YES];
                [self showOperateOKAlert];
            }
        }
    }];
    //http://10.19.116.148:8899/alarm/set_reject_state/?{"FormNo":"ID-051-130910-00845","OperateType":7,"OperateTime":"2013-08-16 13:15:26","Operator":"admin","Cause":"工单不合理"}
}
- (void)getTheUserIsLeader {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    
    [self showLoading];
    [GDService requestWithFunctionName:@"get_user_groupflag" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        //[self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = reObj;
            self.isLeader = ((NSNumber*)[dic objectForKey:@"Flag"]).boolValue;
        }
#warning 老的接口
//        [self getBasedInfo:nil];
#warning 新的接口
        [self getDetail];
    }];
    //http://10.19.116.148:8899/alarm/get_user_groupflag/?{"Operator":"fangmin"}
}
#pragma mark 合并这2个接口
//- (void)getBasedInfo:(id)sender {
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    //[dic setSafeObject:@"HN-051-130810-00036" forKey:@"FormNo"];
//    [dic setSafeObject:self.formNo forKey:@"FormNo"];
//    
//    //[self showLoading];
//    [GDService requestWithFunctionName:@"get_form_base" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
//        [self hideLoading];
//        if ([reObj isKindOfClass:[NSDictionary class]]) {
//            self.basedInfoDic = reObj;
//            self.T2Time = [self.basedInfoDic objectForKey:@"T2Time"];
//            [self updateDisplayView];
//            [self getDetailInfo:nil];
//            //[self getHandleExp:nil];
//        }
//        [self getFormFlow:nil];
//    }];
//    //http://10.19.116.148:8899/alarm/get_form_base/?{"FormNo":"HN-051-130810-00036"}
//}
//- (void)getDetailInfo:(id)sender {
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    //[dic setSafeObject:@"HN-051-130810-00036" forKey:@"FormNo"];
//    [dic setSafeObject:self.formNo forKey:@"FormNo"];
//    
//    [GDService requestWithFunctionName:@"get_form_detail" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
//        if ([reObj isKindOfClass:[NSArray class]]) {
//            self.detailInfoArr = reObj;
//            if (self.topbarDetailInfoBtn.selected) {
//                [self updateDisplayView];
//            }
//        }
//    }];
//    //http://10.19.116.148:8899/alarm/get_form_detail/?{"FormNo":"HN-051-130810-00036"}
//}


-(void)getAlarmBK{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:self.alarmId forKey:@"AlarmId"];

    [GDServiceV2 requestFunc:@"cpt_get_alarm_bk" WithParam:dic withCompletBlcok:^(id reObj, NSError *error) {
        if (error==nil&&[reObj isKindOfClass:[NSArray class]]) {
            self.alarmBKArr = reObj;
        }
    }];
}

-(void)updateAlarmBKView{

    for (UIView* aView in self.mainScrollView.subviews) {
        [aView removeFromSuperview];
    }
    
    float yPositon = 5;

    NSArray *arr=self.alarmBKArr;
    BOOL gaojin=NO;
    for (int i=0; i<arr.count; i++) {
        NSDictionary *dic=arr[i];
        NSString *left=dic[@"Key"];
        NSString *right=[dic[@"Value"] decodeBase64];
        NSLog(@"---------\n   %@",right);
        
        CGSize size=[right sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(0.75*self.view.frame.size.width-10, 5000)];
        
        if (size.height<30) {
            size=CGSizeMake(200, 25);
        }
        
        float newHigh=size.height;
        if (newHigh>25) {
            newHigh+=20;
        }
        GDTextView*t2=[[GDTextView alloc] initWithFrame:CGRectMake(0.25*self.view.frame.size.width+5, yPositon, 0.75*self.view.frame.size.width, newHigh)]
        ;
        t2.contentInset=UIEdgeInsetsMake(-7, 0, 0, 0);
        t2.font=[UIFont systemFontOfSize:16];
        t2.alwaysBounceVertical=YES;
        t2.backgroundColor=[UIColor clearColor];
        t2.scrollEnabled=NO;
        t2.text=right;
        t2.editable=NO;
        
        GDTextView *t=[[GDTextView alloc] initWithFrame:CGRectMake(5, yPositon, 0.25*self.view.frame.size.width, newHigh)];
        t.contentInset=UIEdgeInsetsMake(-7, 0, 0, 0);
        t.alwaysBounceVertical=YES;
        t.font=[UIFont systemFontOfSize:16];
        t.backgroundColor=[UIColor clearColor];
        t.scrollEnabled=NO;
        t.text=[NSString stringWithFormat:@"%@:",left];
        t.editable=NO;
        if (gaojin==NO) {
            [self.mainScrollView addSubview:t];
            [self.mainScrollView addSubview:t2];
        }else{
            
        }
        yPositon+=newHigh;
        
    }
    yPositon+=5;

}
-(void)getDetail{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    self.formNo=@"HB-051-141224-23086";
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    [GDServiceV2 requestFunc:@"wo_get_form_info" WithParam:dic withCompletBlcok:^(id reObj, NSError *error) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            self.detailDic =(NSMutableDictionary*)reObj;
            NSLog(@"%@",reObj);
            self.T2Time = [self.detailDic objectForKey:@"T2Time"];
            self.alarmId=[self.detailDic objectForKey:@"Alarm_id"];
            self.btsName=[self.detailDic objectForKey:@"BtsName"];
            self.cleartime=[self.detailDic objectForKey:@"ClearTime"];
            self.isPowerAlarmId=[self.detailDic[@"isPowerAlarmId"] integerValue];
#warning 网络一级分类为：动力设备， ID： 101010406
            if ([[self.detailDic objectForKey:@"NetSort_one"] isEqualToString:@"101010406"]) {
                self.donghuan=YES;
            }
            if (self.topbarBaseInfoBtn.selected) {
                [self updateDisplayView];
            }

        }
        [self getFormFlow:nil];
        [self getAlarmBK];
        [self updateFollowView];
    }];
    
}
#pragma mark --设备与厂商的关系
-(void)getEquipMapBlock:(void(^)())anBlock{
    [self showLoading];
    [GDService requestWithFunctionName:@"get_vendor_hub" pramaDic:nil requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            NSMutableArray *arr = (NSMutableArray*)reObj;
            self.vendorHubResultArr=[[NSMutableArray alloc] initWithArray:arr copyItems:YES];
            if (arr.count > 0) {
                NSMutableArray *temp=[NSMutableArray array];
                for (NSDictionary*dic in arr) {
                    BOOL content=NO;
                        for (NSString* equit in temp) {
                            if ([equit isEqualToString:dic[@"EquipClassName"]]) {
                                content=YES;
                                break;
                            }
                        }
                    if (!content) {
                        [temp addObject:dic[@"EquipClassName"]];
                    }else{
                        continue;
                    }
                }
                
                NSLog(@"%@",temp);
                self.equitArr=temp;
                if (anBlock) {
                    anBlock();
                }
                
            }
        }
    }];

}

#pragma mark -----
- (void)getHandleExp:(id)sender { // 接口不可用
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:[self.basedInfoDic objectForKey:@"AlarmTitleOrg"] forKey:@"Title"];
    [dic setSafeObject:__INT(1) forKey:@"Subject"];
    [dic setSafeObject:[self.basedInfoDic objectForKey:@"NetType"] forKey:@"ObjClass"];
    [dic setSafeObject:[self.basedInfoDic objectForKey:@"VendorId"] forKey:@"ManuID"];
    
    [GDService requestWithFunctionName:@"get_exp" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        if ([reObj isKindOfClass:[NSArray class]]) {
            NSArray *arr = reObj;
            if (arr.count > 0) {
                NSDictionary *dic = [arr safeObjectAtIndex:0];
                self.handleExpStr = [dic objectForKey:@"S1"];
            }
        }
    }];
    //http://10.19.116.148:8899/alarm/get_exp/?{"Subject":1,"ManuID":5,"ObjClass":200,"Title":"系统无License运行告警"}
}
- (void)getFormFlow:(id)sender {
    if (self.formFlowArr == nil) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        //[dic setSafeObject:@"HN-051-130810-00036" forKey:@"FormNo"];
        [dic setSafeObject:self.formNo forKey:@"FormNo"];
        
//        [GDService requestWithFunctionName:@"get_form_flow" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
//            if ([reObj isKindOfClass:[NSArray class]]) {
//                self.formFlowArr = reObj;
//                [self updateFormView];
//            }
//        }];
        [GDServiceV2 requestFunc:@"wo_get_form_flow" WithParam:dic withCompletBlcok:^(id reObj, NSError *error) {
            if (error==nil&&[reObj isKindOfClass:[NSArray class]]) {
                self.formFlowArr = reObj;
                [self updateFormView];
            }
        }];
    }
    
    //http://10.19.116.148:8899/alarm/get_form_flow/?{"FormNo":"HN-051-130810-00036"}
}
- (void)getCauseOne:(void(^)())anBlock {
    if (self.causeOneArr && self.causeOneArr.count > 0) {
        if (anBlock) {
            anBlock();
        }
        return;
    }
    [self showLoading];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.isPowerAlarmId==0) {
        [dic setSafeObject:__INT(0) forKey:@"Flag"];
    }else{
        [dic setSafeObject:__INT(4) forKey:@"Flag"];
    }
    [GDService requestWithFunctionName:@"get_fault_cause" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.causeOneArr = reObj;
        }
        if (anBlock) {
            anBlock();
        }
    }];
    //http://10.19.116.148:8899/alarm/get_fault_cause/?{"Flag":3,"Class1":6,"Class2":20,"Class3":213}
}
- (void)getCauseTwo:(void(^)())anBlock {
    if (self.selReasonOneDic == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请先选择归因一级" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
//    if (self.causeTwoArr && self.causeTwoArr.count > 0) {
//        if (anBlock) {
//            anBlock();
//        }
//        return;
//    }
    [self showLoading];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:__INT(1) forKey:@"Flag"];
    [dic setSafeObject:[self.selReasonOneDic objectForKey:@"O1"] forKey:@"Class1"];
    [GDService requestWithFunctionName:@"get_fault_cause" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.causeTwoArr = reObj;
        }
        if (anBlock) {
            anBlock();
        }
    }];
}


- (void)getCauseThree:(void(^)())anBlock {
    if (self.selReasonTwoDic == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请先选择归因二级" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
//    if (self.causeThreeArr && self.causeThreeArr.count > 0) {
//        if (anBlock) {
//            anBlock();
//        }
//        return;
//    }
    [self showLoading];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:[self.selReasonOneDic objectForKey:@"O1"] forKey:@"OneCauseID"];
    [dic setSafeObject:[self.selReasonTwoDic objectForKey:@"O1"] forKey:@"TwoCauseID"];
    [GDService requestWithFunctionName:@"get_three_hub" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.causeThreeArr = reObj;
        }
        if (anBlock) {
            anBlock();
        }
    }];
}
// 暂时没用此接口
- (void)getReason:(void(^)())anBlock {
    if (self.selReasonTwoDic == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请先选择原因细分" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:__INT(2) forKey:@"Flag"];
    [dic setSafeObject:[self.selReasonOneDic objectForKey:@"O1"] forKey:@"Class1"];
    [dic setSafeObject:[self.selReasonTwoDic objectForKey:@"O1"] forKey:@"Class2"];
    [GDService requestWithFunctionName:@"get_fault_cause" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.reasonIdArr = reObj;
        }
        if (anBlock) {
            anBlock();
        }
    }];
}
// 获取处理措施
- (void)getHandleMethod:(void(^)())anBlock {
    if (self.dealWaySortBtn && self.selDealWaySortDic == nil) { // 当有原因类别的时候先选择原因类别
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请先选择原因类别" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }else{
        [self getDealWaySortHeadedInfo:^{
            if (anBlock) {
                anBlock();
            }
        }];
    }
//    if (self.selDealWaySortDic && self.dealWaySortBtn) { // 选择了特殊条件
//        [self getDealWaySortHeadedInfo:^{
//            if (anBlock) {
//                anBlock();
//            }
//        }];
//        
//    }else{ // 不是湖北的情况
//        [self showLoading];
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setSafeObject:self.alarmId forKey:@"AlarmID"];
//        [dic setSafeObject:self.formNo forKey:@"FormNo"];
//        [GDService requestWithFunctionName:@"get_deal_way" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
//            [self hideLoading];
//            if ([reObj isKindOfClass:[NSArray class]]) {
//                self.handleMethodIdArr = reObj;
//            }
//            if (anBlock) {
//                anBlock();
//            }
//        }];
//    }
    //http://120.202.255.70:8080/alarmtest/get_deal_way/?{%22AlarmID%22:%22603-075-00-075001%22}
}

- (void)getDealWaySort:(void(^)())anBlock { // 获取故障大类
    [self showLoading];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:self.alarmId forKey:@"AlarmID"];
    [GDService requestWithFunctionName:@"get_deal_way_sort" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.dealWaySortArr = reObj;
        }
        if (anBlock) {
            anBlock();
        }
    }];
    //http://120.202.255.70:8080/alarmtest/get_deal_way/?{%22AlarmID%22:%22603-075-00-075001%22}
}

- (void)getDealWaySortHeadedInfo:(void(^)())anBlock {
    [self showLoading];
    self.causeOneArr = [NSMutableArray array];
    self.causeTwoArr = [NSMutableArray array];
    self.causeThreeArr = [NSMutableArray array];
    self.handleMethodIdArr = [NSMutableArray array];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:self.alarmId forKey:@"AlarmID"];
    [dic setSafeObject:[self.selDealWaySortDic objectForKey:@"Sort"] forKey:@"Sort"];
    [GDService requestWithFunctionName:@"get_deal_way_hub" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.mutableInfoArr = reObj;
            for (NSInteger i = 0; i<_mutableInfoArr.count; i++) {
                NSDictionary *dic = [_mutableInfoArr safeObjectAtIndex:i];
                
                NSMutableDictionary *oneDic = [NSMutableDictionary dictionary];
                [oneDic setSafeObject:[dic objectForKey:@"OneCause"] forKey:@"S1"];
                [oneDic setSafeObject:[dic objectForKey:@"OneCauseID"] forKey:@"O1"];
                [self.causeOneArr addObject:oneDic];
                
                NSMutableDictionary *twoDic = [NSMutableDictionary dictionary];
                [twoDic setSafeObject:[dic objectForKey:@"TwoCause"] forKey:@"S1"];
                [twoDic setSafeObject:[dic objectForKey:@"TwoCauseID"] forKey:@"O1"];
                [self.causeTwoArr addObject:twoDic];
                
                NSMutableDictionary *threeDic = [NSMutableDictionary dictionary];
                [threeDic setSafeObject:[dic objectForKey:@"ThreeCause"] forKey:@"Value"];
                [threeDic setSafeObject:[dic objectForKey:@"ThreeCauseID"] forKey:@"Key"];
                [self.causeThreeArr addObject:threeDic];
                
                NSMutableDictionary *dealDic = [NSMutableDictionary dictionary];
                [dealDic setSafeObject:[dic objectForKey:@"DealWayID"] forKey:@"ID"];
                [dealDic setSafeObject:[dic objectForKey:@"DealWay"] forKey:@"RoomName"];
                [self.handleMethodIdArr addObject:dealDic];
            }
        }
        if (anBlock) {
            anBlock();
        }
    }];
}

- (void)uploadPhoto {
    NSData *data = UIImageJPEGRepresentation(self.selPhotoImage, 1.0);
    [self showLoading];
    [GDService requestWithFunctionName:@"FMS_UPLOAD_FILE" uploadData:data completion:^(id reObj) {
        [self hideLoading];
        if (reObj) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"图片上传成功" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.tag = 301;
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"上传图片失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        
    }];
}

- (void)submitHandle:(void(^)())anBlock {
    if ([self.detailDic[@"isFullClear"] intValue]==0) {
        [self showResAlert:@"有告警没有恢复时间，无法回单"];
        return;
    }
    
    if (self.methodTV.text==nil||[self.methodTV.text isEqualToString:@""]) {
        [self warnNotice:@"处理措施未填写"];
        return;
    }

    if (self.selReasonOneDic==nil) {
        [self warnNotice:@"归因一级未填写"];
        return;
    }
    if (self.selReasonTwoDic==nil) {
        [self warnNotice:@"归因二级未填写"];
        return;
    }
    if (self.selReasonThreeDic==nil) {
        [self warnNotice:@"归因三级未填写"];
        return;
    }
    if (self.reasonTF.text==nil||[self.reasonTF.text isEqualToString:@""]) {
        [self warnNotice:@"故障原因未填写"];
        return;
    }


    if (self.donghuan&&([self.vendorBtn.titleLabel.text isEqualToString:@""]||self.vendorBtn.titleLabel.text==nil)) {
        [self warnNotice:@"请选择设备名称及厂家"];
        return;
    }
    if (self.cleartime==nil||[self.cleartime isEqualToString:@""]) {
        [self warnNotice:@"没有清除时间"];
        return;
    }
    
    

    if (self.cleartime!=nil&&![self.cleartime isEqualToString:@""]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        NSDate *clearDate = [dateFormatter dateFromString:self.cleartime];
        NSDate *handleTime=[dateFormatter dateFromString:self.selHandleTime];
        if ([handleTime compare:clearDate]==NSOrderedDescending) {
            [self warnNotice:@"采取措施时间要不晚于告警清除时间"];
            return;
        }
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    [dic setSafeObject:self.handleTimeBtn.titleLabel.text forKey:@"startTime"];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Dealor"];
    [dic setSafeObject:__INT(4) forKey:@"FromState"];
    
    [dic setSafeObject:[NSString stringWithFormat:@"%@",[self.selReasonOneDic objectForKey:@"O1"]]forKey:@"CauseOne"];
    [dic setSafeObject:[NSString stringWithFormat:@"%@",[self.selReasonTwoDic objectForKey:@"O1"]] forKey:@"CauseTwo"];
    [dic setSafeObject:[NSString stringWithFormat:@"%@",[self.selReasonThreeDic objectForKey:@"Key"]] forKey:@"CauseThree"];
    
    [dic setSafeObject:self.reasonTF.text forKey:@"FaultCause"];
    [dic setSafeObject:self.T2Time forKey:@"T2Time"];
    
    [dic setSafeObject:self.methodTV.text forKey:@"DealWay"];
    [dic setSafeObject:self.handlerTF.text forKey:@"FaultDealor"];
    [dic setSafeObject:nil forKey:@"Fault_classification"];
    [dic setSafeObject:nil forKey:@"Fault_backcase"];
#warning 动环厂商名字
    [dic setSafeObject:self.vendorBtn.titleLabel.text forKey:@"VendorName"];
    [dic setSafeObject:@"2" forKey:@"PfType"];
    [self showLoading];
    [GDService requestWithFunctionName:@"set_state_last" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = reObj;
            NSString *str = [dic objectForKey:@"Flag"];
            if ([str isEqualToString:@"成功"]) {
                [self showOperateOKAlert];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"操作失败" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        if (anBlock) {
            anBlock();
        }
    }];
    
    //http://10.19.116.148:8899/alarm/set_state_last/?{"FormNo":"HN-051-130813-00291","startTime":"2013-08-16 09:00:00","Dealor":"dd","FromState":4,"CauseOne":"安全事件","CauseTwo":"安全设备故障","FaultCause":"掉线故障原因是由于AP长时间工作导致吊死","DealWay":"设备重启后正常","Fault_classification":"101031001","Fault_backcase":"","FaultDealor":"卢建国 138XXXX1234"}
}
#pragma mark - actions -

- (void)showOperateOKAlert {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"操作成功" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 300;
    [alert show];
}
-(void)showResAlert:(NSString*)res{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:res message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 300;
    [alert show];

}
- (void)cancelBtnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)topBarBtnClicked:(id)sender {
    UIButton *selBtn = (UIButton*)sender;
    if (selBtn.tag==2) {
        if (![self.detailDic[@"NetSort_one"] isEqualToString:@"101010401"]) {
            [self warnNotice:@"网元不是基站，没有预处理信息"];
            return;
        }
    }
    if (self.searchview!=nil) {
        [self.searchview removeFromSuperview];
    }
    self.topbarBaseInfoBtn.selected = NO;
    self.topbarDetailInfoBtn.selected = NO;
    self.topBarHistoryBtn.selected = NO;
    self.topBarAlermBtn.selected = NO;
    selBtn.selected = YES;
    switch (selBtn.tag) {
        case 1:{
            self.mainScrollView.hidden=NO;
            self.followScrollView.hidden=YES;
            [self updateDisplayView];
        }
            break;
        case 2:
            self.mainScrollView.hidden=NO;
            self.followScrollView.hidden=YES;
            [self updatePreHandleView];
            break;
        case 3: {
            self.mainScrollView.hidden=YES;
            self.followScrollView.hidden=NO;

        }
            break;
        case 4: {
            self.mainScrollView.hidden=NO;
            self.followScrollView.hidden=YES;
            [self updateAlarmBKView];
        }
            break;

        default:
            break;
    }
    
}
- (IBAction)bottomBarBtnClicked:(id)sender {
    UIButton *selBtn = (UIButton*)sender;
    self.bottomDetailBtn.selected = NO;
    self.bottomProgressRecordBtn.selected = NO;
   

    switch (selBtn.tag) {
        case 1:{
            //
            //self.mainTextView.text = @"第一个TAB内容";
            self.mainScrollView.hidden=NO;
            self.formFlowView.hidden=YES;
            self.topbar.hidden=NO;
            if (self.topBarHistoryBtn.selected==NO) {
                self.followScrollView.hidden=YES;
            }else{
                self.followScrollView.hidden=NO;
            }
//            [self.view sendSubviewToBack:self.formFlowView];
            if (self.searchview!=nil) {
                [self.searchview setHidden:NO];
            }
        }
            break;
        case 2: {//240 248 164
            //
            //self.mainTextView.text = @"第二个TAB内容";
            self.topbar.hidden=YES;
            self.mainScrollView.hidden=YES;
            self.formFlowView.hidden=NO;
            self.followScrollView.hidden=YES;
            if (self.searchview!=nil) {
                [self.searchview setHidden:YES];
            }
            //            [self.view bringSubviewToFront:self.formFlowView];
        }
            break;
            default:
            break;
    }
    selBtn.selected = YES;
}

- (void)rejectBtnClicked {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否驳回工单" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"驳回",nil];
    alert.tag = 100;
    [alert show];
}
- (void)acceptBtnClicked {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否受理工单" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"受理",nil];
    alert.tag = 102;
    [alert show];
}

- (void)submitBackBtnClicked:(id)sender {
    [self submitHandle:^{
        //
    }];
}
- (void)copyBtnClicked:(id)sender {
    GDAppointVC *avc = [[GDAppointVC alloc]initWithFormNo:self.formNo type:1];
    avc.type = 1;
    [self.navigationController pushViewController:avc animated:YES];
}
- (void)warnNoData:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"没有数据" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)warnNotice:(NSString *)notice{
    [[[UIAlertView alloc]initWithTitle:@"提示" message:notice delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
- (void)dealMenuClicked:(id)sender {
    [self.methodTV resignFirstResponder];
    [self.reasonTF resignFirstResponder];
    UIButton *btn = (UIButton*)sender;
    
    switch (btn.tag) {
        case 1: {
            [self getCauseOne:^{
                if (self.causeOneArr.count > 0) {
                    [self showPicker:sender];
                }else{
                    [self warnNoData:@""];//@"get_fault_cause"];
                }
            }];
        }
            break;
        case 2: {
            [self getCauseTwo:^{
                if (self.causeTwoArr.count > 0) {
                    [self showPicker:sender];
                }else{
                    [self warnNoData:@""];//[self warnNoData:@"get_fault_cause"];
                }
            }];
        }
            break;
        case 3: {
            [self getCauseThree:^{
                if (self.causeThreeArr.count > 0) {
                    [self showPicker:sender];
                }else{
                    [self warnNoData:@""];
                }
            }];
//            [self getReason:^{
//                if (self.reasonIdArr.count > 0) {
//                    [self showPicker:sender];
//                }else{
//                   [self warnNoData:@"请手动填写"];
//                }
//            }];
        }
            break;
        case 4: {
            [self getHandleMethod:^{
                if (self.handleMethodIdArr.count > 0) {
                    [self showPicker:sender];
                }else{
                    [self warnNoData:@""];//[self warnNoData:@"get_deal_way"];
                }
            }];
            break;
        }
        case 5: {
            [self showDateSel:sender];
        }
            break;
        case 6: {
            [self getDealWaySort:^{
                if (self.dealWaySortArr.count > 0) {
                    [self showPicker:sender];
                }else{
                    [self warnNoData:@""];//[self warnNoData:@"get_deal_way"];
                }
            }];
            break;
        }
        case 7:{//设备名称
            [self getEquipMapBlock:^{
                [self showPicker:sender];
            }];
        }
            break;
        case 8:{//设备厂家名称
            NSString *equiltName=self.equiltBtn.titleLabel.text;
            if ([equiltName isEqualToString: @""]||equiltName==nil) {
                [self warnNoData:@"请选择设备名称"];
            }else{
                if (self.vendorArr==nil) {
                    self.vendorArr=[[NSMutableArray alloc] init];
                }
                for (NSDictionary *dic in self.vendorHubResultArr) {
                    if ([equiltName isEqualToString:dic[@"EquipClassName"]]) {
                        [self.vendorArr addObject:dic[@"EquipVendorName"]];
                    }
                }
                [self showPicker:sender];
            }
        }
            break;
        default:
            break;
    }
}
- (void)showDateSel:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    self.viewPoper=[[PhoneViewPoper alloc] init];
    self.viewPoper.pickerView.tag=btn.tag;
    self.datePicker=[[RBCustomDatePickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 200)];//
    self.datePicker.backgroundColor=[UIColor whiteColor];
    [self.viewPoper.popView addSubview:self.datePicker];
    self.viewPoper.delegate=self;
    [self.viewPoper showPopView];

    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定",nil];
//    actionSheet.tag = btn.tag;
//    self.datePicker = [[RBCustomDatePickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];//[[UIDatePicker alloc]initWithFrame:CGRectZero];
//    //_datePicker.datePickerMode = UIDatePickerModeDate;
//    _datePicker.tag = btn.tag;
//    [actionSheet addSubview:_datePicker];
//    
//    [actionSheet showInView:SharedDelegate.window];
}
- (void)showPicker:(id)sender {
    UIButton *btn = (UIButton*)sender;

    self.viewPoper=[[PhoneViewPoper alloc] init];
    self.viewPoper.pickerView.tag=btn.tag;
    self.viewPoper.delegate=self;
    [self.viewPoper showPopView];
    
//    UIButton *btn = (UIButton*)sender;
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定",nil];
//    
//    self.picker = [[UIPickerView alloc]initWithFrame:CGRectZero];
//    _picker.tag = btn.tag;
//    _picker.showsSelectionIndicator = YES;
//    self.picker.delegate = self;
//    self.picker.dataSource = self;
//    [actionSheet addSubview:_picker];
//    actionSheet.tag = btn.tag;
//    [actionSheet showInView:SharedDelegate.window];
}

- (void)toPhoto {
    
    self.photoPopView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 300)];
    self.photoPopView.backgroundColor = [UIColor yellowColor];//[UIColor colorWithRed:240.0/255 green:248.0/255 blue:164.0/255 alpha:1.0];
    [self.view addSubview:_photoPopView];
    
    UIButton *openBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-110, 20, 90, 41)];
    [openBtn setBackgroundImage:[UIImage imageNamed:@"openCamera"] forState:UIControlStateNormal];
    [openBtn setBackgroundImage:[UIImage imageNamed:@"openCamera_sel"] forState:UIControlStateHighlighted];
    [openBtn addTarget:self action:@selector(openCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.photoPopView addSubview:openBtn];
    
    self.prePhotoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(320-120, 70, 100, 140)];
    self.prePhotoImageView.backgroundColor = [UIColor lightGrayColor];
    [self.photoPopView addSubview:_prePhotoImageView];
    
    openBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-220, 300-80, 90, 36)];
    [openBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [openBtn setBackgroundImage:[UIImage imageNamed:@"back_sel"] forState:UIControlStateHighlighted];
    [openBtn addTarget:self action:@selector(backOnPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.photoPopView addSubview:openBtn];
    
    openBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-110, 300-80, 90, 36)];
    [openBtn setBackgroundImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];
    [openBtn setBackgroundImage:[UIImage imageNamed:@"upload_sel"] forState:UIControlStateHighlighted];
    [openBtn addTarget:self action:@selector(upLoadPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.photoPopView addSubview:openBtn];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.photoPopView.frame = CGRectMake(0, self.view.frame.size.height-300, 320, 300);
    } completion:^(BOOL finished) {}];
}

- (void)openCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController=[[UIImagePickerController alloc] init];
        _imagePickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
        _imagePickerController.videoQuality=UIImagePickerControllerQualityTypeLow;
        //_imagePickerController.allowsEditing=YES;
        _imagePickerController.delegate = self;
        [self presentViewController:_imagePickerController animated:YES completion:^{
        }];
    }
}
- (void)backOnPhoto {
    [UIView animateWithDuration:0.3 animations:^{
        self.photoPopView.frame = CGRectMake(0, self.view.frame.size.height, 320, 300);
    } completion:^(BOOL finished) {
        [self.photoPopView removeFromSuperview];
    }];
}

- (void)upLoadPhoto:(id)sender {
    if (self.selPhotoImage) {
        [self uploadPhoto];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请先拍照" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
- (void)showRejectView {
    [self.view addSubview:self.rejectView];
}
- (IBAction)cancelReject:(id)sender {
    [self.rejectView removeFromSuperview];
}
- (IBAction)submitReject:(id)sender {
    [self rejectTheForm];
}

-(void)gaojingheshiClicked:(id)sender{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否申请告警核实" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"申请",nil];
//    alert.tag = 400;
//    [alert show];
    self.newb=[[UIView alloc] initWithFrame:self.view.bounds];
    self.newb.backgroundColor=[UIColor colorWithWhite:0.3 alpha:0.5];
    [self.view addSubview:self.newb];
    
    UILabel*lab=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 30)];
    lab.backgroundColor=[UIColor colorWithRed:58/255.0 green:127/255.0 blue:206/255.0 alpha:1];
    lab.text=@"告警核实";
    lab.textColor=[UIColor whiteColor];
    [self.newb addSubview:lab];
    
    UIView *content=[[UIView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 120)];
    content.backgroundColor=[UIColor whiteColor];
    [self.newb addSubview:content];
    UILabel *liyou=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 60)];
    liyou.text=@"核实\n理由";
    liyou.numberOfLines=2;
    liyou.textAlignment=NSTextAlignmentCenter;
    [content addSubview:liyou];
    
    self.gaojinTV=[[UITextView alloc] initWithFrame:CGRectMake(40, 10, self.view.frame.size.width-50, 60)];
    self.gaojinTV.layer.borderWidth=2;
    self.gaojinTV.layer.borderColor=[UIColor orangeColor].CGColor;
    self.gaojinTV.layer.cornerRadius=2;
    [content addSubview:self.gaojinTV];
    UIButton* ok=[UIButton buttonWithType:UIButtonTypeCustom];
    [ok setTitle:@"提交" forState:UIControlStateNormal];
    [ok setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    ok.backgroundColor=[UIColor colorWithRed:58/255.0 green:127/255.0 blue:206/255.0 alpha:1];
    [ok addTarget:self action:@selector(submitGaojin:) forControlEvents:UIControlEventTouchUpInside];
    ok.frame=CGRectMake(0, 0, 80, 30);
    ok.center=CGPointMake(self.view.frame.size.width/4, 100);
    [content addSubview:ok];
    
    UIButton* cancel=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancel.backgroundColor=[UIColor colorWithRed:205/255.0 green:127/255.0 blue:19/255.0 alpha:1];
    [cancel addTarget:self action:@selector(cancelGaojin) forControlEvents:UIControlEventTouchUpInside];
    cancel.frame=CGRectMake(0, 0, 80, 30);
    cancel.center=CGPointMake(self.view.frame.size.width*3/4, 100);
    [content addSubview:cancel];

}

-(void)cancelGaojin{
    [self.gaojinTV resignFirstResponder];
    [self.newb removeFromSuperview];
}

-(void)submitGaojin:(id)sender{
    if (self.gaojinTV.text.length>0) {
        [self.gaojinTV resignFirstResponder];
        [self gaojingAction:@"2" doc:self.gaojinTV.text];
    }else{
        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"" message:@"请填写理由" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}
-(void)newFuncClick:(UIButton*)btn{
    NSString *txt=nil;
    if (btn.tag==900) {//阶段回复
        txt=@"阶段回复";
    }else if (btn.tag==901){//申请延期
        txt=@"申请延期";
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:txt message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    alert.tag = btn.tag;
    [alert show];
}

- (void)closeKeyboard {
    //[self.handlerTF resignFirstResponder];
    [self.rejectTF resignFirstResponder];
    //[self.reasonTF resignFirstResponder];
    //[self.methodTV resignFirstResponder];
}


-(void)yuyingBtn:(id)sender{
    [[FlySpeech sharedInstance] startRecognizer:self.view comletion:^(NSString *yuyingresult) {
        self.reasonTF.text=yuyingresult;
        [[FlySpeech sharedInstance] quitRecgnizer];
    }];
}
#pragma mark - imagePickerImage -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    self.selPhotoImage = image;
    [self.prePhotoImageView setImage:_selPhotoImage];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark 追单
-(void)updateFollowView{
    for (UIView* aView in self.followScrollView.subviews) {
        [aView removeFromSuperview];
    }
    NSString*text=self.detailDic[@"packinfo"];
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:CGSizeMake(300, 2000)];

    UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, size.height)];
    lab.backgroundColor=[UIColor clearColor];
    lab.font=[UIFont systemFontOfSize:16];
//    lab.translatesAutoresizingMaskIntoConstraints=NO;
    lab.text=text;
    lab.numberOfLines=0;
    [self.followScrollView addSubview:lab];
    self.followScrollView.contentSize=CGSizeMake(self.view.frame.size.width, size.height+10);
//    self.followScrollView.translatesAutoresizingMaskIntoConstraints=NO;
//    [self.followScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[lab]-(>=0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lab)]];
//    
//    [self.followScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lab]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lab)]];
}
#pragma mark - update 工作流程图
- (void)updateFormView {//更新流程视图
    for (UIView* aView in self.formFlowView.subviews) {
        [aView removeFromSuperview];
    }
    int yPositon = 5;
    int rightXposition = 90;
    
//    UILabel *theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, yPositon, 80, 20)];
//    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
//    theStaticLabel.backgroundColor = [UIColor clearColor];
//    
//    NSString *str = nil;
//    CGSize size = CGSizeZero;
//    UILabel *theRightLabel = [[UILabel alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 220, size.height)];
//    theRightLabel.backgroundColor = [UIColor clearColor];
//    theRightLabel.font = [UIFont systemFontOfSize:16.0];
//    theRightLabel.numberOfLines = 0;
//    theRightLabel.text = str;
    
    for (NSDictionary *dic in self.formFlowArr) {
        //NSString *key = [dic objectForKey:@"Key"];
        NSString *Result = [dic objectForKey:@"Result"] ;
        NSData *data=[Result dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error=nil;
        NSArray *arr= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        for (int i=0; i<arr.count; i++) {
            NSDictionary *dic=arr[i];
            NSString *left=dic[@"Key"];
            NSString *right=[dic[@"Value"] decodeBase64];
            CGSize size=[right sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(0.75*self.view.frame.size.width-20, 5000)];
            
//            if (size.height<30) {
//                size=CGSizeMake(200, 25);
//            }
            
            float newHigh=size.height;
//            if (newHigh>25) {
//                newHigh+=20;
//            }
            UILabel*t2=[[UILabel alloc] initWithFrame:CGRectMake(0.25*self.view.frame.size.width+5, yPositon, 0.75*self.view.frame.size.width-20, newHigh)]
            ;
            t2.numberOfLines=0;
            t2.font=[UIFont systemFontOfSize:16];
            t2.backgroundColor=[UIColor clearColor];
            t2.text=right;
            
            UILabel *t=[[UILabel alloc] initWithFrame:CGRectMake(5, yPositon, 0.25*self.view.frame.size.width, newHigh)];
            t.font=[UIFont systemFontOfSize:16];
            t.backgroundColor=[UIColor clearColor];
            t.text=[NSString stringWithFormat:@"%@:",left];
            [self.formFlowView addSubview:t];
            [self.formFlowView addSubview:t2];
            yPositon+=newHigh+2;

        }
        yPositon+=20;
//        theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, yPositon, 80, 20)];
//        theStaticLabel.font = [UIFont systemFontOfSize:16.0];
//        theStaticLabel.backgroundColor = [UIColor clearColor];
//        theStaticLabel.text = @"sdf:";//[NSString stringWithFormat:@"%@：",key];
//        
//        str = value;
//        size = [str sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:CGSizeMake(300, 2000)];
//        theRightLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 300, size.height)];
//        theRightLabel.backgroundColor = [UIColor clearColor];
//        theRightLabel.font = [UIFont systemFontOfSize:16.0];
//        theRightLabel.numberOfLines = 0;
//        theRightLabel.text = str;
//        
//        yPositon += size.height>20?size.height+10:30;
//        //[self.formFlowView addSubview:theStaticLabel];
//        [self.formFlowView addSubview:theRightLabel];
    }
    self.formFlowView.contentSize = CGSizeMake(320, yPositon);
}
#pragma mark 更新详情图优化

//预处理界面
-(void)updatePreHandleView{
    for (UIView* aView in self.mainScrollView.subviews) {
        [aView removeFromSuperview];
    }
    self.searchview=[[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 100)];
    self.searchview.backgroundColor = [UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1.0];
    [self.view addSubview:self.searchview];
    
    
    UILabel*theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 80, 20)];
    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
    theStaticLabel.backgroundColor = [UIColor clearColor];
    theStaticLabel.textColor=[UIColor blackColor];
    theStaticLabel.text = @"基站名称：";
    [self.searchview addSubview:theStaticLabel];
    
    UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake(100, 10, self.view.frame.size.width/2, 30)];
    bg.image = [[UIImage imageNamed:@"dealInputFrame"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
    [self.searchview addSubview:bg];
    
    self.btsTxtV = [[UITextView alloc]initWithFrame:bg.frame];
    self.btsTxtV.tag = 10086;
    self.btsTxtV.delegate = self;
    self.btsTxtV.font = [UIFont systemFontOfSize:14.0];
    self.btsTxtV.backgroundColor = [UIColor clearColor];
    self.btsTxtV.text=self.btsName;
    //self.reasonTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.searchview addSubview:self.btsTxtV];

    UIButton *searchBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame=CGRectMake(100+self.view.frame.size.width/2, 10, 30, 30);
    [searchBtn addTarget:self action:@selector(searchbts:) forControlEvents:UIControlEventTouchUpInside];
    searchBtn.tag=9;
    [searchBtn setImage:[UIImage imageNamed:@"searchviewbtn"] forState:UIControlStateNormal];
    [self.searchview addSubview:searchBtn];
    
    UIButton *queryBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    queryBtn.frame=CGRectMake(100+self.view.frame.size.width/2, 10, 80, 30);
    queryBtn.center=CGPointMake(160, 65);
    [queryBtn addTarget:self action:@selector(queryAction:) forControlEvents:UIControlEventTouchUpInside];
    [queryBtn setBackgroundImage:[UIImage imageNamed:@"gaojingheshi"] forState:UIControlStateNormal];
    [queryBtn setTitle:@"查询" forState:UIControlStateNormal];
    [self.searchview addSubview:queryBtn];
    [self queryAction:nil];
}

-(void)searchbts:(id)sender{
    [self.btsTxtV resignFirstResponder];

    if (self.btsTxtV.text==nil||[self.btsTxtV.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"查询条件为空" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
        return;
    }
    [self showLoading];
    NSMutableDictionary *prama=@{@"ServiceName":@"get_bts_name",@"Function":@"mq_bts"}.mutableCopy;
    prama[@"BtsName"]=self.btsTxtV.text;
    
    [GDService requestWithFunctionName:@"mq_bts" pramaDic:prama requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]&&[reObj count]) {
            self.btsArr=(NSMutableArray*)reObj;
            [self showPicker:sender];
        }else{
            [self warnNoData:nil];
        }
        
    }];
}

-(void)queryAction:(id)sender{
    NSMutableDictionary *prama=[NSMutableDictionary dictionary];
    prama[@"UserId"]=SharedDelegate.loginedUserName;
    if (sender==nil&&self.btsName!=nil&&![self.btsName isEqualToString:@""]) {
        prama[@"BtsName"]=self.btsName;
    }else{
        if (self.btsTxtV.text==nil||[self.btsTxtV.text isEqualToString:@""]) {
            [[[UIAlertView alloc] initWithTitle:@"查询条件为空" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
            return;
        }
        prama[@"BtsName"]=self.btsTxtV.text;
    }
    [self showLoading];
    [GDServiceV2 requestFunc:@"wo_get_form_sheetinfo" WithParam:prama withCompletBlcok:^(id reObj, NSError *error) {
        [self hideLoading];
        if (error==nil&&[reObj isKindOfClass:[NSDictionary class]]) {
            for (UIView* aView in self.mainScrollView.subviews) {
                [aView removeFromSuperview];
            }

            NSDictionary *result=(NSDictionary*)reObj;
            GDTextView*textview=[[GDTextView alloc] initWithFrame: CGRectMake(0,0, self.view.frame.size.width, self.mainScrollView.contentSize.height)];

            textview.backgroundColor=[UIColor clearColor];
            textview.scrollEnabled=NO;
            textview.editable=NO;
            textview.font=[UIFont systemFontOfSize:14];
            NSString *txt=[result[@"Result"] decodeBase64];

            [self.mainScrollView addSubview:textview];
            CGSize size=[txt sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(self.view.frame.size.width-20, 800)];
            self.mainScrollView.contentSize=CGSizeMake(self.view.frame.size.width, size.height+100);
            textview.frame=CGRectMake(10,100, self.view.frame.size.width-20, self.mainScrollView.contentSize.height);
            textview.contentSize=CGSizeMake(self.view.frame.size.width-20, self.mainScrollView.contentSize.height);

            textview.contentInset=UIEdgeInsetsMake(10, 10, 10, 10);
            textview.text = txt;

        }
    }];
}
- (void)updateDisplayView {
    for (UIView* aView in self.mainScrollView.subviews) {
        [aView removeFromSuperview];
    }
    
    float yPositon = 5;
    float rightXposition = 0.25*self.view.frame.size.width;
    if (self.detailDic==nil||self.detailDic.count==0) {
        return;
    }
    NSArray *arr=self.detailDic[@"Result"];
    BOOL gaojin=NO;
    for (int i=0; i<arr.count; i++) {
        NSDictionary *dic=arr[i];
        NSString *left=dic[@"Key"];
        NSString *right=[dic[@"Value"] decodeBase64];
        NSLog(@"---------\n   %@",right);
        
        if ([left isEqualToString:@"清除时间"]&&self.formState == FormState_doing&&(self.cleartime==nil||[self.cleartime isEqualToString:@""])) {
            gaojin=YES;
            continue;
        }else{
            gaojin=NO;
        }

        
        CGSize size=[right sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(0.75*self.view.frame.size.width-10, 5000)];

        if (size.height<30) {
            size=CGSizeMake(200, 25);
        }
        
        float newHigh=size.height;
        if (newHigh>25) {
            newHigh+=20;
        }
        GDTextView*t2=[[GDTextView alloc] initWithFrame:CGRectMake(0.25*self.view.frame.size.width+5, yPositon, 0.75*self.view.frame.size.width, newHigh)]
        ;
        t2.contentInset=UIEdgeInsetsMake(-7, 0, 0, 0);
        t2.font=[UIFont systemFontOfSize:16];
        t2.alwaysBounceVertical=YES;
        t2.backgroundColor=[UIColor clearColor];
        t2.scrollEnabled=NO;
        t2.text=right;
        t2.editable=NO;
        
        GDTextView *t=[[GDTextView alloc] initWithFrame:CGRectMake(5, yPositon, 0.25*self.view.frame.size.width, newHigh)];
        t.contentInset=UIEdgeInsetsMake(-7, 0, 0, 0);
        t.alwaysBounceVertical=YES;
        t.font=[UIFont systemFontOfSize:16];
        t.backgroundColor=[UIColor clearColor];
        t.scrollEnabled=NO;
        t.text=[NSString stringWithFormat:@"%@:",left];
        t.editable=NO;
        if (gaojin==NO) {
            [self.mainScrollView addSubview:t];
            [self.mainScrollView addSubview:t2];
        }else{
            
        }
        yPositon+=newHigh;

    }
    yPositon+=5;
    [self infoDealwithY:yPositon rightXposition:rightXposition checkalert:gaojin];
}
     
-(void)infoDealwithY:(float)yPositon rightXposition:(float)rightXposition checkalert:(BOOL)b{
     if (self.topbarBaseInfoBtn.selected && self.formType == FormType_todo) {  // 基本信息特殊处理
         
         if (self.formState == FormState_doing) {
             [self updateDealViewWithYposition:yPositon checkAlert:b];
             return;
         }
         else if (self.formState == FormState_todo) {
             // 操作按钮
             if (self.isLeader) {  // 班组长才有权限
                 // 指定
                 UIButton *appointBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 79, 26)];
                 [appointBtn setTitle:@"指定" forState:UIControlStateNormal];
                 appointBtn.backgroundColor = [UIColor redColor];
                 appointBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
                 [appointBtn setImage:[UIImage imageNamed:@"appoint"] forState:UIControlStateNormal];
                 [appointBtn setImage:[UIImage imageNamed:@"appoint_sel"] forState:UIControlStateHighlighted];
                 [appointBtn addTarget:self action:@selector(appointBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                 [self.mainScrollView addSubview:appointBtn];
             }
             // 受理
             UIButton *acceptBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+84, yPositon, 79, 26)];
             [acceptBtn setTitle:@"受理" forState:UIControlStateNormal];
             [acceptBtn setImage:[UIImage imageNamed:@"accept"] forState:UIControlStateNormal];
             [acceptBtn setImage:[UIImage imageNamed:@"accept_sel"] forState:UIControlStateHighlighted];
             acceptBtn.backgroundColor = [UIColor redColor];
             acceptBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
             [acceptBtn addTarget:self action:@selector(acceptBtnClicked) forControlEvents:UIControlEventTouchUpInside];
             [self.mainScrollView addSubview:acceptBtn];
             
             // 驳回
             UIButton *rejectBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+84+84, yPositon, 79, 26)];
             [rejectBtn setTitle:@"驳回" forState:UIControlStateNormal];
             [rejectBtn setImage:[UIImage imageNamed:@"reject"] forState:UIControlStateNormal];
             [rejectBtn setImage:[UIImage imageNamed:@"reject_sel"] forState:UIControlStateHighlighted];
             rejectBtn.backgroundColor = [UIColor redColor];
             rejectBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
             [rejectBtn addTarget:self action:@selector(rejectBtnClicked) forControlEvents:UIControlEventTouchUpInside];
             [self.mainScrollView addSubview:rejectBtn];
             //无权限则隐藏
             if (!SharedDelegate.reject) {
                 rejectBtn.hidden=YES;
             }
         }
     }
     else if (self.formType == FormType_copy && self.topbarBaseInfoBtn.selected) {
         
         UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+84, yPositon, 79, 26)];
         [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
         [cancelBtn setBackgroundImage:[UIImage imageNamed:@"operBtn"] forState:UIControlStateNormal];
         [cancelBtn setBackgroundImage:[UIImage imageNamed:@"operBtn"] forState:UIControlStateHighlighted];
         [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
         cancelBtn.backgroundColor = [UIColor clearColor];
         [self.mainScrollView addSubview:cancelBtn];
         // 已阅
         UIButton *readFormBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+84+84, yPositon, 79, 26)];
         [readFormBtn setTitle:@"已阅" forState:UIControlStateNormal];
         [readFormBtn setBackgroundImage:[UIImage imageNamed:@"operBtn"] forState:UIControlStateNormal];
         [readFormBtn setBackgroundImage:[UIImage imageNamed:@"operBtn_sel"] forState:UIControlStateHighlighted];
         readFormBtn.backgroundColor = [UIColor redColor];
         readFormBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
         [readFormBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         [readFormBtn addTarget:self action:@selector(readTheForm) forControlEvents:UIControlEventTouchUpInside];
         [self.mainScrollView addSubview:readFormBtn];
         
     }
     yPositon += 50;
     self.mainScrollView.contentSize = CGSizeMake(320, yPositon);
     
}
//已受理的时候
- (void)updateDealViewWithYposition:(int)y checkAlert:(BOOL)gaojin{
//    for (UIView* aView in self.mainScrollView.subviews) {
//        [aView removeFromSuperview];
//    }
    int yPositon = y;
    int rightXposition = 90;
    
    UILabel *theStaticLabel;
    UIButton *menu;
    if (gaojin) {
        
        theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
        theStaticLabel.font = [UIFont systemFontOfSize:16.0];
        theStaticLabel.backgroundColor = [UIColor clearColor];
        theStaticLabel.text = @"清除时间：";
        [self.mainScrollView addSubview:theStaticLabel];

        menu=[UIButton buttonWithType:UIButtonTypeCustom];
        menu.frame=CGRectMake(rightXposition, yPositon, 180, 25);
        [menu setBackgroundImage:[UIImage imageNamed:@"gaojingheshi"] forState:UIControlStateNormal];
        [menu setBackgroundImage:[UIImage imageNamed:@"gaojingheshi"] forState:UIControlStateHighlighted];
        menu.titleLabel.font=[UIFont systemFontOfSize:16];
        [menu setTitle:@"申请告警核实" forState:UIControlStateNormal];
        [menu addTarget:self action:@selector(gaojingheshiClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainScrollView addSubview:menu];
        yPositon += 30;

    }

    // 超级第一行。蛋碎。只在 alarmID为WL-001-00-800003时出现
    if ([self.alarmId isEqualToString:@"WL-001-00-800003"]) {
        theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
        theStaticLabel.font = [UIFont systemFontOfSize:16.0];
        theStaticLabel.backgroundColor = [UIColor clearColor];
        theStaticLabel.text = @"原因类别：";
        
        self.dealWaySortBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, 25)];
        [self.dealWaySortBtn setBackgroundImage:[UIImage imageNamed:@"dealInputFrame"] forState:UIControlStateNormal];
        [self.dealWaySortBtn addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.dealWaySortBtn.tag = 6;
        self.dealWaySortBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self.dealWaySortBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.mainScrollView addSubview:self.dealWaySortBtn];
        
        [self.dealWaySortBtn setTitle:[self.selDealWaySortDic objectForKey:@"Sort"] forState:UIControlStateNormal];
        
        menu = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+184, yPositon-2, 30, 25)];
        [menu setBackgroundImage:[UIImage imageNamed:@"popMenuBtn"] forState:UIControlStateNormal];
        menu.tag = 6;
        [menu addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainScrollView addSubview:menu];
        
        yPositon += 30;
        
        [self.mainScrollView addSubview:theStaticLabel];
    }else{
        self.dealWaySortBtn = nil;
    }
    
    // 第四行， 提到第一行了
    theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
    theStaticLabel.backgroundColor = [UIColor clearColor];
    theStaticLabel.text = @"处理措施：";
    
    CGFloat handleMethodBtnHeight = self.handleMethodStrSize.height > 25 ? self.handleMethodStrSize.height+10 : 25;
    self.handleMethodBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, handleMethodBtnHeight)];
    [self.handleMethodBtn setBackgroundImage:[[UIImage imageNamed:@"dealInputFrame"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)] forState:UIControlStateNormal];
    [self.handleMethodBtn addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.handleMethodBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.handleMethodBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.handleMethodBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.handleMethodBtn.titleLabel.adjustsLetterSpacingToFitWidth = YES;
    self.handleMethodBtn.titleLabel.minimumScaleFactor = 0.5;
    self.handleMethodBtn.titleLabel.numberOfLines = 0;
    self.handleMethodBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    self.handleMethodBtn.tag = 4;
    //self.handleMethodBtn.enabled = NO;
    [self.mainScrollView addSubview:self.handleMethodBtn];
    
    //[self.handleMethodBtn setTitle:[self.selHandleMethodDic objectForKey:@"RoomName"] forState:UIControlStateNormal];
    
    self.methodTV = [[UITextView alloc]initWithFrame:self.handleMethodBtn.frame];
    self.methodTV.tag = 12;
    self.methodTV.delegate = self;
    self.methodTV.font = [UIFont systemFontOfSize:14.0];
    self.methodTV.backgroundColor = [UIColor clearColor];
    [self.mainScrollView addSubview:_methodTV];
    self.methodTV.text = [self.selHandleMethodDic objectForKey:@"RoomName"];
    
    menu = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+184, yPositon-2, 30, 25)];
    [menu setBackgroundImage:[UIImage imageNamed:@"popMenuBtn"] forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    menu.tag = 4;
    [self.mainScrollView addSubview:menu];
    
    yPositon += self.handleMethodBtn.frame.size.height+5;
    [self.mainScrollView addSubview:theStaticLabel];
    
    // 第一行
    theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
    theStaticLabel.backgroundColor = [UIColor clearColor];
    theStaticLabel.text = @"归因一级：";
    
    self.reasonCateBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, 25)];
    [self.reasonCateBtn setBackgroundImage:[UIImage imageNamed:@"dealInputFrame"] forState:UIControlStateNormal];
    [self.reasonCateBtn addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.reasonCateBtn.tag = 1;
    self.reasonCateBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.reasonCateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.mainScrollView addSubview:self.reasonCateBtn];
    
    [self.reasonCateBtn setTitle:[self.selReasonOneDic objectForKey:@"S1"] forState:UIControlStateNormal];
    
    menu = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+184, yPositon-2, 30, 25)];
    [menu setBackgroundImage:[UIImage imageNamed:@"popMenuBtn"] forState:UIControlStateNormal];
    menu.tag = 1;
    [menu addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:menu];
    
    yPositon += 30;
    
    [self.mainScrollView addSubview:theStaticLabel];
    
    // 第二行
    theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
    theStaticLabel.backgroundColor = [UIColor clearColor];
    theStaticLabel.text = @"归因二级：";
    
    self.detailReasonCateBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, 25)];
    [self.detailReasonCateBtn setBackgroundImage:[UIImage imageNamed:@"dealInputFrame"] forState:UIControlStateNormal];
    [self.detailReasonCateBtn addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.detailReasonCateBtn.tag = 2;
    self.detailReasonCateBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.detailReasonCateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.mainScrollView addSubview:self.detailReasonCateBtn];
    
    [self.detailReasonCateBtn setTitle:[self.selReasonTwoDic objectForKey:@"S1"] forState:UIControlStateNormal];
    
    menu = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+184, yPositon-2, 30, 25)];
    [menu setBackgroundImage:[UIImage imageNamed:@"popMenuBtn"] forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    menu.tag = 2;
    [self.mainScrollView addSubview:menu];

    yPositon += 30;
    [self.mainScrollView addSubview:theStaticLabel];
    
    // 第三行
    theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
    theStaticLabel.backgroundColor = [UIColor clearColor];
    theStaticLabel.text = @"归因三级：";
    
    self.reasonBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, 25)];
    [self.reasonBtn setBackgroundImage:[[UIImage imageNamed:@"dealInputFrame"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)] forState:UIControlStateNormal];
    [self.reasonBtn addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.reasonBtn.tag = 3;
    self.reasonBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.reasonBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.mainScrollView addSubview:self.reasonBtn];
    
    [self.reasonBtn setTitle:[self.selReasonThreeDic objectForKey:@"Value"] forState:UIControlStateNormal];
    
    menu = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+184, yPositon-2, 30, 25)];
    [menu setBackgroundImage:[UIImage imageNamed:@"popMenuBtn"] forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    menu.tag = 3;
    [self.mainScrollView addSubview:menu];
    
    yPositon += 30;
    [self.mainScrollView addSubview:theStaticLabel];
    
    // 第四行
    theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
    theStaticLabel.backgroundColor = [UIColor clearColor];
    theStaticLabel.text = @"故障原因：";
    
    
    UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, 50)];
    bg.image = [[UIImage imageNamed:@"dealInputFrame"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
    [self.mainScrollView addSubview:bg];
    
    self.reasonTF = [[UITextView alloc]initWithFrame:bg.frame];
    //self.reasonTF.borderStyle = UITextBorderStyleNone;
    //self.reasonTF.placeholder = @"请输入故障原因";
    self.reasonTF.tag = 11;
    self.reasonTF.delegate = self;
    self.reasonTF.font = [UIFont systemFontOfSize:14.0];
    self.reasonTF.backgroundColor = [UIColor clearColor];
    //self.reasonTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.mainScrollView addSubview:_reasonTF];
    
    self.yuyingBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+185, yPositon-2, 12, 22)];
    [self.yuyingBtn setBackgroundImage:[UIImage imageNamed:@"yuyin"]  forState:UIControlStateNormal];
    [self.yuyingBtn addTarget:self action:@selector(yuyingBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.reasonBtn.tag = 3;
    [self.yuyingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.mainScrollView addSubview:self.yuyingBtn];
    
    yPositon += 55;
    [self.mainScrollView addSubview:theStaticLabel];
    
    
    
    // 第五行
    theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
    theStaticLabel.backgroundColor = [UIColor clearColor];
    theStaticLabel.text = @"采取时间：";
    
    self.handleTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, 25)];
    [self.handleTimeBtn setBackgroundImage:[[UIImage imageNamed:@"dealInputFrame"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [self.handleTimeBtn setTag:5];
    self.handleTimeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.handleTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.handleTimeBtn addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:self.handleTimeBtn];
    
    if (self.cleartime!=nil&&![self.cleartime isEqualToString:@""]) {
        [self.handleTimeBtn setTitle:self.cleartime forState:UIControlStateNormal];
        self.selHandleTime=self.cleartime;
    }
//    NSDateFormatter *dateFor = [[NSDateFormatter alloc]init];
//    NSString * dateStr;
//    [dateFor setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
//    dateStr = [dateFor stringFromDate:[NSDate date]];
//    [self.handleTimeBtn setTitle:dateStr forState:UIControlStateNormal];
    
    menu = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+184, yPositon-2, 30, 25)];
    [menu setBackgroundImage:[UIImage imageNamed:@"popMenuBtn"] forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    menu.tag = 5;
    [self.mainScrollView addSubview:menu];
    
//    self.handleTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon+2, 184, 25)];
//    //self.handleTimeBtn.text = @"sdfsfsd";
//    self.handleTimeBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
//    self.handleTimeBtn.backgroundColor = [UIColor clearColor];
//    self.
//    [self.mainScrollView addSubview:self.handleTimeBtn];
    
    yPositon += 30;
    [self.mainScrollView addSubview:theStaticLabel];
    
    // 第六行
    theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
    theStaticLabel.backgroundColor = [UIColor clearColor];
    theStaticLabel.text = @"处理人：";
    
    UIButton *right = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, 25)];
    [right setBackgroundImage:[UIImage imageNamed:@"dealInputFrame"] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:right];
    
    
    self.handlerTF = [[UITextField alloc]initWithFrame:CGRectMake(rightXposition+3, yPositon, 181, 23)];
    self.handlerTF.backgroundColor = [UIColor clearColor];
    self.handlerTF.delegate = self;
    self.handlerTF.font = [UIFont systemFontOfSize:14.0];
    self.handlerTF.text = self.handlerName;
    [self.mainScrollView addSubview:self.handlerTF];
    
    yPositon += 30;
    [self.mainScrollView addSubview:theStaticLabel];
    //动环类，显示设备号
    if (self.donghuan) {
        theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
        theStaticLabel.font = [UIFont systemFontOfSize:16.0];
        theStaticLabel.backgroundColor = [UIColor clearColor];
        theStaticLabel.text = @"设备名称：";
        
        self.equiltBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, 25)];
        [self.equiltBtn setBackgroundImage:[UIImage imageNamed:@"equitFrame"] forState:UIControlStateNormal];
        [self.equiltBtn addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.equiltBtn.tag = 7;
        self.equiltBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self.equiltBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.mainScrollView addSubview:self.equiltBtn];
        
        [self.equiltBtn setTitle:[self.selReasonTwoDic objectForKey:@"S1"] forState:UIControlStateNormal];
        
        [self.mainScrollView addSubview:theStaticLabel];
        
        yPositon += 30;
        
        
        theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
        theStaticLabel.font = [UIFont systemFontOfSize:16.0];
        theStaticLabel.backgroundColor = [UIColor clearColor];
        theStaticLabel.text = @"设备厂家：";
        
        self.vendorBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, 25)];
        [self.vendorBtn setBackgroundImage:[UIImage imageNamed:@"equitFrame"] forState:UIControlStateNormal];
        [self.vendorBtn addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.vendorBtn.tag = 8;
        self.vendorBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self.vendorBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.mainScrollView addSubview:self.vendorBtn];
        
        [self.vendorBtn setTitle:[self.selReasonTwoDic objectForKey:@"S1"] forState:UIControlStateNormal];
        yPositon+=30;

        [self.mainScrollView addSubview:theStaticLabel];
    }

    
    rightXposition = 23+73;
    // 回单
    right = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/6, yPositon, self.view.frame.size.width*2/3, 27)];
    [right setBackgroundImage:[UIImage imageNamed:@"gaojingheshi"] forState:UIControlStateNormal];
//    [right setBackgroundImage:[UIImage imageNamed:@"handle_sel"] forState:UIControlStateHighlighted];
    [right setTitle:@"回单" forState:UIControlStateNormal];
    right.titleLabel.font=[UIFont systemFontOfSize:16];
    [right addTarget:self action:@selector(submitBackBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:right];
    
    yPositon+=32;
    //阶段回复
    right = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/9, yPositon, self.view.frame.size.width/3, 27)];
    [right setBackgroundImage:[UIImage imageNamed:@"gaojingheshi"] forState:UIControlStateNormal];
    //    [right setBackgroundImage:[UIImage imageNamed:@"handle_sel"] forState:UIControlStateHighlighted];
    [right setTitle:@"阶段回复" forState:UIControlStateNormal];
    right.titleLabel.font=[UIFont systemFontOfSize:16];
    right.tag=900;
    [right addTarget:self action:@selector(newFuncClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:right];
    
    //阶段回复
    right = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width*5/9, yPositon, self.view.frame.size.width/3, 27)];
    [right setBackgroundImage:[UIImage imageNamed:@"gaojingheshi"] forState:UIControlStateNormal];
    //    [right setBackgroundImage:[UIImage imageNamed:@"handle_sel"] forState:UIControlStateHighlighted];
    [right setTitle:@"申请延期" forState:UIControlStateNormal];
    right.tag=901;
    right.titleLabel.font=[UIFont systemFontOfSize:16];
    [right addTarget:self action:@selector(newFuncClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:right];
    

    
    //yPositon += 32;
    rightXposition += 73;
    
//    right = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 63, 27)];
//    [right setBackgroundImage:[UIImage imageNamed:@"preHandle"] forState:UIControlStateNormal];
//    [right setBackgroundImage:[UIImage imageNamed:@"preHandle_sel"] forState:UIControlStateHighlighted];
//    //[right addTarget:self action:@selector(submitBackBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.mainScrollView addSubview:right];
//    
//    rightXposition += 73;
    //抄送
//    right = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 63, 27)];
//    [right setBackgroundImage:[UIImage imageNamed:@"copyBtn"] forState:UIControlStateNormal];
//    [right setBackgroundImage:[UIImage imageNamed:@"copyBtn_sel"] forState:UIControlStateHighlighted];
//    [right addTarget:self action:@selector(copyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.mainScrollView addSubview:right];
    
    //yPositon += 32;
//    rightXposition += 73;
//    //拍照
//    right = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 63, 27)];
//    [right setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
//    [right setBackgroundImage:[UIImage imageNamed:@"takePhoto_sel"] forState:UIControlStateHighlighted];
//    [right addTarget:self action:@selector(toPhoto) forControlEvents:UIControlEventTouchUpInside];
//    [self.mainScrollView addSubview:right];
    
    yPositon += 47;
    
    self.mainScrollView.contentSize = CGSizeMake(320, yPositon);
}

- (void)appointBtnClicked:(id)sender {
    GDAppointVC * apVC = [[GDAppointVC alloc]initWithFormNo:self.formNo type:0];
    [self.navigationController pushViewController:apVC animated:YES];
}
- (CGSize)sizeWithData:(id)str {
    CGSize size = CGSizeZero;
//    if ([str isKindOfClass:[NSString class]]) {
//        size = [str sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:CGSizeMake(220, 2000)];
//    }else
    if ([str isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber*)str;
        str = number.stringValue;
    }
    size = [str sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:CGSizeMake(220, 2000)];
    return size;
}

#pragma mark - pickerview delegate -

/**
 *  功能:点击取消按钮
 */
- (void)viewPoper:(PhoneViewPoper *)aViewPoper cancelBtnClicked:(id)sender{
    [aViewPoper hidePopView];
}

/**
 *  功能:点击完成按钮
 */
- (void)viewPoper:(PhoneViewPoper *)aViewPoper finishBtnClicked:(id)sender{
    NSInteger row = [self.viewPoper.pickerView selectedRowInComponent:0];
    if (self.viewPoper.pickerView.tag == 1 ) {
        NSMutableDictionary *dic = [self.causeOneArr safeObjectAtIndex:row];
        NSString *str = [dic objectForKey:@"S1"];
        self.selReasonOneDic = dic;//[dic objectForKey:@"O1"];
        [self.reasonCateBtn setTitle:str forState:UIControlStateNormal];
#warning 判断动环工单O1:101010406 S1:动力设备
        if ([dic[@"S1"] isEqualToString:@"动力设备"]) {
            self.donghuan=YES;
        }else {
            self.donghuan=NO;
        }
        self.selReasonTwoDic=nil;
        self.selReasonThreeDic=nil;
        [self updateDisplayView];
    }else if (self.viewPoper.pickerView.tag == 2) {
        NSMutableDictionary *dic = [self.causeTwoArr safeObjectAtIndex:row];
        NSString *str = [dic objectForKey:@"S1"];
        self.selReasonTwoDic = dic;//[dic objectForKey:@"O1"];
        [self.detailReasonCateBtn setTitle:str forState:UIControlStateNormal];
        self.selReasonThreeDic=nil;
        [self updateDisplayView];
    }
    else if (self.viewPoper.pickerView.tag == 3) {
        NSMutableDictionary *dic = [self.causeThreeArr safeObjectAtIndex:row];
        NSString *str = [dic objectForKey:@"Value"];
        self.selReasonThreeDic = dic;//[dic objectForKey:@"O1"];
        [self.reasonBtn setTitle:str forState:UIControlStateNormal];
    }else if (self.viewPoper.pickerView.tag == 4) {
        NSMutableDictionary *dic = [self.handleMethodIdArr safeObjectAtIndex:row];
        NSString *str = [dic objectForKey:@"RoomName"];
        self.selHandleMethodDic = dic;//[dic objectForKey:@"O1"];
        
        //            if (self.selDealWaySortDic && self.dealWaySortBtn) {
        //                NSDictionary *infoDic = [self.mutableInfoArr safeObjectAtIndex:row];
        //
        //                NSMutableDictionary *oneDic = [NSMutableDictionary dictionary];
        //                [oneDic setSafeObject:[infoDic objectForKey:@"OneCause"] forKey:@"S1"];
        //                [oneDic setSafeObject:[infoDic objectForKey:@"OneCauseID"] forKey:@"01"];
        //                self.selReasonOneDic = oneDic;
        //
        //                NSMutableDictionary *twoDic = [NSMutableDictionary dictionary];
        //                [twoDic setSafeObject:[infoDic objectForKey:@"TwoCause"] forKey:@"S1"];
        //                [twoDic setSafeObject:[infoDic objectForKey:@"TwoCauseID"] forKey:@"01"];
        //                self.selReasonTwoDic = twoDic;
        //
        //                NSMutableDictionary *threeDic = [NSMutableDictionary dictionary];
        //                [threeDic setSafeObject:[infoDic objectForKey:@"ThreeCause"] forKey:@"Value"];
        //                [threeDic setSafeObject:[infoDic objectForKey:@"ThreeCauseID"] forKey:@"Key"];
        //                self.selReasonThreeDic = threeDic;
        //            }
        // 选择处理方式的时候自动带出一二三级归因
        NSDictionary *infoDic = [self.mutableInfoArr safeObjectAtIndex:row];
        
        NSMutableDictionary *oneDic = [NSMutableDictionary dictionary];
        [oneDic setSafeObject:[infoDic objectForKey:@"OneCause"] forKey:@"S1"];
        [oneDic setSafeObject:[infoDic objectForKey:@"OneCauseID"] forKey:@"O1"];
        self.selReasonOneDic = oneDic;
        
        NSMutableDictionary *twoDic = [NSMutableDictionary dictionary];
        [twoDic setSafeObject:[infoDic objectForKey:@"TwoCause"] forKey:@"S1"];
        [twoDic setSafeObject:[infoDic objectForKey:@"TwoCauseID"] forKey:@"O1"];
        self.selReasonTwoDic = twoDic;
        
        NSMutableDictionary *threeDic = [NSMutableDictionary dictionary];
        [threeDic setSafeObject:[infoDic objectForKey:@"ThreeCause"] forKey:@"Value"];
        [threeDic setSafeObject:[infoDic objectForKey:@"ThreeCauseID"] forKey:@"Key"];
        self.selReasonThreeDic = threeDic;
        
        CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(180, 2000)];
        self.handleMethodStrSize = size;
        [self updateDisplayView];
    }else if (self.viewPoper.pickerView.tag == 5) { // 时间选择
        NSDate *date = self.datePicker.date;
        //NSDate *todayDate = [NSDate date];
        NSDateFormatter *dateFor = [[NSDateFormatter alloc]init];
        NSString * dateStr;
        [dateFor setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        dateStr = [dateFor stringFromDate:date];
        self.selHandleTime = dateStr;
        [self.handleTimeBtn setTitle:dateStr forState:UIControlStateNormal];
    }else if (self.viewPoper.pickerView.tag == 6) {
        NSMutableDictionary *dic = [self.dealWaySortArr safeObjectAtIndex:row];
        NSString *str = [dic objectForKey:@"Sort"];
        self.selDealWaySortDic = dic;//[dic objectForKey:@"O1"];
        [self.dealWaySortBtn setTitle:str forState:UIControlStateNormal];
        //[self getDealWaySortHeadedInfo:^{}];
    }else if (self.viewPoper.pickerView.tag == 7) {
        NSString* str=[self.equitArr safeObjectAtIndex:row];
        [self.equiltBtn setTitle:str forState:UIControlStateNormal];
    }else if (self.viewPoper.pickerView.tag==8){
        NSString *str=[self.vendorArr safeObjectAtIndex:row];
        [self.vendorBtn setTitle:str forState:UIControlStateNormal];
    }else if (self.viewPoper.pickerView.tag==9){
        NSDictionary *dic=[self.btsArr safeObjectAtIndex:row];
        self.btsTxtV.text=dic[@"name"];
    }
    else{
        
    }

}

#pragma mark - picker view相关datasource和delegate
/**
 *  功能:picker view的componet数量
 */
- (NSInteger)viewPoper:(PhoneViewPoper *)aViewPoper numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

/**
 *  功能:picker view的componet的行数
 */
- (NSInteger)viewPoper:(PhoneViewPoper *)aViewPoper pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView.tag == 1) {
        return self.causeOneArr.count;
    }else if (pickerView.tag == 2) {
        return self.causeTwoArr.count;
    }else if (pickerView.tag == 3) {
        return self.causeThreeArr.count;
    }else if (pickerView.tag == 4) {
        return self.handleMethodIdArr.count;
    }else if (pickerView.tag == 6) {
        return self.dealWaySortArr.count;
    }else if (pickerView.tag==7){
        return self.equitArr.count;
    }else if (pickerView.tag==8){
        return self.vendorArr.count;
    }else if (pickerView.tag==9){
        return  self.btsArr.count;
    }
    else{
        //        NSMutableDictionary *dic = [self.gongdanLevelArr safeObjectAtIndex:row];
        //        NSString *str = [dic objectForKey:@"Name"];
        //        return str;
    }
    return 0;

}

/**
 *  功能:picker view每行的title
 */
- (NSString *)viewPoper:(PhoneViewPoper *)aViewPoper pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSMutableDictionary *dic;
    NSString *str;
    if (pickerView.tag == 1) {
        dic = [self.causeOneArr safeObjectAtIndex:row];
        str = [dic objectForKey:@"S1"];
    }else if (pickerView.tag == 2) {
        dic = [self.causeTwoArr safeObjectAtIndex:row];
        str = [dic objectForKey:@"S1"];
    }else if (pickerView.tag == 3) {
        dic = [self.causeThreeArr safeObjectAtIndex:row];
        str = [dic objectForKey:@"Value"];
    }else if (pickerView.tag == 4) {
        dic = [self.handleMethodIdArr safeObjectAtIndex:row];
        str = [dic objectForKey:@"RoomName"];
    }else{
        //        NSMutableDictionary *dic = [self.gongdanLevelArr safeObjectAtIndex:row];
        //        NSString *str = [dic objectForKey:@"Name"];
        //        return str;
    }
    return str;

}

-(UIView*)viewPoper:(PhoneViewPoper *)aViewPoper pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSMutableDictionary *dic;
    NSString *str;
    if (pickerView.tag == 1) {
        dic = [self.causeOneArr safeObjectAtIndex:row];
        str = [dic objectForKey:@"S1"];
    }else if (pickerView.tag == 2) {
        dic = [self.causeTwoArr safeObjectAtIndex:row];
        str = [dic objectForKey:@"S1"];
    }else if (pickerView.tag == 3) {
        dic = [self.causeThreeArr safeObjectAtIndex:row];
        str = [dic objectForKey:@"Value"];
    }else if (pickerView.tag == 4) {
        dic = [self.handleMethodIdArr safeObjectAtIndex:row];
        str = [dic objectForKey:@"RoomName"];
    }else if (pickerView.tag == 6) {
        dic = [self.dealWaySortArr safeObjectAtIndex:row];
        str = [dic objectForKey:@"Sort"];
    }else if (pickerView.tag==7){
        str=[self.equitArr safeObjectAtIndex:row];
    }else if (pickerView.tag==8){
        str=[self.vendorArr safeObjectAtIndex:row];
    }else if (pickerView.tag==9){
        NSDictionary *dic=[self.btsArr safeObjectAtIndex:row];
        str=dic[@"name"];
    }
    else{
        //        NSMutableDictionary *dic = [self.gongdanLevelArr safeObjectAtIndex:row];
        //        NSString *str = [dic objectForKey:@"Name"];
        //        return str;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16.0];
    label.adjustsFontSizeToFitWidth = YES;
    label.adjustsLetterSpacingToFitWidth = YES;
    label.minimumScaleFactor = 0.1;
    label.text = str;
    return label;

}



// returns the number of 'columns' to display.

// returns the # of rows in each component..
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    if (pickerView.tag == 1) {
//        return self.causeOneArr.count;
//    }else if (pickerView.tag == 2) {
//        return self.causeTwoArr.count;
//    }else if (pickerView.tag == 3) {
//        return self.causeThreeArr.count;
//    }else if (pickerView.tag == 4) {
//        return self.handleMethodIdArr.count;
//    }else if (pickerView.tag == 6) {
//        return self.dealWaySortArr.count;
//    }
//    else{
//        //        NSMutableDictionary *dic = [self.gongdanLevelArr safeObjectAtIndex:row];
//        //        NSString *str = [dic objectForKey:@"Name"];
//        //        return str;
//    }
//    return 0;
//}
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    NSMutableDictionary *dic;
//    NSString *str;
//    if (pickerView.tag == 1) {
//        dic = [self.causeOneArr safeObjectAtIndex:row];
//        str = [dic objectForKey:@"S1"];
//    }else if (pickerView.tag == 2) {
//        dic = [self.causeTwoArr safeObjectAtIndex:row];
//        str = [dic objectForKey:@"S1"];
//    }else if (pickerView.tag == 3) {
//        dic = [self.causeThreeArr safeObjectAtIndex:row];
//        str = [dic objectForKey:@"S1"];
//    }else if (pickerView.tag == 4) {
//        dic = [self.handleMethodIdArr safeObjectAtIndex:row];
//        str = [dic objectForKey:@"RoomName"];
//    }else{
////        NSMutableDictionary *dic = [self.gongdanLevelArr safeObjectAtIndex:row];
////        NSString *str = [dic objectForKey:@"Name"];
////        return str;
//    }
//    return str;
//}

//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
//    return 40;
//}
//
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    
//    NSMutableDictionary *dic;
//    NSString *str;
//    if (pickerView.tag == 1) {
//        dic = [self.causeOneArr safeObjectAtIndex:row];
//        str = [dic objectForKey:@"S1"];
//    }else if (pickerView.tag == 2) {
//        dic = [self.causeTwoArr safeObjectAtIndex:row];
//        str = [dic objectForKey:@"S1"];
//    }else if (pickerView.tag == 3) {
//        dic = [self.causeThreeArr safeObjectAtIndex:row];
//        str = [dic objectForKey:@"Value"];
//    }else if (pickerView.tag == 4) {
//        dic = [self.handleMethodIdArr safeObjectAtIndex:row];
//        str = [dic objectForKey:@"RoomName"];
//    }else if (pickerView.tag == 6) {
//        dic = [self.dealWaySortArr safeObjectAtIndex:row];
//        str = [dic objectForKey:@"Sort"];
//    }
//    else{
//        //        NSMutableDictionary *dic = [self.gongdanLevelArr safeObjectAtIndex:row];
//        //        NSString *str = [dic objectForKey:@"Name"];
//        //        return str;
//    }
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 40)];
//    label.backgroundColor = [UIColor clearColor];
//    label.numberOfLines = 0;
//    label.font = [UIFont systemFontOfSize:16.0];
//    label.adjustsFontSizeToFitWidth = YES;
//    label.adjustsLetterSpacingToFitWidth = YES;
//    label.minimumScaleFactor = 0.1;
//    label.text = str;
//    return label;
//}

#pragma mark - alertView & actionsheet & textfield & scrollview -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 300) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if (alertView.tag == 301) {
        [self backOnPhoto];
    }
    
    if (buttonIndex == 0) {
        
    }else{
        if (alertView.tag == 100) {
            [self showRejectView];
        }else if (alertView.tag == 101) {
            //[self rejectTheForm];
        }else if (alertView.tag == 102) {
            [self acceptTheForm];
        }else if (alertView.tag==400){
            [self gaojingAction:@"2" doc:@"告警核实"];
        }else if (alertView.tag==900){//阶段回复
            UITextField *tf=[alertView textFieldAtIndex:0];
            [self gaojingAction:@"1" doc:tf.text];
        }else if (alertView.tag==901){//申请延期
            UITextField *tf=[alertView textFieldAtIndex:0];
            [self gaojingAction:@"4" doc:tf.text];
        }
    }
}
-(void)dealloc{
    self.mainScrollView.delegate=nil;
    self.formFlowView.delegate=nil;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 11) {
        return;
    }
    [self closeKeyboard];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.tag==10086) {
        return;
    }
    CGRect rec = textView.frame;
    CGFloat offset = 216+20 - (self.mainScrollView.frame.size.height - rec.size.height- rec.origin.y);// + self.mainScrollView.contentOffset.y;
    
    //rec.origin.y - rec.size.height - self.mainScrollView.contentOffset.y + 20 - (self.mainScrollView.frame.size.height - 216.0);//键盘高度216
    [self.mainScrollView setContentOffset:CGPointMake(0, offset) animated:YES];
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView.tag==10086) {
        return YES;
    }

    [self.mainScrollView setContentOffset:CGPointMake(0, self.mainScrollView.contentSize.height-self.mainScrollView.frame.size.height) animated:YES];
    if (textView.text != nil) {
        if (textView.tag == 11) {
//            self.selReasonThreeDic = [NSMutableDictionary dictionary];
//            [self.selReasonThreeDic setValue:textView.text forKey:@"Value"];
        }else if (textView.tag == 12) {
            self.selHandleMethodDic = [NSMutableDictionary dictionary];
            [self.selHandleMethodDic setValue:textView.text forKey:@"RoomName"];
        }
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.methodTV resignFirstResponder];
        [self.reasonTF resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect rec = textField.frame;
    CGFloat offset = 216+20 - (self.mainScrollView.frame.size.height - rec.size.height- rec.origin.y);// + self.mainScrollView.contentOffset.y;
    
    //rec.origin.y - rec.size.height - self.mainScrollView.contentOffset.y + 20 - (self.mainScrollView.frame.size.height - 216.0);//键盘高度216
    [self.mainScrollView setContentOffset:CGPointMake(0, offset) animated:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.mainScrollView setContentOffset:CGPointMake(0, self.mainScrollView.contentSize.height-self.mainScrollView.frame.size.height) animated:YES];
    if (textField == self.handlerTF) {
        self.handlerName = textField.text;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self closeKeyboard];
    [self.handlerTF resignFirstResponder];
    return YES;
}
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (!buttonIndex) {
//        NSInteger row = [self.picker selectedRowInComponent:0];
//        if (actionSheet.tag == 1 ) {
//            NSMutableDictionary *dic = [self.causeOneArr safeObjectAtIndex:row];
//            NSString *str = [dic objectForKey:@"S1"];
//            self.selReasonOneDic = dic;//[dic objectForKey:@"O1"];
//            [self.reasonCateBtn setTitle:str forState:UIControlStateNormal];
//        }else if (actionSheet.tag == 2) {
//            NSMutableDictionary *dic = [self.causeTwoArr safeObjectAtIndex:row];
//            NSString *str = [dic objectForKey:@"S1"];
//            self.selReasonTwoDic = dic;//[dic objectForKey:@"O1"];
//            [self.detailReasonCateBtn setTitle:str forState:UIControlStateNormal];
//        }
//        else if (actionSheet.tag == 3) {
//            NSMutableDictionary *dic = [self.causeThreeArr safeObjectAtIndex:row];
//            NSString *str = [dic objectForKey:@"Value"];
//            self.selReasonThreeDic = dic;//[dic objectForKey:@"O1"];
//            [self.reasonBtn setTitle:str forState:UIControlStateNormal];
//        }else if (actionSheet.tag == 4) {
//            NSMutableDictionary *dic = [self.handleMethodIdArr safeObjectAtIndex:row];
//            NSString *str = [dic objectForKey:@"RoomName"];
//            self.selHandleMethodDic = dic;//[dic objectForKey:@"O1"];
//            
////            if (self.selDealWaySortDic && self.dealWaySortBtn) {
////                NSDictionary *infoDic = [self.mutableInfoArr safeObjectAtIndex:row];
////                
////                NSMutableDictionary *oneDic = [NSMutableDictionary dictionary];
////                [oneDic setSafeObject:[infoDic objectForKey:@"OneCause"] forKey:@"S1"];
////                [oneDic setSafeObject:[infoDic objectForKey:@"OneCauseID"] forKey:@"01"];
////                self.selReasonOneDic = oneDic;
////                
////                NSMutableDictionary *twoDic = [NSMutableDictionary dictionary];
////                [twoDic setSafeObject:[infoDic objectForKey:@"TwoCause"] forKey:@"S1"];
////                [twoDic setSafeObject:[infoDic objectForKey:@"TwoCauseID"] forKey:@"01"];
////                self.selReasonTwoDic = twoDic;
////                
////                NSMutableDictionary *threeDic = [NSMutableDictionary dictionary];
////                [threeDic setSafeObject:[infoDic objectForKey:@"ThreeCause"] forKey:@"Value"];
////                [threeDic setSafeObject:[infoDic objectForKey:@"ThreeCauseID"] forKey:@"Key"];
////                self.selReasonThreeDic = threeDic;
////            }
//            // 选择处理方式的时候自动带出一二三级归因
//            NSDictionary *infoDic = [self.mutableInfoArr safeObjectAtIndex:row];
//            
//            NSMutableDictionary *oneDic = [NSMutableDictionary dictionary];
//            [oneDic setSafeObject:[infoDic objectForKey:@"OneCause"] forKey:@"S1"];
//            [oneDic setSafeObject:[infoDic objectForKey:@"OneCauseID"] forKey:@"01"];
//            self.selReasonOneDic = oneDic;
//            
//            NSMutableDictionary *twoDic = [NSMutableDictionary dictionary];
//            [twoDic setSafeObject:[infoDic objectForKey:@"TwoCause"] forKey:@"S1"];
//            [twoDic setSafeObject:[infoDic objectForKey:@"TwoCauseID"] forKey:@"01"];
//            self.selReasonTwoDic = twoDic;
//            
//            NSMutableDictionary *threeDic = [NSMutableDictionary dictionary];
//            [threeDic setSafeObject:[infoDic objectForKey:@"ThreeCause"] forKey:@"Value"];
//            [threeDic setSafeObject:[infoDic objectForKey:@"ThreeCauseID"] forKey:@"Key"];
//            self.selReasonThreeDic = threeDic;
//            
//            CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(180, 2000)];
//            self.handleMethodStrSize = size;
//            [self updateDisplayView];
//        }else if (actionSheet.tag == 5) { // 时间选择
//            NSDate *date = self.datePicker.date;
//            //NSDate *todayDate = [NSDate date];
//            NSDateFormatter *dateFor = [[NSDateFormatter alloc]init];
//            NSString * dateStr;
//            [dateFor setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
//            dateStr = [dateFor stringFromDate:date];
//            self.selHandleTime = dateStr;
//            [self.handleTimeBtn setTitle:dateStr forState:UIControlStateNormal];
//        }else if (actionSheet.tag == 6) {
//            NSMutableDictionary *dic = [self.dealWaySortArr safeObjectAtIndex:row];
//            NSString *str = [dic objectForKey:@"Sort"];
//            self.selDealWaySortDic = dic;//[dic objectForKey:@"O1"];
//            [self.dealWaySortBtn setTitle:str forState:UIControlStateNormal];
//            //[self getDealWaySortHeadedInfo:^{}];
//        }else if (actionSheet.tag == 7) {
//        }else{
//            
//        }
//    }
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
