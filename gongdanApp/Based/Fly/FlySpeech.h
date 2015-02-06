//
//  FlySpeech.h
//  gongdanApp
//
//  Created by yuan jun on 14/12/13.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^yuyingBlock)(NSString* yuyingresult);
@interface FlySpeech : NSObject

AS_SINGLETON(FlySpeech)
-(void)startRecognizer:(UIView*)view comletion:(yuyingBlock) block;

-(void)quitRecgnizer;
@end
