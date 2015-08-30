//
//  DeviceStatusCell.h
//  SCBle
//
//  Created by 吗啡 on 15/8/30.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SBDevice;
@interface DeviceStatusCell : UITableViewCell

// 设备状态图片
@property (nonatomic, weak) IBOutlet UIImageView *deviceStatusImageView;
// 设备名称
@property (nonatomic, weak) IBOutlet UILabel *deviceNameLabel;
// 设备状态
@property (nonatomic, weak) IBOutlet UILabel *deviceStatusLabel;
// 设备开关状态
@property (nonatomic, weak) IBOutlet UIButton *deviceStatusBtn;

// 填充单元格数据
- (void)fillCellWithDeviceInfo:(SBDevice *)deviceInfo;

@end
