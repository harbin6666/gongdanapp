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

@interface GDMainHandleVC ()
@property (weak, nonatomic) IBOutlet UIButton *topbarBaseInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *topbarDetailInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *topBarHistoryBtn;

@property (weak, nonatomic) IBOutlet UIButton *bottomDetailBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomProgressRecordBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *formFlowView;

@property (nonatomic, strong) NSMutableDictionary *basedInfoDic;
@property (nonatomic, strong) NSString *T2Time;
@property (nonatomic, strong) NSArray *detailInfoArr;
@property (nonatomic, strong) NSMutableDictionary *dealDic;
@property (nonatomic, strong) NSString *handleExpStr;
@property (nonatomic, strong) NSArray *formFlowArr;

@property (nonatomic, strong)UIImagePickerController *imagePickerController;
@property (nonatomic, strong)UIPickerView *picker;
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
@property (nonatomic, strong)UITextView *reasonTF;
@property (nonatomic, strong)UIButton *handleMethodBtn;
@property (nonatomic, strong)UITextView *methodTV;

@property (nonatomic)BOOL isLeader;
@property (nonatomic)FormState formState;
@property (nonatomic)FormSearchState formSearchState;
@property (nonatomic)FormType formType;


@property (weak, nonatomic) IBOutlet UITextView *rejectTF;
@property (nonatomic, strong)NSString *alarmId;
@property (nonatomic)CGSize handleMethodStrSize;

@property (nonatomic, strong)UIView *photoPopView;
@property (nonatomic, strong)UIImageView *prePhotoImageView;
@property (nonatomic, strong)UIImage *selPhotoImage;

