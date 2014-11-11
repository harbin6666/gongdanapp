//
//  GDUpSearchView.m
//  gongdanApp
//
//  Created by 薛翔 on 14-3-8.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDUpSearchView.h"
#import "GDBasedVC.h"
#import "RBCustomDatePickerView.h"

@interface GDUpSearchView ()
@property(nonatomic, strong)UIButton *startTimeBtn;
@property(nonatomic, strong)UIButton *endTimeBtn;
@property(nonatomic, strong)UIButton *categoryBtn;

@property(nonatomic, strong)NSString *startDate;
@property(nonatomic, strong)NSString *endDate;

@property(nonatomic, strong)NSMutableArray *categoryArr;

@property(nonatomic, strong)RBCustomDatePickerView *datePicker;
@property (nonatomic, strong)UIPickerView *picker;
@end

@implementation GDUpSearchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, -130, 320, 220)];
    if (self) {
        // Initialization code
        [self initUI];
    }
    return self;
}
- (id)init {
    self = [super init];
    if (self) {
       self = [self initWithFrame:CGRectMake(0, -130, 320, 220)];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1.0];
    int yPositon = 10;
    // section 1
    UIView *sectionV = [[UIView alloc]initWithFrame:CGRectMake(10, yPositon, 300, 150)];
    //sectionV.layer.borderWidth = 1.0;
    yPositon += 150+15;
    [self addSubview:sectionV];
    
    UILabel *normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 130, 30)];
    normalLabel.text = @"开始时间：";
    normalLabel.backgroundColor = [UIColor clearColor];
    [sectionV addSubview:normalLabel];
    
    normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 130, 30)];
    normalLabel.text = @"结束时间：";
    normalLabel.backgroundColor = [UIColor clearColor];
    [sectionV addSubview:normalLabel];
    
    normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 105, 130, 30)];
    normalLabel.text = @"网络分类：";
    normalLabel.backgroundColor = [UIColor clearColor];
    [sectionV addSubview:normalLabel];
    
    self.startTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 10, 190, 40)];
    _startTimeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _startTimeBtn.layer.borderWidth = 1.0;
    _startTimeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_startTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _startTimeBtn.tag = 1;
    _startTimeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    _startTimeBtn.layer.borderColor = [UIColor colorWithRed:153.0/255 green:181.0/255 blue:194.0/255 alpha:1.0].CGColor;
    [_startTimeBtn addTarget:self action:@selector(showDateSel:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(170, 8, 15, 24)];
    arrow.image = [UIImage imageNamed:@"downArr"];
    [_startTimeBtn addSubview:arrow];
    
    [sectionV addSubview:_startTimeBtn];
    
    self.endTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 55, 190, 40)];
    _endTimeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _endTimeBtn.layer.borderWidth = 1.0;
    _endTimeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _endTimeBtn.tag = 2;
    [_endTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _endTimeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    _endTimeBtn.layer.borderColor = [UIColor colorWithRed:153.0/255 green:181.0/255 blue:194.0/255 alpha:1.0].CGColor;
    [_endTimeBtn addTarget:self action:@selector(showDateSel:) forControlEvents:UIControlEventTouchUpInside];
    
    arrow = [[UIImageView alloc]initWithFrame:CGRectMake(170, 8, 15, 24)];
    arrow.image = [UIImage imageNamed:@"downArr"];
    [_endTimeBtn addSubview:arrow];
    
    [sectionV addSubview:_endTimeBtn];
    
    self.categoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 190, 40)];
    _categoryBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _categoryBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _categoryBtn.layer.borderWidth = 1.0;
    _categoryBtn.tag = 3;
    _categoryBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [_categoryBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _categoryBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_categoryBtn addTarget:self action:@selector(getNetClass:) forControlEvents:UIControlEventTouchUpInside];
    _categoryBtn.layer.borderColor = [UIColor colorWithRed:153.0/255 green:181.0/255 blue:194.0/255 alpha:1.0].CGColor;
    
    arrow = [[UIImageView alloc]initWithFrame:CGRectMake(170, 8, 15, 24)];
    arrow.image = [UIImage imageNamed:@"downArr"];
    [_categoryBtn addSubview:arrow];
    
    [sectionV addSubview:_categoryBtn];
    
    UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, yPositon, 98, 34)];
    [searchBtn setTitle:@"查询" forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"toSearchBtn"] forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"toSearchBtn_sel"] forState:UIControlStateHighlighted];
    searchBtn.backgroundColor = [UIColor clearColor];
    [searchBtn addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:searchBtn];
    
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(170, yPositon, 98, 34)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setImage:[UIImage imageNamed:@"cancelBtn"] forState:UIControlStateNormal];
    [cancelBtn setImage:[UIImage imageNamed:@"cancelBtn_sel"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:cancelBtn];
}

- (NSString*)dateToNSString:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}
- (void)doSearch {
    if ([self.delegate respondsToSelector:@selector(upSearchWithStartDate:endDate:)]) {
        [self.delegate upSearchWithStartDate:self.startDate endDate:self.endDate];
    }
    [self closeSelf];
}

- (void)getNetClass:(id)sender {
    
    if (self.categoryArr) {
        [self showActionPicker:sender];
    }else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setSafeObject:__INT(0) forKey:@"NetID"];
        [dic setSafeObject:__INT(0) forKey:@"Type"];
        
        [GDService requestWithFunctionName:@"get_net_class" pramaDic:dic requestMethod:@"GET" completion:^(id reObj) {
            self.categoryArr = reObj;
            [self showActionPicker:sender];
        }];
    }
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

- (void)popTopSearchView {
    CGRect rec = self.frame;
    rec.origin.y = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = rec;
    } completion:^(BOOL finished) {
        //[self removeFromSuperview];
    }];
}

- (void)closeTopSearchViewWithBlock:(void(^)())callBackBlock {
    CGRect rec = self.frame;
    rec.origin.y = -rec.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = rec;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (callBackBlock) {
            callBackBlock();
        }
    }];
}

- (void)closeSelf {
    CGRect rec = self.frame;
    rec.origin.y = -rec.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = rec;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
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
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.categoryArr.count > 0) {
        return self.categoryArr.count;
    }
    return 0;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSMutableDictionary *dic = [self.categoryArr objectAtIndex:row];
    NSString *str = [dic objectForKey:@"NetName"];
    return str;
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    int row = [self.picker selectedRowInComponent:0];
    if (!buttonIndex) {
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
                    self.startDate = dateStr;//[dateFor dateFromString:dateStr];
                    break;
                case 2:
                    [dateFor setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    dateStr = [dateFor stringFromDate:date];
                    [self.endTimeBtn setTitle:dateStr forState:UIControlStateNormal];
                    self.endDate = dateStr;//[dateFor dateFromString:dateStr];
                    break;
                default:
                    break;
            }
        }else {
            NSMutableDictionary *dic = [self.categoryArr objectAtIndex:row];
            NSString *str = [dic objectForKey:@"NetName"];
            //self.groupName = [dic objectForKey:@"NetID"];
            [self.categoryBtn setTitle:str forState:UIControlStateNormal];
        }
    }
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
