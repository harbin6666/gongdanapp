//
//  OTSPickerView.m
//  OneStoreFramework
//
//  Created by Aimy on 14-8-15.
//  Copyright (c) 2014年 OneStore. All rights reserved.
//

#import "OTSPickerView.h"

@implementation OTSPickerView

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
{    
    NSInteger rowCount = [self numberOfRowsInComponent:component];
    if (row>=0 && row<=rowCount-1) {
        [super selectRow:row inComponent:component animated:animated];
    }
    else {
        [super selectRow:0 inComponent:component animated:animated];
    }
}


@end
