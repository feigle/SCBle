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
- (void)fillCellWithDeviceInfo:(STPeripheral *)deviceInfo withTag:(NSInteger)tag
{
    self.deviceStatusBtn.tag = 1000 + tag;
    if (deviceInfo.isConnected) {
        [self.deviceStatusBtn setImage:[UIImage imageNamed:@"kaiguan_open"] forState:UIControlStateNormal];
        [self.deviceStatusImageView setImage:[UIImage imageNamed:@"deng_icon1"]];
        self.deviceStatusLabel.text = @"已连接";
    }else {
        [self.deviceStatusBtn setImage:[UIImage imageNamed:@"kaiguan_close"] forState:UIControlStateNormal];
        [self.deviceStatusImageView setImage:[UIImage imageNamed:@"deng_icon2"]];
        self.deviceStatusLabel.text = @"未连接";
    }
    self.deviceNameLabel.text = deviceInfo.DName;
}

@end
