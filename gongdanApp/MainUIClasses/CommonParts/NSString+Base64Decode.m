//
//  NSString+Base64Decode.m
//  gongdanApp
//
//  Created by yuan jun on 14-3-4.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "NSString+Base64Decode.h"
#import "GTMBase64.h"

@implementation NSString (Base64Decode)
-(NSString*)decodeBase64{
//    NSMutableString *result=[[NSMutableString alloc] init];
    NSString *ar=  [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData *data=[GTMBase64 decodeString:ar];
   NSString* result=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    for (int i=0; i<ar.count; i++) {
//        NSData *decodedData = [GTMBase64 decodeString:ar[i]];//[[NSData alloc] initWithBase64EncodedString:ar[i] options:0];
//        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
//        result = (NSMutableString*)[result stringByAppendingString:[NSString stringWithFormat:@"%@",decodedString]];
//    }
    return result;
}

@end
