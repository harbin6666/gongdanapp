//
//  PhoneViewPoper.h
//  OneStore
//
//  Created by huangjiming on 8/27/14.
//  Copyright (c) 2014 OneStore. All rights reserved.
//

#import "OTSViewPoper.h"
@class PhoneViewPoper;
#import "OTSPickerView.h"
@protocol PhoneViewPoperDelegate <NSObject>

@optional
/**
 *  功能:点击取消按钮
 */
- (void)viewPoper:(PhoneViewPoper *)aViewPoper cancelBtnClicked:(id)sender;

/**
 *  功能:点击完成按钮
 */
- (void)viewPoper:(PhoneViewPoper *)aViewPoper finishBtnClicked:(id)sender;

#pragma mark - picker view相关datasource和delegate
/**
 *  功能:picker view的componet数量
 */
- (NSInteger)viewPoper:(PhoneViewPoper *)aViewPoper numberOfComponentsInPickerView:(UIPickerView *)pickerView;

/**
 *  功能:picker view的componet的行数
 */
- (NSInteger)viewPoper:(PhoneViewPoper *)aViewPoper pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

/**
 *  功能:picker view每行的title
 */
- (NSString *)viewPoper:(PhoneViewPoper *)aViewPoper pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
/**
 *
 *
 *  @param aViewPoper
 *  @param pickerView
 *  @param row
 *  @param component
 *
 *  @return
 */
- (UIView *)viewPoper:(PhoneViewPoper *)aViewPoper pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component;

/**
 *  功能:picker view点击某一行
 */
- (void)viewPoper:(PhoneViewPoper *)aViewPoper pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end

@interface PhoneViewPoper : OTSViewPoper

@property(nonatomic, weak) id<PhoneViewPoperDelegate> delegate;
@property(nonatomic, strong) OTSPickerView *pickerView;
@property(nonatomic, assign)int tag;
@end
