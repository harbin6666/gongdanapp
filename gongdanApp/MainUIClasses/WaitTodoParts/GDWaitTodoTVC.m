//
//  GDWaitTodoTVC.m
//  gongdanApp
//
//  Created by 薛翔 on 14-2-21.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDWaitTodoTVC.h"

@interface GDWaitTodoTVC ()

@property(nonatomic, strong)UILabel *themeLabel;
@property(nonatomic, strong)UILabel *codeLabel;
@property(nonatomic, strong)UILabel *timeLabel;

@property(nonatomic, strong)UIImageView *stateImgV;

@end

@implementation GDWaitTodoTVC

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cell_bg_normal"]];
        
        self.stateImgV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 64, 64)];
        [self.stateImgV setImage:[UIImage imageNamed:@"form_normal"]];
        [self.contentView addSubview:_stateImgV];
        
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 86, 20)];
        textLabel.text = @"工单编号：";
        textLabel.backgroundColor = [UIColor clearColor];
      //  [self.contentView addSubview:textLabel];
        
        self.codeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 230, 20)];
        self.codeLabel.backgroundColor = [UIColor clearColor];
        self.codeLabel.text = @"";
        self.codeLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:_codeLabel];
        
        textLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 32, 200, 20)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = @"工单主题：";
       // [self.contentView addSubview:textLabel];
        
        self.themeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 32, 230, 20)];
        self.themeLabel.backgroundColor = [UIColor clearColor];
        self.themeLabel.text = @"";
        self.themeLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:_themeLabel];
        
        textLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 54, 200, 20)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = @"处理时限：";
        //[self.contentView addSubview:textLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 54, 230, 20)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.text = @"";
        self.timeLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:_timeLabel];
    }
    return self;
}

- (NSArray*)getTheShowInfoWithDic:(NSMutableDictionary*)dic {
    NSString *resultStr = [dic objectForKey:@"Result"];
    NSArray *arr = [resultStr componentsSeparatedByString:@"\n"];
    return arr;
}
- (void)updateWithDic:(NSMutableDictionary*)dic {
    NSArray *arr = [self getTheShowInfoWithDic:dic];
    self.codeLabel.text = [arr objectAtIndex:0];//[dic objectForKey:@"FormNo"];
    self.themeLabel.text = [arr objectAtIndex:1];//[dic objectForKey:@"AlarmTitle"];
    self.timeLabel.text = [arr objectAtIndex:2];//[dic objectForKey:@"Result"];
    //self.timeLabel.font = [UIFont systemFontOfSize:14.0];
    //self.timeLabel.numberOfLines = 0;
    //self.timeLabel.frame = CGRectMake(80, 5, 230, 70);
   
    NSNumber* status = [dic objectForKey:@"FormStatus"];
    switch (status.intValue) {
        case 1:
            [self.stateImgV setImage:[UIImage imageNamed:@"form_temp"]];
            break;
        case 2:
            [self.stateImgV setImage:[UIImage imageNamed:@"form_notAccept"]];
            break;
        case 3:
            [self.stateImgV setImage:[UIImage imageNamed:@"form_accept"]];
            break;
        case 4:
            [self.stateImgV setImage:[UIImage imageNamed:@"form_checking"]];
            break;
        case 7:
            [self.stateImgV setImage:[UIImage imageNamed:@"form_force"]];
            break;
        default:
            [self.stateImgV setImage:[UIImage imageNamed:@"form_normal"]];
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
