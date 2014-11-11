//
//  AppointTVC.m
//  gongdanApp
//
//  Created by 薛翔 on 14-3-4.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "AppointTVC.h"


@interface AppointTVC ()
@property(nonatomic, strong)UIView* line2;

@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *accountLabel;
@end

@implementation AppointTVC

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imageView.image = [UIImage imageNamed:@"selectSign"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43, 300, 1)];
        line.backgroundColor = [UIColor colorWithRed:67.0/255 green:149.0/255 blue:195.0/255 alpha:1.0];
        [self addSubview:line];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 12, 110, 20)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.text = @"xingming";
        self.nameLabel.font = [UIFont systemFontOfSize:10.0];
        self.nameLabel.numberOfLines = 2;
        [self addSubview:_nameLabel];
        
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(55, 0, 1, 44)];
        line1.backgroundColor = [UIColor colorWithRed:67.0/255 green:149.0/255 blue:195.0/255 alpha:1.0];
        [self addSubview:line1];
        
        self.line2 = [[UIView alloc]initWithFrame:CGRectMake(175, 0, 1, 44)];
        self.line2.backgroundColor = [UIColor colorWithRed:67.0/255 green:149.0/255 blue:195.0/255 alpha:1.0];
        [self addSubview:self.line2];
        
        self.accountLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, 12, 115, 20)];
        self.accountLabel.backgroundColor = [UIColor clearColor];
        self.accountLabel.font = [UIFont systemFontOfSize:10.0];
        self.accountLabel.text = @"账号zhanghao";
        [self addSubview:_accountLabel];
    }
    return self;
}
- (void)updaeWithDic:(NSDictionary*)dic type:(int)type isSel:(BOOL)isSel{
    NSString *name = @"";
    NSString *account = @"";
    if (type == 0) {
        self.line2.hidden = NO;
        name = [dic objectForKey:@"UserName"];
        account = [dic objectForKey:@"UserID"];
        self.nameLabel.frame = CGRectMake(60, 2, 110, 40);
    }else{
        self.line2.hidden = YES;
        name = [dic objectForKey:@"GroupName"];
        self.nameLabel.frame = CGRectMake(60, 2, 230, 40);
    }
    if (isSel) {
        self.imageView.image = [UIImage imageNamed:@"selectSign_sel"];
    }else {
        self.imageView.image = [UIImage imageNamed:@"selectSign"];
    }
    self.nameLabel.text = name;
    self.accountLabel.text = account;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
