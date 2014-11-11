//
//  GDSearchVC.m
//  gongdanApp
//
//  Created by 薛翔 on 14-2-20.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDSearchVC.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchResultVC.h"
#import "RBCustomDatePickerView.h"

@interface GDSearchVC ()
@property(nonatomic, strong)UIButton *startTimeBtn;
@property(nonatomic, strong)UIButton *endTimeBtn;
@property(nonatomic, strong)UIButton *categoryBtn;
@property(nonatomic, strong)UIButton *teamBtn;
@property(nonatomic, strong)UIButton *t2HandlerBtn;
@property(nonatomic, strong)UIButton *stateBtn;
@property(nonatomic, strong)UIButton *levelBtn;

@property(nonatomic, strong)RBCustomDatePickerView *datePicker;
@property(nonatomic, strong)UIPickerView *picker;

//data
@property(nonatomic, strong)NSMutableArray *categoryArr;
@property(nonatomic, strong)NSMutableArray *gongdanStatsArr;
@property(nonatomic, strong)NSMutableArray *t2HandlerArr;
@property(nonatomic, strong)NSMutableArray *gongdanLevelArr;
@property(nonatomic, strong)NSMutableArray *groupArr;
//
@property(nonatomic, strong)NSString *teamName;
@property(nonatomic, strong)NSString *teamId;
@property(nonatomic, strong)NSString *t2Hanlder;
@property(nonatomic, strong)NSString *t2HandlerId;
@property(nonatomic, strong)NSNumber *level;
@property(nonatomic, strong)NSString *groupName; // 其实是netid
@property(nonatomic, strong)NSDate *startDate;
@property(nonatomic, strong)NSDate *endDate;
@property(nonatomic, strong)NSNumber *formState;
@end

@implementation GDSearchVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"工单查询";
        self.navigationItem.leftBarButtonItem = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initAllSection];
}
- (void)viewWillAppear:(BOOL)animated {
    [self resetData];
    [self getCurrentGroup];
}

- (void)initTheDefautlParmas {
    self.startDate = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
    self.endDate = [NSDate date];
    [self.startTimeBtn setTitle:[self dateToNSString:self.startDate] forState:UIControlStateNormal];
    [self.endTimeBtn setTitle:[self dateToNSString:self.endDate] forState:UIControlStateNormal];
    
    [self.categoryBtn setTitle:@"全部" forState:UIControlStateNormal];
    self.groupName = @"-1";
    
    self.teamId = self.teamId;
    [self.teamBtn setTitle:self.teamName forState:UIControlStateNormal];
    [self.t2HandlerBtn setTitle:SharedDelegate.loginedUserName forState:UIControlStateNormal];
    self.t2HandlerId = @"ALL";
    
    self.formState = __INT(-1);
    [self.stateBtn setTitle:@"全部" forState:UIControlStateNormal];
    self.level = __INT(-1);
    [self.levelBtn setTitle:@"全部" forState:UIControlStateNormal];
    
}

#pragma mark - service -

