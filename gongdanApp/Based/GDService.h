//
//  GDService.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-26.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "GDDefine.h"

typedef void(^comp)(id reObj);

@interface GDService : NSObject
@property(nonatomic, strong)NSMutableDictionary *pramaDic;
+ (void)requestWithFunctionName:(NSString*)functionName pramaDic:(NSMutableDictionary*)pramaDic requestMethod:(NSString*)method completion:(comp)completion;

+ (void)requestWithFunctionName:(NSString*)functionName uploadData:(NSData*)uploadData completion:(comp)completion;

@end




@interface GDHttpRequest : ASIHTTPRequest
@property(nonatomic, strong)NSString *functionName;
@property(nonatomic, strong)NSMutableDictionary* pramaDic;
@property(nonatomic, copy)comp comBlock;
- (id)initReqWithFunctionName:(NSString *)funcionName pramaDic:(NSMutableDictionary*)pramaDic requestMethod:(NSString*)method completion:(comp)completion;
- (NSString *)md5:(NSString *)str;
@end