//
//  DeviceStatusCell.m
//  SCBle
//
//  Created by 吗啡 on 15/8/30.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import "DeviceStatusCell.h"
#import "STPeripheral.h"

@implementation DeviceStatusCell

// 填充单元格数据
- (void)fillCellWithDeviceInfo:(STPeripheral *)deviceInfo
{
    if (deviceInfo.on) {
        [self.deviceStatusBtn setImage:[UIImage imageNamed:@"kaiguan_open"] forState:UIControlStateNormal];
    }else {
        [self.deviceStatusBtn setImage:[UIImage imageNamed:@"kaiguan_close"] forState:UIControlStateNormal];
    }
    self.deviceNameLabel.text = deviceInfo.DName;
}

@end
