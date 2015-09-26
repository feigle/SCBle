//
//  xTTPlayer.h
//  BluetoothPlayer
//
//  Created by xTT on 14/10/29.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "xTTBLEPlayer.h"

typedef NS_ENUM(NSInteger, PlayerVCType)
{
    LocalMusicVCType = 0,
    BlueToothVCType,
    TcardVCType,
    UdiskVCType,
    UnDefine
};

@interface xTTPlayer : NSObject

@property (nonatomic ,strong) MPMusicPlayerController *player;
@property (nonatomic ,strong) xTTBLEPlayer *BLEplay;
//@property (nonatomic ,strong) MPMediaItem *nowPlayItem;
@property (nonatomic ,assign) NSUInteger musicCount;   //歌曲数量

@property (assign, nonatomic) PlayerVCType playerVCType;

+ (xTTPlayer *)getPlayerObj;
- (NSString *)getPlayTime;
- (NSString *)getLastTime;

- (void)previousMusic;//上一曲
- (void)nextMusic;//下一曲
- (void)repeatMode;//切换播放顺序模式;

+ (NSMutableString *)secToStr:(NSTimeInterval)sec;

-(UIImage *)grayImage:(UIImage *)sourceImage;
@end
