//
//  GDService.m
//  gongdanApp
//
//  Created by 薛翔 on 14-2-26.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDService.h"
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonDigest.h>
#import "ASIFormDataRequest.h"


@implementation GDService

+ (void)requestWithFunctionName:(NSString*)functionName pramaDic:(NSMutableDictionary*)pramaDic requestMethod:(NSString*)method completion:(comp)completion{
    GDHttpRequest *req = [[GDHttpRequest alloc]initReqWithFunctionName:functionName pramaDic:pramaDic requestMethod:method completion:completion];
    req.delegate = req;
    
    [req startAsynchronous];
}

+ (void)requestWithFunctionName:(NSString*)functionName uploadData:(NSData*)uploadData completion:(comp)completion{
    
    NSString *urlStr = [host1 stringByAppendingString:[NSString stringWithFormat:@"%@/",functionName]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL: [NSURL URLWithString:urlStr]];
    [request setPostValue: @"MyName" forKey: @"name"];
    [request setData:uploadData withFileName:@"upload.png" andContentType:@"image/png/jpeg/jpg" forKey:@"clientSticker"];
    [request buildRequestHeaders];
    //request.delegate = self;
    NSLog(@"header: %@", request.requestHeaders);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [request startSynchronous];
        NSLog(@"responseString = %@", request.responseString);
        if (completion) {
            __block NSRange range = [request.responseString rangeOfString:@"Sequenceid"];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (range.location != NSNotFound) {
                    completion(@"成功");
                }else{
                    completion(nil);
                }
            });
        }
    });
}
@end


@implementation GDHttpRequest
@synthesize comBlock = _comBlock;
- (id)initReqWithFunctionName:(NSString *)funcionName pramaDic:(NSMutableDictionary*)pramaDic requestMethod:(NSString*)method completion:(comp)completion{

    NSString *urlStr = [host1 stringByAppendingString:[NSString stringWithFormat:@"%@/",funcionName]];
    [self addRequestHeader:@"text/json" value:@"Content-Type"];
    if ([method isEqualToString:@"GET"] || method == nil) {
        urlStr = [urlStr stringByAppendingString:@"?7B"];
        int i = 1;
        for (NSString* key in pramaDic) {
            id value = [pramaDic objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                if ([key isEqualToString:@"Password"]) {
                    value = [[self md5:value] lowercaseString];
                }
                urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",key, value]];
            }else{
                urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"\"%@\":%@",key, value]];
            }
            if (i < pramaDic.allKeys.count) {
                urlStr = [urlStr stringByAppendingString:@","];
            }
            i++;
        }
        urlStr = [urlStr stringByAppendingString:@"7D"];
        NSLog(@"the request url is:\n\n\n%@\n\n\n",urlStr);
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        self = [super initWithURL:[NSURL URLWithString:urlStr]];
        if (self) {
            self.functionName = funcionName;
            self.pramaDic = pramaDic;
            self.comBlock = completion;
            self.timeOutSeconds = 30;
        }
        return self;
    }else{
        NSString *bodyStr = @"{";
        int i = 1;
        for (NSString* key in pramaDic) {
            id value = [pramaDic objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                if ([key isEqualToString:@"Password"]) {
                    value = [[self md5:value] lowercaseString];
                }
                bodyStr = [bodyStr stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",key, value]];
            }else{
                bodyStr = [bodyStr stringByAppendingString:[NSString stringWithFormat:@"\"%@\":%@",key, value]];
            }
            if (i < pramaDic.allKeys.count) {
                bodyStr = [bodyStr stringByAppendingString:@","];
            }
            i++;
        }
        bodyStr = [bodyStr stringByAppendingString:@"}"];
        NSLog(@"the HOST is:\n\n\n%@\n\n\nbody is :\n\n\n%@\n\n\n",urlStr,bodyStr);
        
        self = [super initWithURL:[NSURL URLWithString:urlStr]];
        if (self) {
            NSMutableData *postData = [[NSMutableData alloc] init];
            [postData appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
            self.postBody = postData;
            self.requestMethod = @"POST";
            self.functionName = funcionName;
            self.pramaDic = pramaDic;
            self.comBlock = completion;
            self.timeOutSeconds = 30;
        }
        return self;
    }
    

}
- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

- (void)requestFinished:(ASIHTTPRequest *)arequest {
    
    __block NSData *aJsonData = [[NSData alloc] initWithData:[arequest responseData]];
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *aerror = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:aJsonData options:kNilOptions error:&aerror];
        NSLog(@"the functionName is:\n   %@\n jsonData is: \n   %@",self.functionName,jsonObj);
        if (jsonObj==nil) {
            NSLog(@"responseString### %@",arequest.responseString);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.comBlock) {
                self.comBlock(jsonObj);
            }
        });
    });
}
- (void)requestFailed:(ASIHTTPRequest *)aRequest {
    NSLog(@"请求失败");
    //[MBProgressHUD hideHUDForView:SharedDelegate.tabbarController.selectedViewController.view animated:YES];
    if (self.comBlock) {
        self.comBlock(nil);
    }
    if (aRequest.error.code == 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络超时" message:@"请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

@end