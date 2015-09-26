//
//  xTTBLEPlayer.m
//  BluetoothPlayer
//
//  Created by xTT on 14/11/20.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//

#import "xTTBLEPlayer.h"
#import "xTTPlayer.h"
#import "xTTBLEdata.h"
#import "xTTBLE.h"
@implementation xTTMusicItem
@end


@implementation xTTBLEPlayer
- (id)init {
    self = [super init];  // Call a designated initializer here.
    if (self) {
        _arrTmusics = [[NSMutableArray alloc] initWithCapacity:1000];
        _arrUmusics = [[NSMutableArray alloc] initWithCapacity:1000];
        _repeatMode = xTTBLERepeatModeDefault;
        _musicName = @"";
        _voltage = 0;
        _volume = 0;
        _signal = 10;
        
        _produceName = @"";
        _produceID = @"";
        _softwareVersion = @"";
    }
    return self;
}

- (void)loadUserEQ{
    switch ([xTTPlayer getPlayerObj].playerVCType) {
        case BlueToothVCType:{
            NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEq_B"];
            _userEQ = [[NSMutableArray alloc] initWithArray:arr];
            _EQMode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"EqType_B"] integerValue];
            _gainEQ = [[[NSUserDefaults standardUserDefaults] objectForKey:@"gainEQ_B"] floatValue];
        }
            break;
        case TcardVCType:{
            NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEq_T"];
            _userEQ = [[NSMutableArray alloc] initWithArray:arr];
            _EQMode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"EqType_T"] integerValue];
            _gainEQ = [[[NSUserDefaults standardUserDefaults] objectForKey:@"gainEQ_T"] floatValue];
        }
            break;
        case UdiskVCType:{
            NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEq_U"];
            _userEQ = [[NSMutableArray alloc] initWithArray:arr];
            _EQMode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"EqType_U"] integerValue];
            _gainEQ = [[[NSUserDefaults standardUserDefaults] objectForKey:@"gainEQ_U"] floatValue];
        }
            break;
        default:
            break;
    }
}

- (void)saveUserEQ{
    switch ([xTTPlayer getPlayerObj].playerVCType) {
        case BlueToothVCType:{
            [[NSUserDefaults standardUserDefaults] setObject:@(_EQMode)
                                                      forKey:@"EqType_B"];
            [[NSUserDefaults standardUserDefaults] setObject:_userEQ
                                                      forKey:@"UserEq_B"];
            [[NSUserDefaults standardUserDefaults] setObject:@(_gainEQ)
                                                      forKey:@"gainEQ_B"];
        }
            break;
        case TcardVCType:{
            [[NSUserDefaults standardUserDefaults] setObject:@(_EQMode)
                                                      forKey:@"EqType_T"];
            [[NSUserDefaults standardUserDefaults] setObject:_userEQ
                                                      forKey:@"UserEq_T"];
            [[NSUserDefaults standardUserDefaults] setObject:@(_gainEQ)
                                                      forKey:@"gainEQ_T"];

        }
            break;
        case UdiskVCType:{
            [[NSUserDefaults standardUserDefaults] setObject:@(_EQMode)
                                                      forKey:@"EqType_U"];
            [[NSUserDefaults standardUserDefaults] setObject:_userEQ
                                                      forKey:@"UserEq_U"];
            [[NSUserDefaults standardUserDefaults] setObject:@(_gainEQ)
                                                      forKey:@"gainEQ_U"];

        }
            break;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sendUserEq{
    NSString *gain = [NSString stringWithFormat:@"%x",(int)(_gainEQ * 1024)];
    if (gain.length > 4) {
        gain = [gain substringFromIndex:4];
    }
    NSString *type = [NSString stringWithFormat:@"%x",_EQMode];
    NSString *typeGain = [NSString stringWithFormat:@"%@%@",[xTTBLEdata intToLittle:type length:2],[xTTBLEdata intToLittle:gain length:4]];
    if (_EQMode != EQ_MODE_USER) {
        NSString *temp = [NSString stringWithFormat:@"%@0000",[xTTBLEdata intToLittle:type length:2]];
        [[xTTBLE getBLEObj] sendBLEuserData:temp
                                       type:BTR_SET_EQ_MODE];
        return;
    }
    if ([xTTPlayer getPlayerObj].BLEplay.userEQ.count == 0) {
        return;
    }
    NSString *data = [NSString stringWithFormat:@"%d",_userEQ.count];
    data = [xTTBLEdata intToLittle:data length:4];
    
    __block NSString *data1 = @"";
    __block NSString *data2 = @"";
    __block NSString *data3 = @"";
    __block NSString *data4 = @"";
    
    NSArray *arr = @[@"HPF", @"LPF", @"HSF", @"LSF", @"PF"];
    [_userEQ enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isEqualToString:@"频率"]) {
                NSString *tmp = [NSString stringWithFormat:@"%x",[obj intValue]];
                data1 = [NSString stringWithFormat:@"%@%@",data1,[xTTBLEdata intToLittle:tmp length:8]];
            }else if ([key isEqualToString:@"增益"]){
                NSString *tmp = [NSString stringWithFormat:@"%x",(int)([obj intValue] * 1024)];
                if (tmp.length > 4) {
                    tmp = [tmp substringFromIndex:4];
                }
                data2 = [NSString stringWithFormat:@"%@%@",data2,[xTTBLEdata intToLittle:tmp length:4]];
            }else if ([key isEqualToString:@"q值"]){
                NSString *tmp = [NSString stringWithFormat:@"%x",(int)([obj floatValue] * 1024)];
                data3 = [NSString stringWithFormat:@"%@%@",data3,[xTTBLEdata intToLittle:tmp length:4]];
            }else if ([key isEqualToString:@"类型"]){
                switch ([arr indexOfObject:obj]) {
                    case 0:
                        data4 = [NSString stringWithFormat:@"%@0100",data4];
                        break;
                    case 1:
                        data4 = [NSString stringWithFormat:@"%@0200",data4];
                        break;
                    case 2:
                        data4 = [NSString stringWithFormat:@"%@0300",data4];
                        break;
                    case 3:
                        data4 = [NSString stringWithFormat:@"%@0400",data4];
                        break;
                    case 4:
                        data4 = [NSString stringWithFormat:@"%@0500",data4];
                        break;
                    default:
                        break;
                }
                
            }
        }];
    }];
    NSString *aaa = [NSString stringWithFormat:@"%@%@%@%@%@%@",typeGain,data,data1,data2,data3,data4];
    [[xTTBLE getBLEObj] sendBLEuserData:aaa
                                   type:BTR_SET_EQ_USER_DEFINE];
}

@end
