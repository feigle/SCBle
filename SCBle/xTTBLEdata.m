//
//  xTTBLEdata.m
//  BluetoothPlayer
//
//  Created by xTT on 14/11/4.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//

//        0000 0000  单首 00

//        0000 0001  分首 01
//        0000 1001  分中 09
//        0001 0001  分结 11

//        0000 0010  回首 02
//        0000 1010  回中 0a
//        0001 0010  回结 12

// 任何命令 回应不做分包

#import "xTTBLEdata.h"
#include "xTTPlayer.h"
#import "AppDelegate.h"
#import "xTTBLE.h"
//#import "WirelessNetworkcardViewController.h"
//#import "WirelessUPlateViewController.h"

@implementation xTTBLEdata
{
    NSInteger index;
    NSString *musicName;
}

- (id)init{
    self = [super init];  // Call a designated initializer here.
    if (self) {
        _arrCommand = [[NSMutableArray alloc] init];
        musicName = @"";
    }
    return self;
}

- (void)removeAllData{
    _dBT = @"";
    _dBCD = @"";
    _dMLBM = @"";
    _dMLXX = @"";
    _dYHSJCD = @"";
    _dBID = @"";
    _dYHSJPY = @"";
    _dBQRBS = @"";
    _dYHSJ = @"";
    _dJYH = @"";
    _dBW = @"";
    _allData = @"";
}

//解析数据
- (void)setBELData:(NSData *)data{
    [self removeAllData];
    NSString *str = [xTTBLEdata NSDataToByteTohex:data];
    if (str.length > 10){
        _allData = str;
        
        _dBT    = [str substringWithRange:NSMakeRange(0, 2)];
        _dBCD   = [str substringWithRange:NSMakeRange(2, 4)];
        _dMLBM  = [str substringWithRange:NSMakeRange(6, 2)];
        _dMLXX  = [str substringWithRange:NSMakeRange(8, 2)];
        
        if ([_dMLXX isEqualToString:@"00"] || [_dMLXX isEqualToString:@"01"]) {
            _dYHSJCD    = [str substringWithRange:NSMakeRange(10, 4)];
            _dYHSJ      = [str substringWithRange:NSMakeRange(14, str.length - 20)];
        }else if ([_dMLXX isEqualToString:@"09"] || [_dMLXX isEqualToString:@"11"] || [_dMLXX isEqualToString:@"0a"] || [_dMLXX isEqualToString:@"12"]){
            _dYHSJPY    = [str substringWithRange:NSMakeRange(10, 4)];
            _dBID       = [str substringWithRange:NSMakeRange(14, 4)];
            _dYHSJ      = [str substringWithRange:NSMakeRange(14,  str.length - 20)];
        }else if ([_dMLXX isEqualToString:@"02"]){
            _dBQRBS  = [str substringWithRange:NSMakeRange(10, 2)];
            _dYHSJ   = [str substringWithRange:NSMakeRange(12, str.length - 18)];
        }
        
        _dJYH   = [str substringWithRange:NSMakeRange(str.length - 6, 4)];
        _dBW    = [str substringWithRange:NSMakeRange(str.length - 2, 2)];
    }
}

//处理数据
- (void)processBELData{
    if ([_dMLBM isEqualToString:@"02"]) {
        [self setSPPCommand];
    }else{
        [self processGetSPPCommand];
    }
}

