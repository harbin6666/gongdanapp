//
//  GDServiceV2.h
//  gongdanApp
//
//  Created by yuan jun on 14/12/13.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
typedef void(^compBlock)(id reObj,NSError* error);

@interface GDServiceV2 : NSObject
+(void)requestFunc:(NSString*)funName WithParam:(NSMutableDictionary*)param withCompletBlcok:(compBlock)block;

+(void)upLoadRequestWithData:(NSData*)uploadData withCompletBlcok:(compBlock)block;
@end

//@interface GDHttpRequest : ASIHTTPRequest
//
//@end