//
//  NSData+DES.h
//  gongdanApp
//
//  Created by yj on 16/3/20.
//  Copyright © 2016年 xuexiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(NSData_DES)
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key;
+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key;
@end
