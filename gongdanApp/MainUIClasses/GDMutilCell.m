//
//  GDMutilCell.m
//  gongdanApp
//
//  Created by yj on 16/3/29.
//  Copyright © 2016年 xuexiang. All rights reserved.
//

#import "GDMutilCell.h"
@interface GDMutilCell()
@property(nonatomic, strong)UILabel *themeLabel;
@property(nonatomic, strong)UILabel *codeLabel;
@property(nonatomic, strong)UILabel *timeLabel;

@property(nonatomic)int state;

@end
@implementation GDMutilCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cell_bg_normal"]];
        
        self.stateImgV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 28, 24, 24)];
        [self.stateImgV setImage:[UIImage imageNamed:@"login_auto"]];
        [self.contentView addSubview:self.stateImgV];
        
        self.codeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 230, 20)];
        self.codeLabel.backgroundColor = [UIColor clearColor];
        self.codeLabel.text = @"";
        self.codeLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:self.codeLabel];
        
        self.themeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 32, 230, 20)];
        self.themeLabel.backgroundColor = [UIColor clearColor];
        self.themeLabel.text = @"";
        self.themeLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:self.themeLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 54, 230, 20)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.text = @"";
        self.timeLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (NSArray*)getTheShowInfoWithDic:(NSMutableDictionary*)dic {
    NSString *resultStr = [dic objectForKey:@"Result"];
    NSArray *arr = [resultStr componentsSeparatedByString:@"\n"];
    return arr;
}

- (void)updateWithDic:(NSMutableDictionary*)dic {
    NSString *Result=[dic objectForKey:@"Result"];
    Result=[Result stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    Result=[Result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    Result=[Result stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSData *data=[Result dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error=nil;
    NSArray *arr= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (arr==nil) {
        arr = [self getTheShowInfoWithDic:dic];
        
        NSString *codeRangeStr = @"编号";
        NSString *timeRangeStr = @"时限";
        NSString *titleRangeStr = @"主题";
        for (int i=0; i<3; i++) {
            NSString *str = [arr objectAtIndex:i];
            NSRange range1 = [str rangeOfString:codeRangeStr];
            NSRange range2 = [str rangeOfString:titleRangeStr];
            NSRange range3 = [str rangeOfString:timeRangeStr];
            
            if (range1.location != NSNotFound) {
                self.codeLabel.text = str;
            }else if (range2.location != NSNotFound) {
                self.themeLabel.text = str;
            }else if (range3.location != NSNotFound) {
                self.timeLabel.text = str;
            }
        }
        
    }else{//代办工单
        for (NSDictionary* dic in arr) {
            if ([dic[@"Key"] isEqualToString:@"工单编号"]) {
                self.codeLabel.text=[dic[@"Value"] decodeBase64];
            }
            if ([dic[@"Key"] isEqualToString:@"工单主题"]) {
                self.themeLabel.text=[dic[@"Value"] decodeBase64];
            }
            if ([dic[@"Key"] isEqualToString:@"处理时限"]) {
                self.timeLabel.text=[dic[@"Value"] decodeBase64];
            }
            
        }
        //超时状态（0:正常，1：将要超时的工单:2：已经超时的工单）
        NSNumber *outTimeStatus=[dic objectForKey:@"OutTimeStatus"];
        if (outTimeStatus) {
            if (outTimeStatus.intValue!=0) {
                self.codeLabel.textColor=[UIColor redColor];
                self.themeLabel.textColor=[UIColor redColor];
                self.timeLabel.textColor=[UIColor redColor];
            }else{
                self.codeLabel.textColor=[UIColor blackColor];
                self.themeLabel.textColor=[UIColor blackColor];
                self.timeLabel.textColor=[UIColor blackColor];
                
            }
        }
//        self.stateImgV.image=[UIImage imageNamed:@"login_auto"];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
