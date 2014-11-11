//
//  GDDefine.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-28.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#ifndef gongdanApp_GDDefine_h
#define gongdanApp_GDDefine_h


// NSNumber define
#undef	__INT
#define __INT( __x )			[NSNumber numberWithInt:(NSInteger)(__x)]

#undef	__UINT
#define __UINT( __x )			[NSNumber numberWithUnsignedInt:(NSUInteger)(__x)]

#undef	__LONG
#define __LONG( __x )			[NSNumber numberWithLong:(long)(__x)]

#undef	__LONGLONG
#define __LONGLONG( __x )			[NSNumber numberWithLongLong:(long long)(__x)]

#undef	__FLOAT
#define	__FLOAT( __x )			[NSNumber numberWithFloat:(float)(__x)]

#undef	__DOUBLE
#define	__DOUBLE( __x )			[NSNumber numberWithDouble:(double)(__x)]

#undef	__BOOL
#define __BOOL( __x )			[NSNumber numberWithBool:(BOOL)(__x)]

// http completion block
typedef void(^CompletionBlock)(id aResultObject, NSError* anError, id anExtraData);


#endif
