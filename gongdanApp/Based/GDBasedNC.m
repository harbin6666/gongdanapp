//
//  GDBasedNC.m
//  gongdanApp
//
//  Created by 薛翔 on 14-2-20.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDBasedNC.h"

@interface GDBasedNC ()

@end

@implementation GDBasedNC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.navigationBar setBarStyle:UIBarStyleDefault];
    }
    return self;
}
- (id)init {
    self = [super init];
    if (self) {
        [self.navigationBar setBarStyle:UIBarStyleDefault];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
