//
//  xTTBLEdata.h
//  BluetoothPlayer
//
//  Created by xTT on 14/11/4.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//SPP_GET_TF_STATUS
//#include <stdio.h>





#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, SPP_Command) {
    BTR_SWITCH_MODE                 = 1,    //切换系统工作模式     //
    BTR_REQUEST_MUSIC_NAME          = 2,    //得到指定序号的播放歌曲名
    BTR_SEND_MUSIC_NAME             = 3,    //发送指定序号的播放歌曲名
    
    BTR_REQUEST_MUSIC_LIST          = 4,    //得到当前播放的列表
    BTR_SEND_MUSIC_LIST             = 5,    //发送指定序列的播放列表
    
    BTR_SET_VOL                     = 6,    //设置音量          //
    BTR_GET_VOL                     = 7,    //得到当前音量
    
    BTR_SET_PLAY_STATUS             = 8,    //设置当前播放状态
    BTR_GET_PLAY_STATUS             = 9,    //得到当前播放状态
    
    BTR_SET_EQ_MODE                 =10,    //设置当前的 EQ 模式
    BTR_GET_EQ_MODE                 =11,    //得到当前 EQ 模式    //
    BTR_SET_EQ_USER_DEFINE          =12,    //设置用户自定义 EQ
    BTR_GET_EQ_USER_DEFINE          =13,    //得到用户自定义 EQ
    
    BTR_SET_PLAY_MODE               =14,    //设置当前播放模式
    BTR_GET_PLAY_MODE               =15,    //得到当前的播放模式
    
    BTR_GET_VOLTAGE                 =16,    //得到设备电压
    BTR_SET_PLAY_MUSICID            =17,    //设置当前播放的歌曲
    BTR_SET_LAST_NEXT               =18,    //设置上下曲
    BTR_GET_STDB_MODE               =19,    //得到系统工作模式
    
    BTR_SEND_LIST_OVER              =20,    //通知列表发完
    
    BTR_SEND_TF_STATUS              =21,    //通知 T 卡有插拔动作
    BTR_GET_TF_STATUS               =22,    //获取 T 卡状态
    
    BTR_GET_FM_LIST                 =23,    //得到 FM 的频道列表
    BTR_GET_FM_PLAY_ID              =24,    //得到 FM 当前频道
    BTR_SET_FM_PLAY_ID              =25,    //设置 FM 的播放频道
    
    BTR_SET_SYSTEM_TIME             =26,    //设置系统时钟
    BTR_GET_SYSTEM_TIME             =27,    //得到系统时钟
    
    BTR_GET_ALARM_TIME              =28,    //得到系统闹钟
    BTR_SET_ALARM_TIME              =29,    //设置系统闹钟
    
    BTR_SET_PLAY_BACK_FORWARD_START =30,    //设置音乐播放快进/快退开始
    BTR_SET_PLAY_BACK_FORWARD_STOP  =31,    //设置音乐播放快进/快退结束
    BTR_GET_PLAY_BACK_FORWARD_STATE =32,    //得到音乐播放快进/快退状态
    
    BTR_GET_PRODUCE_NAME            =33,    //获得产品名称
    BTR_GET_SOFTWARE_VERSION        =34,    //获得产品软件版本
    BTR_GET_PRODUCER_SERIAL_ID      =35,    //获得产品序列号
    //    BTR_GET_RECORD_COUNT            =36,    //获得纪录总数
    //    BTR_GET_REC_CONTENT_BY_ID       =37,    //通过编号获得记录内容
    //    BTR_SET_USERINFO                =36,    //设置用户信息
    //    BTR_GET_USERINFO                =37,    //得到用户信息
    BTR_GET_BT_SIGNAL               =36,    //获取蓝牙信号强度
    BTR_SET_BT_SIGNAL               =37,
    BTR_SET_BT_VOLTAGE              =38,
    BTR_GET_A2DP_CONNECT_STATE      =39,    //获得A2DP状态
    BTR_USERDEFINE                  =40,    //自定义命令
    
    BTR_WOSHOU                      =100
};



@interface xTTBLEdata : NSObject


@property (nonatomic,strong) NSString *dBT;     //包头(1)
@property (nonatomic,strong) NSString *dBCD;    //包长度(2)
@property (nonatomic,strong) NSString *dMLBM;   //命令编码(1)
@property (nonatomic,strong) NSString *dMLXX;   //命令信息(1)


@property (nonatomic,strong) NSString *dYHSJCD; //用户数据总长度(2)(单命令或首包)


@property (nonatomic,strong) NSString *dBID;    //包ID(2)(分包命令)
@property (nonatomic,strong) NSString *dYHSJPY; //用户数据偏移(2)(分包命令)


@property (nonatomic,strong) NSString *dBQRBS;  //包确认标示符(1)(回应命令)(接收正确:0x55,数据出错:0xAA)


@property (nonatomic,strong) NSString *dYHSJ;   //用户数据
@property (nonatomic,strong) NSString *dJYH;    //校验和(2)
@property (nonatomic,strong) NSString *dBW;     //包尾(1)

@property (nonatomic,strong) NSString *allData;

//@property (nonatomic,strong) NSString *dZYF;    //转义符

@property (nonatomic,strong) NSMutableArray *arrCommand;

- (void)setBELData:(NSData *)data;
- (void)processBELData;


- (BOOL)isValidateData:(NSString *)str;
- (NSData *)getResponseDataWith:(BOOL)isValidate MLXX:(NSString *)mlxx MLBM:(NSString *)mlbm;

- (NSData *)getDataWithUserData:(NSString *)userData
                           type:(SPP_Command)type
                           MLXX:(NSString *)mlxx
                            BID:(NSString *)bid
                         YHSJPY:(NSString *)yhsjpy
                        YHSJZCD:(int)yhsjzcd;

+ (NSString *)intToLittle:(NSString *)str length:(int)length;
+ (NSString *)NSDataToByteTohex:(NSData *)data;//data转string(去转义符)
+ (NSData *)stringToByte:(NSString*)string;//string转data (加转义符)
+ (NSString *)toBinary:(int)input;//10转2进制

+ (int)littleEndianModeToInt:(NSString *)str;

+ (NSString *)replaceUnicode:(NSString*)aUnicodeString;//Unicode转汉字

@end