@property (nonatomic, strong)RBCustomDatePickerView *datePicker;
@property (strong, nonatomic) IBOutlet UIView *rejectView;
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
    self.title = @"工单处理";
    [self bottomBarBtnClicked:self.bottomDetailBtn];
    [self topBarBtnClicked:self.topbarBaseInfoBtn];
    self.topBarHistoryBtn.enabled = NO;
    [self.mainScrollView setAlwaysBounceVertical:YES];
    self.handleMethodStrSize = CGSizeMake(184, 50);
    self.handlerName = SharedDelegate.loginedUserName;
    
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
        [self getBasedInfo:nil];
    }];
    //http://10.19.116.148:8899/alarm/get_user_groupflag/?{"Operator":"fangmin"}
}
- (void)getBasedInfo:(id)sender {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //[dic setSafeObject:@"HN-051-130810-00036" forKey:@"FormNo"];
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    
    //[self showLoading];
    [GDService requestWithFunctionName:@"get_form_base" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSDictionary class]]) {
            self.basedInfoDic = reObj;
            self.T2Time = [self.basedInfoDic objectForKey:@"T2Time"];
            [self updateDisplayView];
            [self getDetailInfo:nil];
            //[self getHandleExp:nil];
        }
        [self getFormFlow:nil];
    }];
    //http://10.19.116.148:8899/alarm/get_form_base/?{"FormNo":"HN-051-130810-00036"}
}
- (void)getDetailInfo:(id)sender {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //[dic setSafeObject:@"HN-051-130810-00036" forKey:@"FormNo"];
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    
    [GDService requestWithFunctionName:@"get_form_detail" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.detailInfoArr = reObj;
            if (self.topbarDetailInfoBtn.selected) {
                [self updateDisplayView];
            }
        }
    }];
    //http://10.19.116.148:8899/alarm/get_form_detail/?{"FormNo":"HN-051-130810-00036"}
}
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
        
        [GDService requestWithFunctionName:@"get_form_flow" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
            if ([reObj isKindOfClass:[NSArray class]]) {
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
    [dic setSafeObject:__INT(0) forKey:@"Flag"];
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
    
    if (self.causeTwoArr && self.causeTwoArr.count > 0) {
        if (anBlock) {
            anBlock();
        }
        return;
    }
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
    
    if (self.causeThreeArr && self.causeThreeArr.count > 0) {
        if (anBlock) {
            anBlock();
        }
        return;
    }
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
                [oneDic setSafeObject:[dic objectForKey:@"OneCauseID"] forKey:@"01"];
                [self.causeOneArr addObject:oneDic];
                
                NSMutableDictionary *twoDic = [NSMutableDictionary dictionary];
                [twoDic setSafeObject:[dic objectForKey:@"TwoCause"] forKey:@"S1"];
                [twoDic setSafeObject:[dic objectForKey:@"TwoCauseID"] forKey:@"01"];
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:self.formNo forKey:@"FormNo"];
    [dic setSafeObject:self.handleTimeBtn.titleLabel.text forKey:@"startTime"];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Dealor"];
    [dic setSafeObject:__INT(4) forKey:@"FromState"];
    
    [dic setSafeObject:[NSString stringWithFormat:@"%@",[self.selReasonOneDic objectForKey:@"01"]]forKey:@"CauseOne"];
    [dic setSafeObject:[NSString stringWithFormat:@"%@",[self.selReasonTwoDic objectForKey:@"01"]] forKey:@"CauseTwo"];
    [dic setSafeObject:[NSString stringWithFormat:@"%@",[self.selReasonThreeDic objectForKey:@"Key"]] forKey:@"CauseThree"];
    
    [dic setSafeObject:self.reasonTF.text forKey:@"FaultCause"];
    [dic setSafeObject:self.T2Time forKey:@"T2Time"];
    
    [dic setSafeObject:self.methodTV.text forKey:@"DealWay"];
    [dic setSafeObject:self.handlerTF.text forKey:@"FaultDealor"];
    [dic setSafeObject:nil forKey:@"Fault_classification"];
    [dic setSafeObject:nil forKey:@"Fault_backcase"];
    
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

- (void)cancelBtnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)topBarBtnClicked:(id)sender {
    UIButton *selBtn = (UIButton*)sender;
    self.topbarBaseInfoBtn.selected = NO;
    self.topbarDetailInfoBtn.selected = NO;
    self.topBarHistoryBtn.selected = NO;
    selBtn.selected = YES;
    switch (selBtn.tag) {
        case 1:{
            //[self updateBaseInfoView];
            [self updateDisplayView];
        }
            break;
        case 2:
            //[self updateDetailInfoView];
            [self updateDisplayView];
            break;
        case 3:
            //
            [self updateDisplayView];
            //[self updateDealView];
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
            [self.view sendSubviewToBack:self.formFlowView];
        }
            break;
        case 2: {//240 248 164
            //
            //self.mainTextView.text = @"第二个TAB内容";
            [self.view bringSubviewToFront:self.formFlowView];
        }
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
        default:
            break;
    }
}
- (void)showDateSel:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定",nil];
    actionSheet.tag = btn.tag;
    self.datePicker = [[RBCustomDatePickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];//[[UIDatePicker alloc]initWithFrame:CGRectZero];
    //_datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.tag = btn.tag;
    [actionSheet addSubview:_datePicker];
    
    [actionSheet showInView:SharedDelegate.window];
}
- (void)showPicker:(id)sender {
    UIButton *btn = (UIButton*)sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定",nil];
    
    self.picker = [[UIPickerView alloc]initWithFrame:CGRectZero];
    _picker.tag = btn.tag;
    _picker.showsSelectionIndicator = YES;
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [actionSheet addSubview:_picker];
    actionSheet.tag = btn.tag;
    [actionSheet showInView:SharedDelegate.window];
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

- (void)closeKeyboard {
    //[self.handlerTF resignFirstResponder];
    [self.rejectTF resignFirstResponder];
    //[self.reasonTF resignFirstResponder];
    //[self.methodTV resignFirstResponder];
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

#pragma mark - update UI -
- (void)updateFormView {
    for (UIView* aView in self.formFlowView.subviews) {
        [aView removeFromSuperview];
    }
    int yPositon = 5;
    int rightXposition = 90;
    
    UILabel *theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, yPositon, 80, 20)];
    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
    theStaticLabel.backgroundColor = [UIColor clearColor];
    
    NSString *str = nil;
    CGSize size = CGSizeZero;
    UILabel *theRightLabel = [[UILabel alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 220, size.height)];
    theRightLabel.backgroundColor = [UIColor clearColor];
    theRightLabel.font = [UIFont systemFontOfSize:16.0];
    theRightLabel.numberOfLines = 0;
    theRightLabel.text = str;
    
    for (NSDictionary *dic in self.formFlowArr) {
        //NSString *key = [dic objectForKey:@"Key"];
        NSString *value = [dic objectForKey:@"Result"];
        
        theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, yPositon, 80, 20)];
        theStaticLabel.font = [UIFont systemFontOfSize:16.0];
        theStaticLabel.backgroundColor = [UIColor clearColor];
        theStaticLabel.text = @"sdf:";//[NSString stringWithFormat:@"%@：",key];
        
        str = value;
        size = [str sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:CGSizeMake(300, 2000)];
        theRightLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 300, size.height)];
        theRightLabel.backgroundColor = [UIColor clearColor];
        theRightLabel.font = [UIFont systemFontOfSize:16.0];
        theRightLabel.numberOfLines = 0;
        theRightLabel.text = str;
        
        yPositon += size.height>20?size.height+10:30;
        //[self.formFlowView addSubview:theStaticLabel];
        [self.formFlowView addSubview:theRightLabel];
    }
    self.formFlowView.contentSize = CGSizeMake(320, yPositon);
}
- (void)updateDisplayView {
    for (UIView* aView in self.mainScrollView.subviews) {
        [aView removeFromSuperview];
    }
    int yPositon = 5;
    int rightXposition = 90;
    
    UILabel *theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
    theStaticLabel.font = [UIFont systemFontOfSize:16.0];
    theStaticLabel.backgroundColor = [UIColor clearColor];
    
    NSString *str = nil;
    CGSize size = CGSizeZero;
    UILabel *theRightLabel = [[UILabel alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 220, size.height)];
    theRightLabel.backgroundColor = [UIColor clearColor];
    theRightLabel.font = [UIFont systemFontOfSize:16.0];
    theRightLabel.numberOfLines = 0;
    theRightLabel.text = str;
    
    NSArray *arr;
    if (self.topbarBaseInfoBtn.selected) {
        arr = [self.basedInfoDic objectForKey:@"Result"];
    }else if (self.topbarDetailInfoBtn.selected) {
        arr = self.detailInfoArr;
    }else if (self.topBarHistoryBtn.selected) {  // 历史处理特殊处理
        //self.handleExpStr = @"sdlkfjslkfjladskfjlsdkfjldskfjslkfjlsdkfjlsdkfjslfkj";
        CGSize size = [self.handleExpStr sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:CGSizeMake(300, 2000)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 300, size.height)];
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:16.0];
        label.text = self.handleExpStr;
        [self.mainScrollView addSubview:label];
        [self.mainScrollView setContentSize:CGSizeMake(320, size.height+50)];
        return;
    }
    
    if (arr.count <= 0) {
        return;
    }
    
    for (NSDictionary *dic in arr) {
        NSString *key = [dic objectForKey:@"Key"];
        NSString *value = [dic objectForKey:@"Value"];
        value = [value decodeBase64];
        if ([key isEqualToString:@"告警ID"]) {
            self.alarmId = value;
#warning 死数据
            //self.alarmId = @"WL-001-00-800003";
        }
        
        theStaticLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositon, 80, 20)];
        theStaticLabel.font = [UIFont systemFontOfSize:16.0];
        theStaticLabel.backgroundColor = [UIColor clearColor];
        theStaticLabel.text = [NSString stringWithFormat:@"%@：",key];
        
        str = value;
        size = [self sizeWithData:str];
        theRightLabel = [[UILabel alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 220, size.height)];
        theRightLabel.backgroundColor = [UIColor clearColor];
        theRightLabel.font = [UIFont systemFontOfSize:16.0];
        theRightLabel.numberOfLines = 0;
        theRightLabel.text = str;
        
        yPositon += size.height>20?size.height+5:25;
        [self.mainScrollView addSubview:theStaticLabel];
        [self.mainScrollView addSubview:theRightLabel];
    }
    //self.mainScrollView.contentSize = CGSizeMake(320, yPositon);
    
    rightXposition -= 28;
    if (self.topbarBaseInfoBtn.selected && self.formType == FormType_todo) {  // 基本信息特殊处理
        
        if (self.formState == FormState_doing) {
            [self updateDealViewWithYposition:yPositon];
            return;
        }else if (self.formState == FormState_todo) {
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
        }
    }else if (self.formType == FormType_copy && self.topbarBaseInfoBtn.selected) {
        
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
- (void)updateDealViewWithYposition:(int)y {
//    for (UIView* aView in self.mainScrollView.subviews) {
//        [aView removeFromSuperview];
//    }
    int yPositon = y;
    int rightXposition = 90;
    
    UILabel *theStaticLabel;
    UIButton *menu;
    
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
    
//    self.reasonBtn = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon-2, 184, 50)];
//    [self.reasonBtn setBackgroundImage:[[UIImage imageNamed:@"dealInputFrame"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)] forState:UIControlStateNormal];
//    //[self.reasonBtn addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
//    self.reasonBtn.tag = 3;
//    [self.reasonBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.mainScrollView addSubview:self.reasonBtn];
    
    
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
    
    //self.reasonTF.text = [self.selReasonThreeDic objectForKey:@"Value"];
    
//    menu = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition+184, yPositon-2, 30, 25)];
//    [menu setBackgroundImage:[UIImage imageNamed:@"popMenuBtn"] forState:UIControlStateNormal];
//    [menu addTarget:self action:@selector(dealMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
//    menu.tag = 3;
//    [self.mainScrollView addSubview:menu];
    
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
    
    [self.handleTimeBtn setTitle:self.selHandleTime forState:UIControlStateNormal];
    
    NSDateFormatter *dateFor = [[NSDateFormatter alloc]init];
    NSString * dateStr;
    [dateFor setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    dateStr = [dateFor stringFromDate:[NSDate date]];
    [self.handleTimeBtn setTitle:dateStr forState:UIControlStateNormal];
    
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
    
    yPositon += 60;
    [self.mainScrollView addSubview:theStaticLabel];
    
    
    rightXposition = 23+73;
    // 操作按钮
    right = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 63, 27)];
    [right setBackgroundImage:[UIImage imageNamed:@"handle"] forState:UIControlStateNormal];
    [right setBackgroundImage:[UIImage imageNamed:@"handle_sel"] forState:UIControlStateHighlighted];
    [right addTarget:self action:@selector(submitBackBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    
    right = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 63, 27)];
    [right setBackgroundImage:[UIImage imageNamed:@"copyBtn"] forState:UIControlStateNormal];
    [right setBackgroundImage:[UIImage imageNamed:@"copyBtn_sel"] forState:UIControlStateHighlighted];
    [right addTarget:self action:@selector(copyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:right];
    
    //yPositon += 32;
    rightXposition += 73;
    
    right = [[UIButton alloc]initWithFrame:CGRectMake(rightXposition, yPositon, 63, 27)];
    [right setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [right setBackgroundImage:[UIImage imageNamed:@"takePhoto_sel"] forState:UIControlStateHighlighted];
    [right addTarget:self action:@selector(toPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:right];
    
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
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
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
    }
    else{
        //        NSMutableDictionary *dic = [self.gongdanLevelArr safeObjectAtIndex:row];
        //        NSString *str = [dic objectForKey:@"Name"];
        //        return str;
    }
    return 0;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
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
        str = [dic objectForKey:@"S1"];
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

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
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
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 11) {
        return;
    }
    [self closeKeyboard];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGRect rec = textView.frame;
    CGFloat offset = 216+20 - (self.mainScrollView.frame.size.height - rec.size.height- rec.origin.y);// + self.mainScrollView.contentOffset.y;
    
    //rec.origin.y - rec.size.height - self.mainScrollView.contentOffset.y + 20 - (self.mainScrollView.frame.size.height - 216.0);//键盘高度216
    [self.mainScrollView setContentOffset:CGPointMake(0, offset) animated:YES];
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!buttonIndex) {
        NSInteger row = [self.picker selectedRowInComponent:0];
        if (actionSheet.tag == 1 ) {
            NSMutableDictionary *dic = [self.causeOneArr safeObjectAtIndex:row];
            NSString *str = [dic objectForKey:@"S1"];
            self.selReasonOneDic = dic;//[dic objectForKey:@"O1"];
            [self.reasonCateBtn setTitle:str forState:UIControlStateNormal];
        }else if (actionSheet.tag == 2) {
            NSMutableDictionary *dic = [self.causeTwoArr safeObjectAtIndex:row];
            NSString *str = [dic objectForKey:@"S1"];
            self.selReasonTwoDic = dic;//[dic objectForKey:@"O1"];
            [self.detailReasonCateBtn setTitle:str forState:UIControlStateNormal];
        }
        else if (actionSheet.tag == 3) {
            NSMutableDictionary *dic = [self.causeThreeArr safeObjectAtIndex:row];
            NSString *str = [dic objectForKey:@"Value"];
            self.selReasonThreeDic = dic;//[dic objectForKey:@"O1"];
            [self.reasonBtn setTitle:str forState:UIControlStateNormal];
        }else if (actionSheet.tag == 4) {
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
            [oneDic setSafeObject:[infoDic objectForKey:@"OneCauseID"] forKey:@"01"];
            self.selReasonOneDic = oneDic;
            
            NSMutableDictionary *twoDic = [NSMutableDictionary dictionary];
            [twoDic setSafeObject:[infoDic objectForKey:@"TwoCause"] forKey:@"S1"];
            [twoDic setSafeObject:[infoDic objectForKey:@"TwoCauseID"] forKey:@"01"];
            self.selReasonTwoDic = twoDic;
            
            NSMutableDictionary *threeDic = [NSMutableDictionary dictionary];
            [threeDic setSafeObject:[infoDic objectForKey:@"ThreeCause"] forKey:@"Value"];
            [threeDic setSafeObject:[infoDic objectForKey:@"ThreeCauseID"] forKey:@"Key"];
            self.selReasonThreeDic = threeDic;
            
            CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(180, 2000)];
            self.handleMethodStrSize = size;
            [self updateDisplayView];
        }else if (actionSheet.tag == 5) { // 时间选择
            NSDate *date = self.datePicker.date;
            //NSDate *todayDate = [NSDate date];
            NSDateFormatter *dateFor = [[NSDateFormatter alloc]init];
            NSString * dateStr;
            [dateFor setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            dateStr = [dateFor stringFromDate:date];
            self.selHandleTime = dateStr;
            [self.handleTimeBtn setTitle:dateStr forState:UIControlStateNormal];
        }else if (actionSheet.tag == 6) {
            NSMutableDictionary *dic = [self.dealWaySortArr safeObjectAtIndex:row];
            NSString *str = [dic objectForKey:@"Sort"];
            self.selDealWaySortDic = dic;//[dic objectForKey:@"O1"];
            [self.dealWaySortBtn setTitle:str forState:UIControlStateNormal];
            //[self getDealWaySortHeadedInfo:^{}];
        }else if (actionSheet.tag == 7) {
        }else{
            
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