//发送回应命令
- (NSData *)getResponseDataWith:(BOOL)isValidate MLXX:(NSString *)mlxx MLBM:(NSString *)mlbm
{
//    11 0500 01  02 55 5d00  12
    NSMutableString *str = [NSMutableString string];
    
    [str appendString:@"11"];
    
    int i = 0;
    [str appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",5] length:4]];//包长度
    i += 5;

    [str appendString:mlbm];
    i += [xTTBLEdata littleEndianModeToInt:mlbm];
    
    if ([mlxx isEqualToString:@"00"] || [mlxx isEqualToString:@"01"]) {
        [str appendString:@"02"];
        i += [xTTBLEdata littleEndianModeToInt:@"02"];
    }else if ([mlxx isEqualToString:@"09"]){
        [str appendString:@"0a"];
        i += [xTTBLEdata littleEndianModeToInt:@"0a"];
    }else if ([mlxx isEqualToString:@"11"]){
        [str appendString:@"12"];
        i += [xTTBLEdata littleEndianModeToInt:@"12"];
    }
    
    if (isValidate) {
        [str appendString:@"55"];
        i += [xTTBLEdata littleEndianModeToInt:@"55"];
    }else{
        [str appendString:@"aa"];
        i += [xTTBLEdata littleEndianModeToInt:@"aa"];
    }
    
    [str appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",i] length:4]];//校验和
    
    [str appendString:@"12"];
    
    return [xTTBLEdata stringToByte:str];
}

//检测数据是否正确
- (BOOL)isValidateData:(NSString *)str
{
    if ([str hasPrefix:@"11"] && [str hasSuffix:@"12"]
        && [self getJYHint:str] == [xTTBLEdata littleEndianModeToInt:[str substringWithRange:NSMakeRange(str.length - 6, 4)]]) {
        return YES;
    }
    return NO;
}

//得到校验和
- (int)getJYHint:(NSString *)str{
    int jyh = 0;
    for (int i = 2; i < str.length - 6; i+=2) {
        jyh += [xTTBLEdata littleEndianModeToInt:[str substringWithRange:NSMakeRange(i, 2)]];
    }
    return jyh;
}

//得到命令总数和初始化
- (void)setSPPCommand{
    if (![[_arrCommand componentsJoinedByString:@""] isEqualToString:_dYHSJ]) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i < _dYHSJ.length; i += 2) {
            [arr addObject:[_dYHSJ substringWithRange:NSMakeRange(i, 2)]];
        }
        
        [_arrCommand removeAllObjects];
        _arrCommand = [NSMutableArray arrayWithArray:arr];
    }
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_GET_PLAY_MODE];
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_GET_VOLTAGE];
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_GET_PLAY_STATUS];
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_GET_EQ_MODE];
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_GET_BT_SIGNAL];
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_GET_STDB_MODE];
}

