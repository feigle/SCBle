//
//  STBleController.h
//  STBle
//  该类为蓝牙通讯控制类
//  Created by 何泽文 on 15/8/28.
//  Copyright (c) 2015年 My MacPro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPeripheral.h"

@protocol STBleCommProtocol <NSObject>

@optional
- (void)discoverDevice:(NSMutableArray *)mArray;
- (void)dataArrive:(unsigned char *)buf;
- (void)connectOK;//连接成功，可以发送数据
- (void)hasDisconecnt;//连接丢失
- (void)connectFail;//连接失败
@end

@interface STBleController : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager *CManager;
   
}
@property(nonatomic,assign)BOOL isConneted;//连接，既是可以传送数据
@property(nonatomic,retain)STPeripheral *currentPeri;//当前连接的设备
@property(nonatomic,assign)id<STBleCommProtocol> dataDelegate;
+(STBleController*)getInstance;
- (void) open;
- (void) writeData:(NSData *) data;//发送数据
- (void) didConnect:(STPeripheral *)peripheral;//连接
- (void) didDisconnect:(CBPeripheral *)peripheral;//断开连接
- (void) searchDevices;//搜索设备
- (void) stopSearch;//停止搜索

@end
