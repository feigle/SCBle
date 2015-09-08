//
//  STPeripheral.m
//  STBle
//
//  Created by My MacPro on 15/8/28.
//  Copyright (c) 2015年 My MacPro. All rights reserved.
//

#import "STPeripheral.h"

@implementation STPeripheral

- (STPeripheral *)initWithName:(NSString *)name andPeripheral:(CBPeripheral *)cb
{
    STPeripheral *stPer = [[STPeripheral alloc] init];
    stPer.DName = name;
    stPer.DPeripheral = cb;
    return stPer;
}

@end
