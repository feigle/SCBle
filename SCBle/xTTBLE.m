
//
//  xTTBLE.m
//  BluetoothPlayer
//
//  Created by xTT on 14/11/4.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//

#import "xTTBLE.h"
#import "xTTPlayer.h"
//#import "MBProgressHUD.h"

#define UUID_NOT    @"49535343-1E4D-4BD9-BA61-23C647249616"
#define UUID_WRITE  @"49535343-8841-43F4-A8D4-ECBE34729BB3"

@implementation xTTBLE


- (id)init {
    self = [super init];  // Call a designated initializer here.
    if (self) {
//        _manager    = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];

    static dispatch_queue_t myQueue;
    if(!myQueue) {
        //        myQueue = dispatch_queue_create("aps.processUpgrade.queue",nil);
        myQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _manager = [[CBCentralManager alloc] initWithDelegate:(id<CBCentralManagerDelegate>)self queue:myQueue];
    }

        _nDevices   = [[NSMutableArray alloc] init];
        BLEobj      = [[xTTBLEdata alloc] init];
        _isConnect  = NO;
    }
    return self;
}

+ (xTTBLE *)getBLEObj{
    static xTTBLE *xTTble;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        xTTble = [[xTTBLE alloc] init];
    });
    return xTTble;
}

-(void)open
{
    
//    static dispatch_queue_t myQueue;
//    if(!myQueue) {
//        //        myQueue = dispatch_queue_create("aps.processUpgrade.queue",nil);
//        myQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        _manager = [[CBCentralManager alloc] initWithDelegate:(id<CBCentralManagerDelegate>)self queue:myQueue];
//    }
}

//开始查看服务，蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
//            [[LKLoadingCenter defaultCenter] postLoadingWithTitle:@"正在扫描蓝牙音箱"
//                                                          message:nil ignoreTouch:NO];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEPoweredOn" object:nil];
            NSLog(@"蓝牙已打开,请扫描外设");
            break;
        default:
            break;
    }
    if (central == scanManager) {
        scanManager = nil;
    }
}

- (void)chcekBluetoothPower{
    scanManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)scanClick
{
//    [_manager stopScan];
    [_manager scanForPeripheralsWithServices:nil options:nil];

    NSLog(@"正在扫描外设...");
}

//查到外设后，停止扫描
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSLog(@"Did discover peripheral %@", peripheral.name);

    if (![_nDevices containsObject:peripheral]) {
        
        [_nDevices addObject:peripheral];
        
        if (self.DataDelegate && [self.DataDelegate respondsToSelector:@selector(discoverDevice:)]) {
            
            [self. DataDelegate discoverDevice:_nDevices];
        }
        
    }
}

-(void)connectClick:(CBPeripheral *)peripheral
{
    _isConnect = NO;
    if (self.myCurrentPeri && self.myCurrentPeri.state == CBPeripheralStateDisconnected) {
        [_manager cancelPeripheralConnection:self.myCurrentPeri];
    }
    self.myCurrentPeri = nil;

    [_manager stopScan];
    [_manager connectPeripheral:peripheral options:nil];
    
    if (timeOut) {
        [timeOut invalidate];
        timeOut = nil;
    }
    timeOut = [NSTimer scheduledTimerWithTimeInterval:10
                                               target:self
                                             selector:@selector(connectTime)
                                             userInfo:nil
                                              repeats:NO];
//    [self performSelector:@selector(connectTime) withObject:nil afterDelay:10];
}

- (void)connectTime{
    if (!_isConnect) {
        NSLog(@"timeout = %d",_isConnect);
        if (timeOut) {
            [timeOut invalidate];
            timeOut = nil;
        }
        if (self.myCurrentPeri) {
            [_manager cancelPeripheralConnection:self.myCurrentPeri];
            self.myCurrentPeri = nil;
        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"connect_OK" object:@(NO)];
    }
}

//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%@",[NSString stringWithFormat:@"成功连接 peripheral: %@ with UUID: %@",peripheral,peripheral.identifier]);
    self.myCurrentPeri = peripheral;
    
    [self.myCurrentPeri setDelegate:self];
    [self.myCurrentPeri discoverServices:nil];
    NSLog(@"扫描服务");
}

//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接外设失败 %@",error);
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"connect_OK" object:@(NO)];
}