- (void)getCurrentGroup {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [self showLoading];
    [GDService requestWithFunctionName:@"get_group_byuser" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            NSArray *arr = reObj;
            NSDictionary *dic = [arr safeObjectAtIndex:0];
            self.teamName = [dic objectForKey:@"GroupName"];
            self.teamId = [dic objectForKey:@"GroupID"];
        }
        [self initTheDefautlParmas];
        
    }];
    
    //http://10.19.116.148:8899/alarm/get_group_byuser/?{"Operator":"admin"}
}
- (void)doSearch {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:__INT(1) forKey:@"StartNo"];
    [dic setSafeObject:__INT(5) forKey:@"EndNo"];
    [dic setSafeObject:self.t2HandlerId forKey:@"Operator"];
    [dic setSafeObject:[self dateToNSString:self.startDate] forKey:@"StartTime"];
    [dic setSafeObject:[self dateToNSString:self.endDate] forKey:@"EndTime"];
    [dic setSafeObject:self.formState forKey:@"FormState"];
    [dic setSafeObject:self.level forKey:@"FormLevel"];
    [dic setSafeObject:self.groupName forKey:@"NetTypeOne"];
    [dic setSafeObject:self.teamId forKey:@"GroupName"];
    [self showLoading];
    [GDService requestWithFunctionName:@"get_form_query" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            NSMutableArray *arr = reObj;
            if (arr.count > 0) {
                NSDictionary *dic1 = [arr safeObjectAtIndex:0];
                //            NSNumber *flag = [dic objectForKey:@"Flag"];
                NSString *desc = [dic1 objectForKey:@"Desc"];
                if (desc) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"失败" message:desc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }else{
                    SearchResultVC *svc = [[SearchResultVC alloc]initWithPramaDic:dic dataArr:arr];
                    [self.navigationController pushViewController:svc animated:YES];
                }
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"查询无数据" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
    //{"NetTypeOne":"101010401","GroupName":"8a9982f2222d2030012231a4252110ab","Operator":"inspur","FormState":2,"FormLevel":1,"StartTime":"2013-11-01 00:00:00","EndTime":"2013-11-01 23:59:59","StartNo":1,"EndNo":5}
}
- (void)getNetClass:(id)sender {
    
    if (self.categoryArr) {
        [self showActionPicker:sender];
    }else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setSafeObject:__INT(0) forKey:@"NetID"];
        [dic setSafeObject:__INT(0) forKey:@"Type"];
        [self showLoading];
        [GDService requestWithFunctionName:@"get_net_class" pramaDic:dic requestMethod:@"GET" completion:^(id reObj) {
            [self hideLoading];
            if ([reObj isKindOfClass:[NSArray class]]) {
                
                self.categoryArr = reObj;
                [self showActionPicker:sender];
            }
        }];
    }
}
- (void)getTeamAndGroup:(id)sender {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:__INT(1) forKey:@"Type"];
    [dic setSafeObject:SharedDelegate.loginedUserName forKey:@"Operator"];
    [self showLoading];
    [GDService requestWithFunctionName:@"get_group_info" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.groupArr = reObj;
            [self showActionPicker:sender];
        }
    }];
    //http://10.19.116.148:8899/alarm/get_group_info/?{"Type":3,"Operator":"admin","Group":"无线"}
}

- (void)getT2User:(id)sender {
    if (!self.teamName) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请先选择班组" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:self.teamId forKey:@"Group"];
    [self showLoading];
    [GDService requestWithFunctionName:@"get_user_bygroup" pramaDic:dic requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
            self.t2HandlerArr = reObj;
            [self showActionPicker:sender];
        }
    }];
    //http://10.19.116.148:8899/alarm/get_user_bygroup/?{"Group":"8a9982f33f21bf44013f3cd464da2ea3"}
}
- (void)getGongDanState:(id)sender {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setSafeObject:__INT(0) forKey:@"Type"];
    [dic setSafeObject:__INT(0) forKey:@"Type"];
    [dic setSafeObject:@"liuweiguo" forKey:@"Operator"];
    [dic setSafeObject:__INT(1) forKey:@"Flag"];
    [dic setSafeObject:__INT(-1) forKey:@"CityID"];
    [self showLoading];
    [GDService requestWithFunctionName:@"get_sys_dict" pramaDic:nil requestMethod:@"POST" completion:^(id reObj) {
        [self hideLoading];
        if ([reObj isKindOfClass:[NSArray class]]) {
             NSArray *arr = reObj;
            self.gongdanStatsArr = [NSMutableArray array];
            self.gongdanLevelArr = [NSMutableArray array];
            for (NSDictionary *dic in arr) {
                NSNumber *typeId = [dic objectForKey:@"TypeID"];
                NSLog(@"the dic is: %@, %@",dic.allKeys, dic.allValues);
                if (typeId.intValue == 8) {
                    [self.gongdanStatsArr addObject:dic];
                }
                if (typeId.intValue == 46) {
                    [self.gongdanLevelArr addObject:dic];
                }
            }
            [self showActionPicker:sender];
        }
    }];
}

