//
//  GDMainHandleVC.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-23.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDBasedVC.h"

typedef enum _FormSearchState {
    FormSearchState_TodoAndDoing = 1, // 包含待受理，处理中
    FormSearchState_Copy = 3, // 抄送
    FormSearchState_Todo,
    FormSearchState_Doing
}FormSearchState;

typedef enum _FormState {
    FormState_todo = 2,
    FormState_doing = 3,
    FormState_done = 4
}FormState;

typedef enum _FormType{
    FormType_todo = 1,
    FormType_done,
    FormType_copy
}FormType;

@interface GDMainHandleVC : GDBasedVC<UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate,UITextFieldDelegate, UITextViewDelegate>
- (IBAction)topBarBtnClicked:(id)sender;
- (IBAction)bottomBarBtnClicked:(id)sender;
- (id)initWithFormNo:(NSString*)formNo formType:(FormType)formType formsearchState:(FormSearchState)formsearchState formState:(FormState)formeState;
@end
