//
//  GDBasedVC.m
//  gongdanApp
//
//  Created by 薛翔 on 14-2-21.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDBasedVC.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@implementation NSMutableDictionary (GD)

- (void)setSafeObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject == nil) {
        anObject = @"";
    }
    [self setObject:anObject forKey:aKey];
}
@end

@implementation NSMutableArray (GD)

- (id)safeObjectAtIndex:(NSUInteger)index {
    if (self.count > index ) {
        return [self objectAtIndex:index];
    }else{
        return nil;
    }
}
@end

@implementation NSArray (GD)

- (id)safeObjectAtIndex:(NSUInteger)index {
    if (self.count > index ) {
        return [self objectAtIndex:index];
    }else{
        return nil;
    }
}

@end


@interface GDBasedVC ()
@property(nonatomic, strong)UIButton *rightButton;
@property(nonatomic, strong)UIButton *leftButton;
@end

@implementation GDBasedVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
#endif
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftButton];
    }
    return self;
}
- (void)setLeftBtnImage:(UIImage*)image highLightImage:(UIImage*)hImage{
    //获取需要改变样式的按钮
    UIButton *theButton;
    if (self.navigationItem.leftBarButtonItem == nil) {
        UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
        self.navigationItem.leftBarButtonItem = btnItem;
    }
    theButton = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
    [theButton setBackgroundImage:image forState:UIControlStateNormal];
    [theButton setBackgroundImage:hImage forState:UIControlStateHighlighted];
}
- (void)setRightBtnImage:(UIImage*)image highLightImage:(UIImage*)hImage{
    UIButton *theButton;
    if (self.navigationItem.rightBarButtonItem == nil) {
        UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
        self.navigationItem.rightBarButtonItem = btnItem;
    }
    theButton = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
    [theButton setBackgroundImage:image forState:UIControlStateNormal];
    [theButton setBackgroundImage:hImage forState:UIControlStateHighlighted];
}
- (UIButton *)leftButton
{
	if (_leftButton == nil) {
		_leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 13, 22)];
		[_leftButton setBackgroundImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateNormal];
		[_leftButton setBackgroundImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateHighlighted];
		[_leftButton addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _leftButton;
}

- (UIButton *)rightButton
{
	if (_rightButton == nil) {
		_rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[_rightButton setBackgroundImage:[UIImage imageNamed:@"title_left_btn"] forState:UIControlStateNormal];
		[_rightButton setBackgroundImage:[UIImage imageNamed:@"title_left_btn_sel"] forState:UIControlStateHighlighted];
		[_rightButton addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _rightButton;
}
/**
 *  功能:左按钮点击行为，可在子类重写此方法
 */
- (void)leftBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  功能:右按钮点击行为，可在子类重写此方法
 */
- (void)rightBtnClicked:(id)sender
{
    
}

- (void)showLoading {
    [self showHUD:nil];
}
- (void)hideLoading {
    [self hideHUD];
}
/**
 *  功能:显示hud
 */
- (void)showHUD:(NSString *)aMessage
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = aMessage;
}
/**
 *  功能:隐藏hud
 */
- (void)hideHUD
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (NSString*)dateToNSString:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //frame
    
    CGRect thisRc = [UIScreen mainScreen].applicationFrame;
    float naviHeight = self.navigationController.navigationBar.frame.size.height;
	
    float tabHeight = ((AppDelegate *)[UIApplication sharedApplication].delegate).tabbarController.tabBar.frame.size.height;
    if (self.hidesBottomBarWhenPushed) {
        thisRc.size.height -= naviHeight;
    } else {
        thisRc.size.height -= naviHeight + tabHeight;
    }
    self.view.frame = thisRc;
    self.view.bounds = CGRectMake(0, 0, thisRc.size.width, thisRc.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
