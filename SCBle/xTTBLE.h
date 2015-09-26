//
//  xTTBLE.h
//  BluetoothPlayer
//
//  Created by xTT on 14/11/4.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "xTTBLEdata.h"

@protocol STBleCommProtocol <NSObject>

@optional
- (void)discoverDevice:(NSMutableArray *)mArray;
- (void)dataArrive:(unsigned char *)buf;
- (void)connectOK;//连接成功，可以发送数据
- (void)hasDisconecnt;//连接丢失
- (void)connectFail;//连接失败
@end


@interface xTTBLE : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    xTTBLEdata *BLEobj;
    
    CBCentralManager *scanManager;
    NSTimer *timeOut;
}

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *myCurrentPeri;
@property (nonatomic, assign) id<STBleCommProtocol> DataDelegate;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (nonatomic, assign) BOOL isConnected;
@property (strong ,nonatomic) CBCharacteristic *writeCharacteristic;

@property (strong,nonatomic) NSMutableArray *nWriteCharacteristics;
@property (assign,nonatomic) BOOL isConnect;

+ (xTTBLE *)getBLEObj;
-(void)open;

- (void)chcekBluetoothPower;
- (void)scanClick;
- (void)connectClick:(CBPeripheral *)peripheral;

- (void)sendBLEData:(NSData *)data;

- (void)sendBLEuserData:(NSString *)userData type:(SPP_Command)type;

@end
