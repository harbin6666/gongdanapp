//
//  FlySpeech.m
//  gongdanApp
//
//  Created by yuan jun on 14/12/13.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "FlySpeech.h"
#import <iflyMSC/IFlyRecognizerViewDelegate.h>
#import <iflyMSC/IFlyRecognizerView.h>
#import <iflyMSC/IFlySpeechUtility.h>
#import <iflyMSC/IFlySpeechConstant.h>
@interface FlySpeech()<IFlyRecognizerViewDelegate>
@property(nonatomic,strong)IFlySpeechUtility *flyUtility;
@property(nonatomic ,strong)IFlyRecognizerView *iflyRecognizerView;
@property(nonatomic,strong)yuyingBlock block;
@end
@implementation FlySpeech
DEF_SINGLETON(FlySpeech)

-(id)init{
    self=[super init];
    if (self) {
        [self setting];
    }
    return self;
}
-(void)setting{
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"50ab52fb"];
    self.flyUtility=[IFlySpeechUtility createUtility:initString];
}
static NSMutableString *result=nil;
-(void)startRecognizer:(UIView*)view comletion:(yuyingBlock) block{
    self.block=block;
    _iflyRecognizerView=[[IFlyRecognizerView alloc] initWithCenter:view.center];
    _iflyRecognizerView.delegate = self;
    [_iflyRecognizerView setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    //启动识别服务
    [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
//    [_iflyRecognizerView setParameter:@"1" forKey:[IFlySpeechConstant ASR_SCH]];
//    [_iflyRecognizerView setParameter:@"0" forKey:[IFlySpeechConstant ASR_PTT]];
    
    [_iflyRecognizerView start];
    result=nil;
    
}
-(void)quitRecgnizer{
    [_iflyRecognizerView cancel];
}
/*识别结果返回代理
 @param resultArray 识别结果
 @ param isLast 表示是否最后一次结果
 */
- (void)onResult: (NSArray *)resultArray isLast:(BOOL) isLast {
    if (result==nil) {
        result = [[NSMutableString alloc] init];
    }
    NSLog(@"%@",resultArray);
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    if (isLast) {
        NSLog(@"%@",result);
        self.block(result);
    }
}
/*识别会话错误返回代理
 @ param error 错误码
 */
- (void)onError: (IFlySpeechError *) error {
    NSLog(@"%@",[error errorDesc]);
}
@end
