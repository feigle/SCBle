//
//  SBDevice.h
//  SCBle
//
//  Created by 吗啡 on 15/8/30.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//
//  SBDevice类用于抽象蓝牙设备

#import <Foundation/Foundation.h>

@interface SBDevice : NSObject

// 设备名称
@property (nonatomic, strong) NSString *name;
// 设备状态
@property (nonatomic, assign) BOOL on;

@end