#pragma mark - UIInition -
- (void)initAllSection {
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [scrollView setAlwaysBounceVertical:YES];
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    int yPositon = 10;
    // section 1
    UIView *sectionV = [[UIView alloc]initWithFrame:CGRectMake(10, yPositon, 300, 150)];
    sectionV.layer.borderWidth = 1.0;
    yPositon += 150+15;
    [scrollView addSubview:sectionV];
    
    UILabel *normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 130, 30)];
    normalLabel.text = @"派单开始时间：";
    normalLabel.backgroundColor = [UIColor clearColor];
    [sectionV addSubview:normalLabel];
    
    normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 130, 30)];
    normalLabel.text = @"派单结束时间：";
    normalLabel.backgroundColor = [UIColor clearColor];
    [sectionV addSubview:normalLabel];
    
    normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 105, 130, 30)];
    normalLabel.text = @"网络一级分类：";
    normalLabel.backgroundColor = [UIColor clearColor];
    [sectionV addSubview:normalLabel];
    
    self.startTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(130, 10, 160, 40)];
    _startTimeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _startTimeBtn.layer.borderWidth = 1.0;
    _startTimeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_startTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _startTimeBtn.tag = 1;
    _startTimeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    _startTimeBtn.layer.borderColor = [UIColor colorWithRed:153.0/255 green:181.0/255 blue:194.0/255 alpha:1.0].CGColor;
    [_startTimeBtn addTarget:self action:@selector(showDateSel:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(140, 8, 15, 24)];
    arrow.image = [UIImage imageNamed:@"downArr"];
    [_startTimeBtn addSubview:arrow];
    
    [sectionV addSubview:_startTimeBtn];
    
    self.endTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(130, 55, 160, 40)];
    _endTimeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _endTimeBtn.layer.borderWidth = 1.0;
    _endTimeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _endTimeBtn.tag = 2;
    [_endTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _endTimeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    _endTimeBtn.layer.borderColor = [UIColor colorWithRed:153.0/255 green:181.0/255 blue:194.0/255 alpha:1.0].CGColor;
    [_endTimeBtn addTarget:self action:@selector(showDateSel:) forControlEvents:UIControlEventTouchUpInside];
    
    arrow = [[UIImageView alloc]initWithFrame:CGRectMake(140, 8, 15, 24)];
    arrow.image = [UIImage imageNamed:@"downArr"];
    [_endTimeBtn addSubview:arrow];
    
    [sectionV addSubview:_endTimeBtn];
    
    self.categoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(130, 100, 160, 40)];
    _categoryBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _categoryBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _categoryBtn.layer.borderWidth = 1.0;
    _categoryBtn.tag = 3;
    _categoryBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [_categoryBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _categoryBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_categoryBtn addTarget:self action:@selector(getNetClass:) forControlEvents:UIControlEventTouchUpInside];
    _categoryBtn.layer.borderColor = [UIColor colorWithRed:153.0/255 green:181.0/255 blue:194.0/255 alpha:1.0].CGColor;
    
    arrow = [[UIImageView alloc]initWithFrame:CGRectMake(140, 8, 15, 24)];
    arrow.image = [UIImage imageNamed:@"downArr"];
    [_categoryBtn addSubview:arrow];
    
    [sectionV addSubview:_categoryBtn];
    
    // section 2
    sectionV = [[UIView alloc]initWithFrame:CGRectMake(10, yPositon, 300, 100)];
    sectionV.layer.borderWidth = 1.0;
    yPositon += 100+15;
    [scrollView addSubview:sectionV];
    
    normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 130, 30)];
    normalLabel.text = @"部门班组：";
    normalLabel.backgroundColor = [UIColor clearColor];
    [sectionV addSubview:normalLabel];
    
    normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 130, 30)];
    normalLabel.text = @"T2处理人：";
    normalLabel.backgroundColor = [UIColor clearColor];
    [sectionV addSubview:normalLabel];
    
    self.teamBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 10, 190, 40)];
    _teamBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _teamBtn.layer.borderWidth = 1.0;
    _teamBtn.tag = 4;
    [_teamBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _teamBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_teamBtn addTarget:self action:@selector(getTeamAndGroup:) forControlEvents:UIControlEventTouchUpInside];
    _teamBtn.layer.borderColor = [UIColor colorWithRed:153.0/255 green:181.0/255 blue:194.0/255 alpha:1.0].CGColor;
    
    arrow = [[UIImageView alloc]initWithFrame:CGRectMake(170, 8, 15, 24)];
    arrow.image = [UIImage imageNamed:@"downArr"];
    [_teamBtn addSubview:arrow];
    
    [sectionV addSubview:_teamBtn];
    
    self.t2HandlerBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 55, 190, 40)];
    _t2HandlerBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _t2HandlerBtn.layer.borderWidth = 1.0;
    _t2HandlerBtn.tag = 5;
    [_t2HandlerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _t2HandlerBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_t2HandlerBtn addTarget:self action:@selector(getT2User:) forControlEvents:UIControlEventTouchUpInside];
    _t2HandlerBtn.layer.borderColor = [UIColor colorWithRed:153.0/255 green:181.0/255 blue:194.0/255 alpha:1.0].CGColor;
    
    arrow = [[UIImageView alloc]initWithFrame:CGRectMake(170, 8, 15, 24)];
    arrow.image = [UIImage imageNamed:@"downArr"];
    [_t2HandlerBtn addSubview:arrow];
    
    [sectionV addSubview:_t2HandlerBtn];
    
    // section 3
    sectionV = [[UIView alloc]initWithFrame:CGRectMake(10, yPositon, 300, 100)];
    sectionV.layer.borderWidth = 1.0;
    yPositon += 100+15;
    [scrollView addSubview:sectionV];
    
    normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 130, 30)];
    normalLabel.text = @"工单状态：";
    normalLabel.backgroundColor = [UIColor clearColor];
    [sectionV addSubview:normalLabel];
    
    normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 130, 30)];
    normalLabel.text = @"工单级别：";
    normalLabel.backgroundColor = [UIColor clearColor];
    [sectionV addSubview:normalLabel];
    
    self.stateBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 10, 190, 40)];
    _stateBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _stateBtn.layer.borderWidth = 1.0;
    _stateBtn.tag = 6;
    [_stateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _stateBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _stateBtn.layer.borderColor = [UIColor colorWithRed:153.0/255 green:181.0/255 blue:194.0/255 alpha:1.0].CGColor;
    [_stateBtn addTarget:self action:@selector(getGongDanState:) forControlEvents:UIControlEventTouchUpInside];
    
    arrow = [[UIImageView alloc]initWithFrame:CGRectMake(170, 8, 15, 24)];
    arrow.image = [UIImage imageNamed:@"downArr"];
    [_stateBtn addSubview:arrow];
    
    [sectionV addSubview:_stateBtn];
    
    self.levelBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 55, 190, 40)];
    _levelBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _levelBtn.layer.borderWidth = 1.0;
    _levelBtn.tag = 7;
    [_levelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _levelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _levelBtn.layer.borderColor = [UIColor colorWithRed:153.0/255 green:181.0/255 blue:194.0/255 alpha:1.0].CGColor;
    [_levelBtn addTarget:self action:@selector(getGongDanState:) forControlEvents:UIControlEventTouchUpInside];
    
    arrow = [[UIImageView alloc]initWithFrame:CGRectMake(170, 8, 15, 24)];
    arrow.image = [UIImage imageNamed:@"downArr"];
    [_levelBtn addSubview:arrow];
    
    [sectionV addSubview:_levelBtn];
    // extraBtn
    UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, yPositon, 98, 34)];
    [searchBtn setTitle:@"查询" forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"toSearchBtn"] forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"toSearchBtn_sel"] forState:UIControlStateHighlighted];
    searchBtn.backgroundColor = [UIColor clearColor];
    [searchBtn addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:searchBtn];
    
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(170, yPositon, 98, 34)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setImage:[UIImage imageNamed:@"cancelBtn"] forState:UIControlStateNormal];
    [cancelBtn setImage:[UIImage imageNamed:@"cancelBtn_sel"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(resetData) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:cancelBtn];
    
    scrollView.contentSize = CGSizeMake(320, yPositon+60);
}
- (void)closeKeyboard {
    [self.startTimeBtn resignFirstResponder];
    [self.endTimeBtn resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self closeKeyboard];
    return YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self closeKeyboard];
}