//已发现服务,开始发现特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *s in peripheral.services) {
        if (![s.UUID.UUIDString isEqualToString:@"180A"]) {
            [peripheral discoverCharacteristics:nil forService:s];
        }
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"-------------------------------");
    NSLog(@"%@",[NSString stringWithFormat:@"服务 UUID: %@ (%@)",service.UUID.data,service.UUID.UUIDString]);
    
    NSData *handshake = nil;
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"特征 UUID: %@ : %@  :  %@",c.UUID.UUIDString,c.UUID,c.value);
        if ([c.UUID.UUIDString isEqualToString:UUID_NOT])
        {
            [peripheral setNotifyValue:YES forCharacteristic:c];
//            [peripheral readValueForCharacteristic:c];
            handshake = c.value;
        }else if([c.UUID.UUIDString isEqualToString:UUID_WRITE])
        {
            _writeCharacteristic = c;
            if (self.DataDelegate && [self.DataDelegate respondsToSelector:@selector(connectOK)]) {
                
                [self. DataDelegate connectOK];
            }

            [self performSelector:@selector(configurationDeivce) withObject:nil afterDelay:1];
        }
    }
}

- (void)configurationDeivce{
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_WOSHOU];
}

//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"read = %@",characteristic.value);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"readData" object:characteristic.value];
    
    if (characteristic.value.length > 5 && _writeCharacteristic) {
        [self getBLEDataWithValue:characteristic.value];
    }
}

- (BOOL)getBLEDataWithValue:(NSData *)value{
    NSString *str = [xTTBLEdata NSDataToByteTohex:value];
    NSString *mlxx = [str substringWithRange:NSMakeRange(8, 2)];
    BOOL isValidate = [BLEobj isValidateData:str];
    
    if (![mlxx isEqualToString:@"02"] && ![mlxx isEqualToString:@"0a"] && ![mlxx isEqualToString:@"12"]) {
        
        [self sendBLEData:[BLEobj getResponseDataWith:isValidate MLXX:mlxx MLBM:[str substringWithRange:NSMakeRange(6, 2)]]];
    }
    if (isValidate) {
        if ([[str substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"]) {
            _isConnect = isValidate;
            if (timeOut) {
                [timeOut invalidate];
                timeOut = nil;
            }
            if (!_isConnect) {
                [_manager cancelPeripheralConnection:self.myCurrentPeri];
                self.myCurrentPeri = nil;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connect_OK" object:@(_isConnect)];
        }else{
            [BLEobj setBELData:value];
            [BLEobj processBELData];
        }
    }
    return isValidate;
}


- (void)sendBLEuserData:(NSString *)userData type:(SPP_Command)type
{
    if (self.myCurrentPeri.state != CBPeripheralStateConnected) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"连接断开", nil) message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [xTTPlayer getPlayerObj].BLEplay.signal = 10;
        [xTTPlayer getPlayerObj].BLEplay.voltage = 0;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_BT_SIGNAL" object:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_VOLTAGE" object:nil];
        return;
    }
    NSString *tmp;
    int length  = 100;
    if (userData.length < length) {
        [self sendBLEData:[BLEobj getDataWithUserData:userData
                                                 type:type
                                                 MLXX:@"00" BID:@"" YHSJPY:@""
                                              YHSJZCD:userData.length / 2]];
    }else{
        NSString *mlxx;
        for (int i = 0; i * length < userData.length; i++) {
            if ((i+1) * length < userData.length) {
                tmp = [userData substringWithRange:NSMakeRange(i * length, length)];
                if (i == 0) {
                    mlxx = @"01";
                    [self sendBLEData:[BLEobj getDataWithUserData:tmp type:type
                                                             MLXX:mlxx BID:@"" YHSJPY:@""
                                                          YHSJZCD:userData.length / 2]];
                }else{
                    mlxx = @"09";
                    NSString *bid = [xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",i] length:4];
                    NSString *yhsjpy = [xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",i * length / 2] length:4];
                    [self sendBLEData:[BLEobj getDataWithUserData:tmp type:type
                                                             MLXX:mlxx BID:bid
                                                           YHSJPY:yhsjpy
                                                          YHSJZCD:userData.length / 2]];
                }
            }else{
                tmp = [userData substringWithRange:NSMakeRange(i * length, userData.length - i * length)];
                mlxx = @"11";
                NSString *bid = [xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",i] length:4];
                NSString *yhsjpy = [xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",i * length / 2] length:4];
                [self sendBLEData:[BLEobj getDataWithUserData:tmp type:type
                                                         MLXX:mlxx BID:bid
                                                       YHSJPY:yhsjpy
                                                      YHSJZCD:userData.length / 2]];
            }
        }
    }
}

-(void)sendBLEData:(NSData *)data
{
    NSLog(@"send data ====== %@",data);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendData" object:data];
    [self.myCurrentPeri writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

//用于检测中心向外设写数据是否成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"%@",[NSString stringWithFormat:@"特征 UUID: %@ (%@) %@",characteristic.UUID.data,characteristic.UUID,characteristic.value]);
        NSLog(@"=======%@",error.userInfo);
        if (![xTTBLE getBLEObj].myCurrentPeri || [xTTBLE getBLEObj].myCurrentPeri.state == CBPeripheralStateDisconnected){
            [[xTTBLE getBLEObj] scanClick];
        }
    }else{
//        NSLog(@"发送数据成功");
    }
}

@end
