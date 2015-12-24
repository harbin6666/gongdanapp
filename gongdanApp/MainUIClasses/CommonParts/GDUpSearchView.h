//
//  GDUpSearchView.h
//  gongdanApp
//
//  Created by 薛翔 on 14-3-8.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GDUpSearchDelegate <NSObject>
@required
- (void)upSearchWithStartDate:(NSString*)startDate endDate:(NSString*)endDate;
@end

@interface GDUpSearchView : UIView <UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property(nonatomic, weak)id<GDUpSearchDelegate> delegate;
- (void)popTopSearchView;
- (void)closeTopSearchViewWithBlock:(void(^)())callBackBlock;
@end