#pragma mark - actions -


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
- (void)showActionPicker:(id)sender {
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
- (void)resetData {
    self.teamName = nil;
    self.teamId = nil;
    self.t2Hanlder = nil;
    self.t2HandlerId = nil;
    self.level = nil;
    self.groupName = nil;
    self.startDate = nil;
    self.endDate = nil;
    self.formState = nil;
    
    [self.teamBtn setTitle:@"" forState:UIControlStateNormal];
    [self.t2HandlerBtn setTitle:@"" forState:UIControlStateNormal];
    [self.levelBtn setTitle:@"" forState:UIControlStateNormal];
    [self.categoryBtn setTitle:@"" forState:UIControlStateNormal];
    [self.startTimeBtn setTitle:@"" forState:UIControlStateNormal];
    [self.endTimeBtn setTitle:@"" forState:UIControlStateNormal];
    [self.stateBtn setTitle:@"" forState:UIControlStateNormal];
}

#pragma mark - pickerview delegate -
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 3) {
        return self.categoryArr.count;
    }else if (pickerView.tag == 4) {
        return self.groupArr.count;
    }else if (pickerView.tag == 5) {
        return self.t2HandlerArr.count;
    }
    return 4;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 3) {
        NSMutableDictionary *dic = [self.categoryArr objectAtIndex:row];
        NSString *str = [dic objectForKey:@"NetName"];
        return str;
    }else if (pickerView.tag == 4) {
        NSMutableDictionary *dic = [self.groupArr objectAtIndex:row];
        NSString *str = [dic objectForKey:@"GroupName"];
        return str;
    }else if (pickerView.tag == 5) {
        //NSMutableDictionary *dic = [self.groupArr objectAtIndex:row];
        return @"get_user_group接口取不到数据";
    }else if (pickerView.tag == 6) {
        NSMutableDictionary *dic = [self.gongdanStatsArr objectAtIndex:row];
        NSString *str = [dic objectForKey:@"Name"];
        return str;
    }else if (pickerView.tag == 7) {
        NSMutableDictionary *dic = [self.gongdanLevelArr objectAtIndex:row];
        NSString *str = [dic objectForKey:@"Name"];
        return str;
    }
    return @"safkjsdlfj";
}
//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0); // attributed title is favored if both methods are implemented
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    NSString *str;
    if (pickerView.tag == 3) {
        NSMutableDictionary *dic = [self.categoryArr objectAtIndex:row];
        str = [dic objectForKey:@"NetName"];
       // return str;
    }else if (pickerView.tag == 4) {
        NSMutableDictionary *dic = [self.groupArr objectAtIndex:row];
        str = [dic objectForKey:@"GroupName"];
        //return str;
    }else if (pickerView.tag == 5) {
        NSMutableDictionary *dic = [self.t2HandlerArr objectAtIndex:row];
        str =  [dic objectForKey:@"UserName"];
    }else if (pickerView.tag == 6) {
        NSMutableDictionary *dic = [self.gongdanStatsArr objectAtIndex:row];
        str = [dic objectForKey:@"Name"];
        //return str;
    }else if (pickerView.tag == 7) {
        NSMutableDictionary *dic = [self.gongdanLevelArr objectAtIndex:row];
        str = [dic objectForKey:@"Name"];
        //return str;
    }else{
        str = @"没有数据";
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 30)];
    label.font = [UIFont systemFontOfSize:12.0];
    label.backgroundColor = [UIColor clearColor];
    label.text = str;
    return label;
}

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
////    NSMutableDictionary *dic = [self.categoryArr objectAtIndex:row];
////    NSString *str = [dic objectForKey:@"NetName"];
////    [self.categoryBtn setTitle:str forState:UIControlStateNormal];
//}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!buttonIndex) {
        int row = [self.picker selectedRowInComponent:0];
        if (actionSheet.tag == 1 || actionSheet.tag == 2) {
            NSDate *date = self.datePicker.date;
            //NSDate *todayDate = [NSDate date];
            NSDateFormatter *dateFor = [[NSDateFormatter alloc]init];
            NSString * dateStr;
            switch (self.datePicker.tag) {
                case 1:
                    [dateFor setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    dateStr = [dateFor stringFromDate:date];
                    [self.startTimeBtn setTitle:dateStr forState:UIControlStateNormal];
                    self.startDate = date;
                    break;
                case 2:
                    [dateFor setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    dateStr = [dateFor stringFromDate:date];
                    [self.endTimeBtn setTitle:dateStr forState:UIControlStateNormal];
                    self.endDate = date;
                    break;
                default:
                    break;
            }
        }else if (actionSheet.tag == 3) {
            NSMutableDictionary *dic = [self.categoryArr objectAtIndex:row];
            NSString *str = [dic objectForKey:@"NetName"];
            self.groupName = [dic objectForKey:@"NetID"];
            [self.categoryBtn setTitle:str forState:UIControlStateNormal];
        }else if (actionSheet.tag == 4) {
            NSMutableDictionary *dic = [self.groupArr objectAtIndex:row];
            NSString *teamName = [dic objectForKey:@"GroupName"];
            NSString *teamId = [dic objectForKey:@"GroupID"];
            self.teamName = teamName;
            self.teamId = teamId;
            [self.teamBtn setTitle:_teamName forState:UIControlStateNormal];
        }else if (actionSheet.tag == 5) {
            NSMutableDictionary *dic = [self.t2HandlerArr objectAtIndex:row];
            NSString *userName = [dic objectForKey:@"UserName"];
            NSString *userId = [dic objectForKey:@"UserID"];
            self.t2HandlerId = userId;
            self.t2Hanlder = userName;
            [self.t2HandlerBtn setTitle:_t2Hanlder forState:UIControlStateNormal];
        }else if (actionSheet.tag == 6) {
            NSMutableDictionary *dic = [self.gongdanStatsArr objectAtIndex:row];
            NSString *str = [dic objectForKey:@"Name"];
            self.formState = [dic objectForKey:@"ID"];
            [self.stateBtn setTitle:str forState:UIControlStateNormal];
        }else if (actionSheet.tag == 7) {
            NSMutableDictionary *dic = [self.gongdanLevelArr objectAtIndex:row];
            NSString *str = [dic objectForKey:@"Name"];
            self.level = [dic objectForKey:@"ID"];
            [self.levelBtn setTitle:str forState:UIControlStateNormal];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