//发送数据
- (NSData *)getDataWithUserData:(NSString *)userData
                           type:(SPP_Command)type
                           MLXX:(NSString *)mlxx
                            BID:(NSString *)bid
                         YHSJPY:(NSString *)yhsjpy
                        YHSJZCD:(int)yhsjzcd{
    NSMutableString *commandStr = [NSMutableString string];
    
    [commandStr appendString:@"11"];
    
    long jyh = 0;
    if ([mlxx isEqualToString:@"00"] ||[mlxx isEqualToString:@"01"]) {
        [commandStr appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",6 + userData.length / 2] length:4]];//包长度
    }else if ([mlxx isEqualToString:@"09"] || [mlxx isEqualToString:@"11"]){
        [commandStr appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",8 + userData.length / 2] length:4]];//包长度
    }
    
    if (type == 100) {
        [commandStr appendString:@"01"];
    }else{
        NSInteger index = type - 1;
        [commandStr appendString:_arrCommand[index]];
    }
    
    [commandStr appendString:mlxx];
    
    if ([mlxx isEqualToString:@"00"] ||[mlxx isEqualToString:@"01"]){
        [commandStr appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",yhsjzcd] length:4]];//用户数据
    }
    
    if ([mlxx isEqualToString:@"09"] || [mlxx isEqualToString:@"11"]){
        [commandStr appendString:[xTTBLEdata intToLittle:bid length:4]];
        [commandStr appendString:[xTTBLEdata intToLittle:yhsjpy length:4]];
    }
    
    [commandStr appendString:userData];
    
    for (int i = 2; i < commandStr.length; i+=2) {
        jyh += [xTTBLEdata littleEndianModeToInt:[commandStr substringWithRange:NSMakeRange(i, 2)]];
    }
    
    [commandStr appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%lx",jyh] length:4]];//校验和
    
    [commandStr appendString:@"12"];
    return [xTTBLEdata stringToByte:commandStr];
}

//获得歌曲名
- (xTTMusicItem *)getMusicName:(NSString *)nameData{
    NSMutableArray *arr = [NSMutableArray array];
    
    for (int i = 0; i < _dYHSJ.length;) {
        NSString *tmp = [NSString stringWithFormat:@"\\u%@",[_dYHSJ substringWithRange:NSMakeRange(i+2, 2)]];
        tmp = [NSString stringWithFormat:@"%@%@",tmp,[_dYHSJ substringWithRange:NSMakeRange(i, 2)]];
        i += 4;
        [arr addObject:tmp];
    }
    
    if (([_dMLXX isEqual:@"01"] || [_dMLXX isEqual:@"00"]) && arr.count > 0) {
        NSString *tmp1 = [NSString stringWithFormat:@"%@",[arr[0] substringWithRange:NSMakeRange(4, 2)]];
        tmp1 = [NSString stringWithFormat:@"%@%@",tmp1,[arr[0] substringWithRange:NSMakeRange(2, 2)]];
        index = [xTTBLEdata littleEndianModeToInt:tmp1];
        [arr removeObjectAtIndex:0];
    }
    
    if ([_dMLXX isEqual:@"00"]) {
        xTTMusicItem *item = [[xTTMusicItem alloc] init];
        item.musicName = [xTTBLEdata replaceUnicode:[arr componentsJoinedByString:@""]];
        item.musicID = index;
        return item;
    }else if([_dMLXX isEqual:@"11"]){
        xTTMusicItem *item = [[xTTMusicItem alloc] init];
        item.musicName = [NSString stringWithFormat:@"%@%@",musicName,[xTTBLEdata replaceUnicode:[arr componentsJoinedByString:@""]]];
        item.musicID = index;
        musicName = @"";
        return item;
    }
    
    musicName = [NSString stringWithFormat:@"%@%@",musicName,[xTTBLEdata replaceUnicode:[arr componentsJoinedByString:@""]]];
    return nil;
}

//添加歌曲到列表中
- (NSMutableArray *)addMusicItem:(xTTMusicItem *)item{
    NSMutableArray *arr;
    if ([xTTPlayer getPlayerObj].playerVCType == TcardVCType) {
        arr = [NSMutableArray arrayWithArray:[xTTPlayer getPlayerObj].BLEplay.arrTmusics];
    }else if ([xTTPlayer getPlayerObj].playerVCType == UdiskVCType){
        arr = [NSMutableArray arrayWithArray:[xTTPlayer getPlayerObj].BLEplay.arrUmusics];
    }
    __block BOOL hasItem = NO;
    [arr enumerateObjectsUsingBlock:^(xTTMusicItem *obj, NSUInteger idx, BOOL *stop) {
        if (obj.musicID == item.musicID) {
            hasItem = YES;
            *stop = YES;
        }
    }];
    if (!hasItem) {
        __block NSUInteger i = arr.count;
        [arr enumerateObjectsUsingBlock:^(xTTMusicItem *obj, NSUInteger idx, BOOL *stop) {
            if (item.musicID < obj.musicID) {
                i = idx;
                *stop = YES;
            }
        }];
        if (i == arr.count) {
            [arr addObject:item];
        }else{
            [arr insertObject:item atIndex:i];
        }
        if ([xTTPlayer getPlayerObj].playerVCType == TcardVCType) {
            [xTTPlayer getPlayerObj].BLEplay.arrTmusics = [NSMutableArray arrayWithArray:arr];
        }else if ([xTTPlayer getPlayerObj].playerVCType == UdiskVCType){
            [xTTPlayer getPlayerObj].BLEplay.arrUmusics = [NSMutableArray arrayWithArray:arr];
        }
    }
    return arr;
}

//处理命令数据
- (void)processGetSPPCommand{
    switch ([_arrCommand indexOfObject:_dMLBM] + 1) {
        case 1://切换系统工作模式
        {
//            AppDelegate *app = [UIApplication sharedApplication].delegate;
//            UITabBarController *tab = (UITabBarController *)app.window.rootViewController;

            NSLog(@"切换系统工作模式 : %@",_dYHSJ);
            if ([_dYHSJ isEqual:@"00"]) {
                [xTTPlayer getPlayerObj].playerVCType = BlueToothVCType;
                [[xTTPlayer getPlayerObj].BLEplay loadUserEQ];
                [[xTTPlayer getPlayerObj].BLEplay sendUserEq];
//                UINavigationController *VC1 = tab.viewControllers[1];
//                [(WirelessNetworkcardViewController *)VC1.topViewController deleteNOT];
//                UINavigationController *VC2 = tab.viewControllers[2];
//                [(WirelessUPlateViewController *)VC2.topViewController deleteNOT];
//                tab.selectedIndex = 0;
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SWITCH_MODE" object:_dYHSJ];
            }else if ([_dYHSJ isEqual:@"01"]){
                [xTTPlayer getPlayerObj].playerVCType = UdiskVCType;
                [[xTTPlayer getPlayerObj].BLEplay loadUserEQ];
                [[xTTPlayer getPlayerObj].BLEplay sendUserEq];
//                UINavigationController *VC1 = tab.viewControllers[1];
//                [(WirelessNetworkcardViewController *)VC1.topViewController deleteNOT];
//                tab.selectedIndex = 2;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SWITCH_MODE" object:_dYHSJ];
            }else if ([_dYHSJ isEqual:@"03"]){
                [xTTPlayer getPlayerObj].playerVCType = TcardVCType;
                [[xTTPlayer getPlayerObj].BLEplay loadUserEQ];
                [[xTTPlayer getPlayerObj].BLEplay sendUserEq];
//                UINavigationController *VC2 = tab.viewControllers[2];
//                [(WirelessUPlateViewController *)VC2.topViewController deleteNOT];
//                tab.selectedIndex = 1;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SWITCH_MODE" object:_dYHSJ];
            }else if ([_dBQRBS isEqual:@"ac"] || [_dBQRBS isEqual:@"55"] || [_dBQRBS isEqual:@"ab"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SWITCH_MODE" object:_dBQRBS];
            }else{
                [xTTPlayer getPlayerObj].playerVCType = UnDefine;
//                UINavigationController *VC1 = tab.viewControllers[1];
//                [(WirelessNetworkcardViewController *)VC1.topViewController deleteNOT];
//                UINavigationController *VC2 = tab.viewControllers[2];
//                [(WirelessUPlateViewController *)VC2.topViewController deleteNOT];
//                tab.selectedIndex = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SWITCH_MODE" object:nil];
            }
        }
            break;
        case 2://得到指定序号的播放歌曲名
        {
            
            xTTMusicItem *musicItem = [self getMusicName:_dYHSJ];
            if (!musicItem) {
                return;
            }
            NSLog(@"单歌曲 --- %@  %d",musicItem.musicName,musicItem.musicID);
            [xTTPlayer getPlayerObj].BLEplay.musicName = musicItem.musicName;
            [xTTPlayer getPlayerObj].BLEplay.nowItem = musicItem.musicID;
            
            [self addMusicItem:musicItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_REQUEST_MUSIC_NAME" object:nil];
        }
            break;
        case 3://发送指定序号的播放歌曲名
        {
            xTTMusicItem *musicItem = [self getMusicName:_dYHSJ];
            if (!musicItem) {
                return;
            }
            NSLog(@"单歌曲 --- %@  %d",musicItem.musicName,musicItem.musicID);
            
            [xTTPlayer getPlayerObj].BLEplay.musicName = musicItem.musicName;
            [xTTPlayer getPlayerObj].BLEplay.nowItem = musicItem.musicID;
            
            [self addMusicItem:musicItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SEND_MUSIC_NAME" object:nil];
        }
            break;
        case 4://得到当前播放的列表
        {
            xTTMusicItem *musicItem = [self getMusicName:_dYHSJ];
            if (!musicItem) {
                return;
            }
            NSLog(@"歌曲 --- %@  %d",musicItem.musicName,musicItem.musicID);

            [self addMusicItem:musicItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_REQUEST_MUSIC_LIST" object:nil];
        }
            break;
        case 5://发送指定序列的播放列表
        {
            xTTMusicItem *musicItem = [self getMusicName:_dYHSJ];
            if (!musicItem) {
                return;
            }
            NSLog(@"歌曲 --- %@  %d",musicItem.musicName,musicItem.musicID);

            [self addMusicItem:musicItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SEND_MUSIC_LIST" object:nil];
        }
            break;
        case 6://设置音量
        {
            NSLog(@"设置音量 %@",_dYHSJ);
            [xTTPlayer getPlayerObj].BLEplay.volume = [xTTBLEdata littleEndianModeToInt:_dYHSJ];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_VOL" object:nil];
        }
            break;
        case 7://得到当前音量
        {
            [xTTPlayer getPlayerObj].BLEplay.volume = [xTTBLEdata littleEndianModeToInt:_dYHSJ];
            NSLog(@"得到当前音量 %@",_dYHSJ);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_VOL" object:nil];
        }
            break;
        case 8://设置当前播放状态
        {
            NSLog(@"设置当前播放状态 %@",_dYHSJ);
            if ([_dYHSJ isEqual:@"00"]) {
                [xTTPlayer getPlayerObj].BLEplay.playState = xTTBLEplayStatePaused;
            }else if ([_dYHSJ isEqual:@"01"]){
                [xTTPlayer getPlayerObj].BLEplay.playState = xTTBLEplayStatePlay;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_PLAY_STATUS" object:nil];            
        }
            break;
        case 9://得到当前播放状态
        {
            NSLog(@"得到当前播放状态 %@",_dYHSJ);
            if ([_dYHSJ isEqual:@"00"]) {
                [xTTPlayer getPlayerObj].BLEplay.playState = xTTBLEplayStatePaused;
            }else if ([_dYHSJ isEqual:@"01"]){
                [xTTPlayer getPlayerObj].BLEplay.playState = xTTBLEplayStatePlay;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_PLAY_STATUS" object:nil];
        }
            break;
        case 10://设置当前的 EQ 模式
        {
            if ([_dYHSJ isEqual:@"00"]) {
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_NORMAL;
            }else if ([_dYHSJ isEqual:@"01"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_CLASSIC;
            }else if ([_dYHSJ isEqual:@"02"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_JAZZ;
            }else if ([_dYHSJ isEqual:@"03"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_POP;
            }else if ([_dYHSJ isEqual:@"04"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_ROCK;
            }else if ([_dYHSJ isEqual:@"05"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_EXBASS;
            }else if ([_dYHSJ isEqual:@"06"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_SOFT;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_EQ_MODE" object:nil];
            NSLog(@"设置当前的 EQ 模式 %@",_dYHSJ);
        }
            break;
        case 11://得到当前 EQ 模式
        {
            NSLog(@"得到当前 EQ 模式 %@",_dYHSJ);
            if ([_dYHSJ isEqual:@"00"]) {
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_NORMAL;
            }else if ([_dYHSJ isEqual:@"01"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_CLASSIC;
            }else if ([_dYHSJ isEqual:@"02"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_JAZZ;
            }else if ([_dYHSJ isEqual:@"03"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_POP;
            }else if ([_dYHSJ isEqual:@"04"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_ROCK;
            }else if ([_dYHSJ isEqual:@"05"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_EXBASS;
            }else if ([_dYHSJ isEqual:@"06"]){
                [xTTPlayer getPlayerObj].BLEplay.EQMode = EQ_MODE_SOFT;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_EQ_MODE" object:nil];
        }
            break;
        case 12://设置用户自定义 EQ
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_EQ_USER_DEFINE" object:nil];
            NSLog(@"设置用户自定义 EQ");            
        }
            break;
        case 13://得到用户自定义 EQ
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_EQ_USER_DEFINE" object:nil];
            NSLog(@"得到用户自定义 EQ");
        }
            break;
        case 14://设置当前播放模式
        {
            [[xTTBLE getBLEObj] sendBLEuserData:@""
                                           type:BTR_GET_PLAY_MODE];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_PLAY_MODE" object:nil];
            NSLog(@"设置当前播放模式 %@",_dYHSJ);
            return;
        }
            break;
        case 15://得到当前的播放模式
        {
            NSLog(@"得到当前的播放模式 %@",_dYHSJ);
            if ([_dYHSJ isEqual:@"00"]){
                [xTTPlayer getPlayerObj].BLEplay.repeatMode = xTTBLERepeatModeDefault;
            }else if ([_dYHSJ isEqual:@"01"]){
                [xTTPlayer getPlayerObj].BLEplay.repeatMode = xTTBLERepeatModeOne;
            }else if ([_dYHSJ isEqual:@"02"]){
                [xTTPlayer getPlayerObj].BLEplay.repeatMode = xTTBLERepeatModeAll;
            }else if ([_dYHSJ isEqual:@"03"]){
                [xTTPlayer getPlayerObj].BLEplay.repeatMode = xTTBLERepeatModeNone;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_PLAY_MODE" object:nil];
        }
            break;
        case 16://得到设备电压
        {
            NSLog(@"得到设备电压");
            [xTTPlayer getPlayerObj].BLEplay.voltage = [xTTBLEdata littleEndianModeToInt:_dYHSJ];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_VOLTAGE" object:nil];
        }
            break;
        case 17://设置当前播放的歌曲
        {
            NSDictionary *musicDic = [self getMusicName:_dYHSJ];
            if (!musicDic) {
                return;
            }
            [musicDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [xTTPlayer getPlayerObj].BLEplay.musicName = obj;
                [xTTPlayer getPlayerObj].BLEplay.nowItem = [key integerValue] + 1;
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_PLAY_MUSICID" object:nil];
            NSLog(@"设置当前播放的歌曲");            
        }
            break;
        case 18://设置上下曲
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_LAST_NEXT" object:nil];
            NSLog(@"设置上下曲");
        }
            break;
        case 19://得到系统工作模式
        {
            NSLog(@"得到系统工作模式 %@",_dYHSJ);
            if ([_dYHSJ isEqual:@"00"]) {
                [xTTPlayer getPlayerObj].playerVCType = BlueToothVCType;
            }else if ([_dYHSJ isEqual:@"01"]){
                [xTTPlayer getPlayerObj].playerVCType = UdiskVCType;
            }else if ([_dYHSJ isEqual:@"03"]){
                [xTTPlayer getPlayerObj].playerVCType = TcardVCType;
            }
            [[xTTPlayer getPlayerObj].BLEplay loadUserEQ];
            [[xTTPlayer getPlayerObj].BLEplay sendUserEq];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_STDB_MODE" object:_dYHSJ];
        }
            break;
        case 20://通知列表发完
        {
            NSLog(@"通知列表发完");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SEND_LIST_OVER" object:nil];
        }
            break;
        case 21://通知 T 卡有插拔动作
        {
            NSLog(@"通知 T 卡有插拔动作");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SEND_TF_STATUS" object:nil];
        }
            break;
        case 22://获取 T 卡状态
        {
            NSLog(@"获取 T 卡状态");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_TF_STATUS" object:nil];
        }
            break;
        case 23://得到 FM 的频道列表
        {
            NSLog(@"得到 FM 的频道列表");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_FM_LIST" object:nil];
        }
            break;
        case 24://得到 FM 当前频道
        {
            NSLog(@"得到 FM 当前频道");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_FM_PLAY_ID" object:nil];
        }
            break;
        case 25://设置 FM 的播放频道
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_FM_PLAY_ID" object:nil];
            NSLog(@"设置 FM 的播放频道");
        }
            break;
        case 26://设置系统时钟
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_SYSTEM_TIME" object:nil];
            NSLog(@"设置系统时钟");
        }
            break;
        case 27://得到系统时钟
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_SYSTEM_TIME" object:nil];
            NSLog(@"得到系统时钟");
        }
            break;
        case 28://得到系统闹钟
        {
            NSLog(@"得到系统闹钟");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_ALARM_TIME" object:nil];
        }
            break;
        case 29://设置系统闹钟
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_ALARM_TIME" object:nil];
            NSLog(@"设置系统闹钟");
        }
            break;
        case 30://设置音乐播放快进/快退开始
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_PLAY_BACK_FORWARD_START" object:nil];
            NSLog(@"设置音乐播放快进/快退开始");
        }
            break;
        case 31://设置音乐播放快进/快退结束
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_PLAY_BACK_FORWARD_STOP" object:nil];
            NSLog(@"设置音乐播放快进/快退结束");
        }
            break;
        case 32://得到音乐播放快进/快退状态
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_PLAY_BACK_FORWARD_STATE" object:nil];
            NSLog(@"得到音乐播放快进/快退状态");
        }
            break;
        case 33://获得产品名称
        {
            [xTTPlayer getPlayerObj].BLEplay.produceName = [self getNameWithASCII:_dYHSJ];
            NSLog(@"获得产品名称 %@",[xTTPlayer getPlayerObj].BLEplay.produceName);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_PRODUCE_NAME" object:nil];
        }
            break;
        case 34://获取软件版本
        {
            [xTTPlayer getPlayerObj].BLEplay.softwareVersion = [self getNameWithASCII:_dYHSJ];
            NSLog(@"获取软件版本 %@",[xTTPlayer getPlayerObj].BLEplay.softwareVersion);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_SOFTWARE_VERSION" object:nil];
        }
            break;
        case 35://获取产品序列号
        {
            [xTTPlayer getPlayerObj].BLEplay.produceID = [self getNameWithASCII:_dYHSJ];
            NSLog(@"获取产品序列号 %@",[xTTPlayer getPlayerObj].BLEplay.produceID);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_PRODUCER_SERIAL_ID" object:nil];
        }
            break;
        case 36://获取蓝牙信号强度
        {
            NSLog(@"获取蓝牙信号强度");
            [xTTPlayer getPlayerObj].BLEplay.signal = [xTTBLEdata littleEndianModeToInt:_dYHSJ];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_BT_SIGNAL" object:nil];
        }
            break;
        case 37://获取蓝牙信号强度
        {
            NSLog(@"获取蓝牙信号强度");
            [xTTPlayer getPlayerObj].BLEplay.signal = [xTTBLEdata littleEndianModeToInt:_dYHSJ];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_BT_SIGNAL" object:nil];
        }
            break;

        case 38://得到设备电压
        {
            NSLog(@"得到设备电压");
            [xTTPlayer getPlayerObj].BLEplay.voltage = [xTTBLEdata littleEndianModeToInt:_dYHSJ];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_VOLTAGE" object:nil];
        }
            break;

        case 39://获得A2DP状态
        {
            NSLog(@"获得A2DP状态");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_A2DP_CONNECT_STATE" object:_dYHSJ];
        }
            break;
        case 40://自定义命令
        {
            NSLog(@"自定义命令");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_USERDEFINE" object:nil];
        }
            break;
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"not_SPP_TO_VIEW" object:nil];
}

//解析ASCII
- (NSString *)getNameWithASCII:(NSString *)str{
    NSString *tmp1 = @"";
    for (int i = 0 ; i< str.length; i+=2) {
        NSString *tmp2 = [NSString stringWithFormat:@"%c",[xTTBLEdata ToHex:[str substringWithRange:NSMakeRange(i, 2)]]];
        tmp1 = [NSString stringWithFormat:@"%@%@",tmp1,tmp2];
    }
    return tmp1;
}

//用户数转成小端模式
+ (NSString *)intToLittle:(NSString *)str length:(int)length{
    if (str.length % 2 == 1) {
        str = [NSString stringWithFormat:@"0%@",str];
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < str.length / 2 ; i++) {
        [arr insertObject:[str substringWithRange:NSMakeRange(i * 2, 2)] atIndex:0];
    }
    NSString *tmp = [arr componentsJoinedByString:@""];
    if (tmp.length < length) {
        for (; tmp.length < length; ) {
            tmp = [NSString stringWithFormat:@"%@00",tmp];
        }
    }else if (tmp.length > length){
        tmp = [str substringWithRange:NSMakeRange(0, length)];
    }
    return tmp;
}

//小端转int
+ (int)littleEndianModeToInt:(NSString *)str{
    int count = 0;
    for (int i = 0; i < str.length / 2; i++) {
        int j = [self ToHex:[str substringWithRange:NSMakeRange(i * 2, 2)]];
        if (i != 0) {
            j *= (i * 256);
        }
        count += j;
    }
//    NSLog(@"%d",count);
    return count;
}

//Byte数组－>16进制数(去转义符)
+ (NSString *)NSDataToByteTohex:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    BOOL isZhuanYi = NO;
    BOOL addDid = NO;
    for(int i = 0 ; i<[data length] ; i++)
    {
        NSString *newHexStr = @"";
        if (isZhuanYi) {
            isZhuanYi = NO;
            if (![[NSString stringWithFormat:@"%x",bytes[i]&0xff] isEqual:@"0"]) {
                newHexStr = [NSString stringWithFormat:@"%x",(bytes[i] - 19)&0xff];///16进制数
                if ([[NSString stringWithFormat:@"%x",bytes[i]&0xff] isEqual:@"26"]) {
                    if([newHexStr length]==1)
                        hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
                    else
                        hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
                }
            }else{
                addDid = YES;
                newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
                if([newHexStr length]==1)
                    hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
                else
                    hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
            }
        }else{
            newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        }
        
        if (addDid && ![newHexStr isEqualToString:@"13"]) {
            addDid = NO;
        }else if ([newHexStr isEqualToString:@"13"]) {
            isZhuanYi = YES;
        }else if (!addDid){
            if([newHexStr length]==1)
                hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            else
                hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
//    NSLog(@"hexStr:%@",hexStr);
    return hexStr;
}

//16进制转10进制
+ (int)ToHex:(NSString*)tmpid
{
    int int_ch;
    unichar hex_char1 = [tmpid characterAtIndex:0];
    
    int int_ch1;
    
    if(hex_char1 >= '0'&& hex_char1 <='9')
        int_ch1 = (hex_char1-48)*16;
    else if(hex_char1 >= 'A'&& hex_char1 <='F')
        int_ch1 = (hex_char1-55)*16;
    else
        int_ch1 = (hex_char1-87)*16;

    unichar hex_char2 = [tmpid characterAtIndex:1];
    int int_ch2;
    if(hex_char2 >= '0'&& hex_char2 <='9')
        int_ch2 = (hex_char2-48);
    else if(hex_char2 >= 'A'&& hex_char2 <='F')
        int_ch2 = hex_char2-55;
    else
        int_ch2 = hex_char2-87;
    
    int_ch = int_ch1+int_ch2;
    
    return int_ch;
}

//string转data (加转义符)
+ (NSData*)stringToByte:(NSString*)string
{
    NSString *hexString = [[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSInteger length = hexString.length;
    for (int i = 2; i < length - 2; i += 2) {
        if ([[hexString substringWithRange:NSMakeRange(i, 2)] isEqualToString:@"11"]) {
            hexString = [hexString stringByReplacingCharactersInRange:NSMakeRange(i, 2) withString:@"1324"];
            i += 2;
            length += 2;
        }else if([[hexString substringWithRange:NSMakeRange(i, 2)] isEqualToString:@"12"]){
            hexString = [hexString stringByReplacingCharactersInRange:NSMakeRange(i, 2) withString:@"1325"];
            i += 2;
            length += 2;
        }else if([[hexString substringWithRange:NSMakeRange(i, 2)] isEqualToString:@"13"]){
            hexString = [hexString stringByReplacingCharactersInRange:NSMakeRange(i, 2) withString:@"1326"];
            i += 2;
            length += 2;
        }
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes = [NSMutableData data];
    for (int i = 0; i < hexString.length; ++i)
    {
        tempbyt[0] = [self ToHex:[hexString substringWithRange:NSMakeRange(i, 2)]];  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
        i++;
    }
    return bytes;
}

//10转2进制
+ (NSString *)toBinary:(int)input
{
    if (input == 1 || input == 0) {
        return [NSString stringWithFormat:@"%d", input];
    }
    else {
        return [NSString stringWithFormat:@"%@%d", [self toBinary:input / 2], input % 2];
    }
}

//Unicode转汉字
+ (NSString*) replaceUnicode:(NSString*)aUnicodeString
{
    NSString *tempStr1 = [aUnicodeString stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"]; 
}

@end
