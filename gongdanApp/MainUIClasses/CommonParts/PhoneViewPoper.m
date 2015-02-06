//
//  PhoneViewPoper.m
//  OneStore
//
//  Created by huangjiming on 8/27/14.
//  Copyright (c) 2014 OneStore. All rights reserved.
//

#import "PhoneViewPoper.h"
#import "OTSPickerView.h"
@interface PhoneViewPoper()<UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, strong) UIView *popView;
@property(nonatomic, strong) UIImageView *titleBg;
@property(nonatomic, strong) UIButton *cancelBtn;
@property(nonatomic, strong) UIButton *finishBtn;
//@property(nonatomic, strong) OTSPickerView *pickerView;

@end

@implementation PhoneViewPoper

@synthesize popView = _popView;

- (void)dealloc
{
    [_cancelBtn removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    [_finishBtn removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    _pickerView.dataSource = nil;
    _pickerView.delegate = nil;
}

#pragma mark - Property
- (UIImageView *)titleBg
{
    if (_titleBg == nil) {
        _titleBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 44)];
        _titleBg.image = [UIImage imageNamed:@"actionsheet_bg"];
    }
    
    return _titleBg;
}

- (UIButton *)cancelBtn
{
    if (_cancelBtn == nil) {
        _cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(8, 6, 48, 33)];
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"actionsheet_cancel" ] forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"actionsheet_cancel_sel" ] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelBtn;
}

- (UIButton *)finishBtn
{
    if (_finishBtn == nil) {
        _finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(UI_SCREEN_WIDTH-56, 6, 48, 33)];
        [_finishBtn setBackgroundImage:[UIImage imageNamed:@"actionsheet_confirm" ] forState:UIControlStateNormal];
        [_finishBtn setBackgroundImage:[UIImage imageNamed:@"actionsheet_confirm_sel" ] forState:UIControlStateHighlighted];
        [_finishBtn addTarget:self action:@selector(finishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _finishBtn;
}

- (UIPickerView *)pickerView
{
    if (_pickerView == nil) {
        _pickerView = [[OTSPickerView alloc] initWithFrame:CGRectMake(0, 44, UI_SCREEN_WIDTH, 196)];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.showsSelectionIndicator = YES;
    }
    
    return _pickerView;
}

- (UIView *)popView
{
    if (_popView == nil) {
        _popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 240)];
        
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, UI_SCREEN_WIDTH, 224)];
        subView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        subView.layer.cornerRadius = 5.0;
        [_popView addSubview:subView];
        
        [_popView addSubview:self.titleBg];
        [_popView addSubview:self.cancelBtn];
        [_popView addSubview:self.finishBtn];
        [_popView addSubview:self.pickerView];
    }
    
    return _popView;
}

#pragma mark - Action
- (void)finishBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(viewPoper:finishBtnClicked:)]) {
        [self.delegate viewPoper:self finishBtnClicked:sender];
    }
    
    [self hidePopView];
}

- (void)cancelBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(viewPoper:cancelBtnClicked:)]) {
        [self.delegate viewPoper:self cancelBtnClicked:sender];
    }
    
    [self hidePopView];
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([self.delegate respondsToSelector:@selector(viewPoper:numberOfComponentsInPickerView:)]) {
        return [self.delegate viewPoper:self numberOfComponentsInPickerView:pickerView];
    }
    
    return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([self.delegate respondsToSelector:@selector(viewPoper:pickerView:numberOfRowsInComponent:)]) {
        return [self.delegate viewPoper:self pickerView:pickerView numberOfRowsInComponent:component];
    }
    
    return 99;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([self.delegate respondsToSelector:@selector(viewPoper:pickerView:titleForRow:forComponent:)]) {
        return [self.delegate viewPoper:self pickerView:pickerView titleForRow:row forComponent:component];
    }
    
    return @"";
}

-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    if ([self.delegate respondsToSelector:@selector(viewPoper:pickerView:viewForRow:forComponent:)]) {
        return [self.delegate viewPoper:self pickerView:pickerView viewForRow:row forComponent:component];
    }
    
    return nil;
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.delegate respondsToSelector:@selector(viewPoper:pickerView:didSelectRow:inComponent:)]) {
        [self.delegate viewPoper:self pickerView:pickerView didSelectRow:row inComponent:component];
    }
}

@end
