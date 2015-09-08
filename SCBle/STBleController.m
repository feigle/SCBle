//
//  STBleController.m
//  STBle
//
//  Created by My MacPro on 15/8/28.
//  Copyright (c) 2015年 My MacPro. All rights reserved.
//

#import "STBleController.h"

@implementation STBleController
{
    NSMutableArray *deviceList;//发现的设备
}

+(STBleController*)getInstance
{
    static STBleController* itinst;
    if(itinst==nil){
        itinst=[[STBleController alloc] init];
        
    }
    return itinst;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        deviceList = [[NSMutableArray alloc] init];
//        _currentPeri = [STPeripheral alloc]
    }
    return self;
}
-(void)open
{
    
    static dispatch_queue_t myQueue;
    if(!myQueue) {
        myQueue = dispatch_queue_create("aps.processUpgrade.queue",nil);}
    CManager = [[CBCentralManager alloc] initWithDelegate:(id<CBCentralManagerDelegate>)self queue:myQueue];
    
    
}

- (void) writeData:(NSData *) data
{
    NSLog(@"发送的数据：%@, self.curr.txChar == %@",data ,self.currentPeri.txCharacteristic);
    [self.currentPeri.DPeripheral writeValue:data forCharacteristic:self.currentPeri.txCharacteristic type:CBCharacteristicWriteWithResponse];
}
- (void) didConnect:(STPeripheral *)peripheral
{
    [CManager connectPeripheral:peripheral.DPeripheral options:nil];
}
- (void) didDisconnect:(CBPeripheral *)peripheral
{
}
- (void) searchDevices
{
    [CManager scanForPeripheralsWithServices:nil options:nil];
}
- (void) stopSearch
{

}

#pragma mark CBCentralManagerDelegate
//1.CBCentralManager初始化的回调
- (void)centralManagerDidUpdateState:(CBCentralManager *)manager
{
    NSLog(@"manager state %ld", (long)manager.state);
    
    
    switch ([manager state])
    {
        case CBCentralManagerStateUnknown:
            NSLog(@"The platform/hardware CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            break;
            
        case CBCentralManagerStateUnsupported:
            NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
            
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
            
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Bluetooth is currently powered off.");
            
            break;
        case CBCentralManagerStatePoweredOn:
            
            NSLog(@"Bluetooth is currently powered on.");
            break;
        default:
            break;
            
    }
    
    
}
//2.搜索到蓝牙设备的回调
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Did discover peripheral %@", peripheral.name);
    NSLog(@"uuid == %@", peripheral.UUID);
    
    for (STPeripheral *stPe in deviceList) {
        if(stPe.DPeripheral == peripheral) {
            
            return;
        }
    }
    
    if ([peripheral.name isEqualToString:@""]||peripheral.name ==nil) {
        return;
    }
    STPeripheral *uPeripheral = [[STPeripheral alloc] initWithName:peripheral.name andPeripheral:peripheral];
    [self stroyDevice:uPeripheral];
    
}
- (void)stroyDevice:(STPeripheral *)stPer
{
    [deviceList addObject:stPer];
    if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(discoverDevice:)]) {
        [self.dataDelegate discoverDevice:deviceList];
    }
}

//3.连接成功的回调
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect peripheral %@", peripheral.name);
    for (STPeripheral *stPe in deviceList) {
        if (stPe.DPeripheral == peripheral) {
            self.currentPeri = stPe;;
        }
    }
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}
//4.连接断开或者丢失的回调
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Did disconnect peripheral %@", peripheral.name);
}
//5.连接失败的回调
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
  
}
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict{
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    
    NSLog(@"恢复 = %@", peripherals);
    
}

#pragma mark CBPeripheralDelegate
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *s in peripheral.services) {
        if (![s.UUID.UUIDString isEqualToString:@"180A"]) {
            [peripheral discoverCharacteristics:nil forService:s];
        }
    }

}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    NSData *handshake = nil;
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"特征 UUID: %@ : %@  :  %@",c.UUID.UUIDString,c.UUID,c.value);
        if ([c.UUID.UUIDString isEqualToString:UUID_NOT])
        {
            [peripheral setNotifyValue:YES forCharacteristic:c];
            [peripheral readValueForCharacteristic:c];
            handshake = c.value;
        }else if([c.UUID.UUIDString isEqualToString:UUID_WRITE])
        {
            self.currentPeri.txCharacteristic = c;
//            [self performSelector:@selector(configurationDeivce) withObject:nil afterDelay:1];
        }
    }

}
//重新构造蓝牙外设对象
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    
    
//    for (int i = 0; i < [peripherals count]; i++) {
//        
//        CBPeripheral *peripheral = [peripherals objectAtIndex:i];
//        NSLog(@"%@ --- %@",peripheral.UUID, peripheral.name);
//        NSString *name = peripheral.name;
//        if ([name isEqualToString:@""]) {
//            name = @"NO Name";
//        }
//        UARTPeripheral *uPeri = [[UARTPeripheral alloc] initWithPeripheral:peripheral andName:name];
//        self.currentPeri = uPeri;
//        //        [peripheral discoverServices:nil];
//        [self stroyDevices:uPeri];
//        [self didConnect:uPeri];
//    }
}

//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"read = %@",characteristic.value);
    char *a = (char *)[characteristic.value bytes];
    int res = [self ParseResult:(unsigned char *)a bufLen:(int)characteristic.value.length];
    if (res == 0) {
        
    }
             
             
}
//解析数据
- (int )ParseResult:(unsigned char *)buf bufLen:(int)len
{   //<11 0500 01 02 55 5d00 12>
    //<11 0f00 01 00 0900 424c55453130435634 6f02 12>
    if (buf[3] == 0x01 && buf[4] == 0x02) {//首次确认命令
        if(buf[6] == 0x55)
        {
            NSLog(@"设备正常可以通讯！");
        }else
        {
            NSLog(@"设备异常！");
 
        }
    }
    else if (buf[3] == 0x01 && buf[4] == 0x00){//设备主动发送的命令，则继续需要确认命令。
        
    
    }
    else
    {
    }
    return 0;
}


@end
