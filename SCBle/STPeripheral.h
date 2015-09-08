//
//  STPeripheral.h
//  STBle
// 此类为蓝牙外设类
//  Created by 何泽文 on 15/8/28.
//  Copyright (c) 2015年 My MacPro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define UUID_NOT    @"49535343-1E4D-4BD9-BA61-23C647249616"
#define UUID_WRITE  @"49535343-8841-43F4-A8D4-ECBE34729BB3"

@interface STPeripheral : NSObject

@property (nonatomic,strong)NSString *DName;
@property (nonatomic,strong)CBPeripheral *DPeripheral;

@property (nonatomic,retain)CBService *DService;
@property (nonatomic,retain)CBCharacteristic *rxCharacteristic;
@property (nonatomic,retain)CBCharacteristic *txCharacteristic;

- (STPeripheral *)initWithName:(NSString *)name andPeripheral:(CBPeripheral *)cb;
@end
