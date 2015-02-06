//
//  GDServiceV2.m
//  gongdanApp
//
//  Created by yuan jun on 14/12/13.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDServiceV2.h"
#import <CommonCrypto/CommonDigest.h>
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#define host2 [NSString stringWithFormat:@"%@%@",host1,@"mq_pass_2/"] //@"http://120.202.255.70:8080/alarm/"//

@interface GDServiceV2()<ASIHTTPRequestDelegate>
@property(nonatomic,copy)compBlock block;

@end
@implementation GDServiceV2
+(void)requestFunc:(NSString*)funName WithParam:(NSMutableDictionary*)param withCompletBlcok:(compBlock)block{
    [param setObject:@2 forKey:@"PfType"];
    [param setObject:@"mq_pass_2" forKey:@"Function"];
    [param setObject:funName forKey:@"ServiceName"];
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:host2]];
    [request addRequestHeader:@"text/plain;charset=UTF-8 " value:@"Content-Type"];
    NSString *jsonStr;
    NSError *error=nil;
     NSData *jsonData=[NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
    if (error==nil) {
        jsonStr=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSLog(@"request param  %@",jsonStr);
//    NSMutableData *postData = [[NSMutableData alloc] init];
//    [postData appendData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
    request.postBody = jsonData.mutableCopy;
    request.delegate=self;
    request.requestMethod = @"POST";
    request.timeOutSeconds = 30;
//    [request startAsynchronous];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [request startSynchronous];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (request.error==nil) {
                NSData *jsonData=request.responseData;
                NSString *responseString=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                NSLog(@"%@",responseString);
                responseString = [responseString stringByReplacingOccurrencesOfString : @"\r" withString : @"\\r" ];
                
                responseString = [responseString stringByReplacingOccurrencesOfString : @"\n" withString : @"\\n" ];
                
                responseString = [responseString stringByReplacingOccurrencesOfString : @"\t" withString : @"\\t" ];
                

                NSError *parseError=nil;
                id result=[NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&parseError];
                    block(result,parseError);
            }

        });
    });
}

+(void)upLoadRequestWithData:(NSData*)uploadData withCompletBlcok:(compBlock)block{
    
}

@end
