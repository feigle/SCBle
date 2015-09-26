//
//  xTTPlayer.m
//  BluetoothPlayer
//
//  Created by xTT on 14/10/29.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//

#import "xTTPlayer.h"
#import "xTTBLE.h"
@implementation xTTPlayer

- (id)init {
    self = [super init];  // Call a designated initializer here.
    if (self) {
        if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0) {
            _player = [MPMusicPlayerController systemMusicPlayer];
        }else{
            _player = [MPMusicPlayerController iPodMusicPlayer];
        }
        _player.repeatMode = MPMusicRepeatModeAll;
        [_player setQueueWithQuery:[MPMediaQuery songsQuery]];
        _BLEplay = [[xTTBLEPlayer alloc] init];
    }
    return self;
}

+ (xTTPlayer *)getPlayerObj{
    static xTTPlayer *xTTplayer;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        xTTplayer = [[xTTPlayer alloc] init];
    });
    return xTTplayer;
}

//上一曲
- (void)previousMusic{
    if (_playerVCType == LocalMusicVCType || _playerVCType == BlueToothVCType) {
        if ([[xTTPlayer getPlayerObj].player indexOfNowPlayingItem] == 0)
        {
            [[xTTPlayer getPlayerObj].player skipToBeginning];
        }else
        {
            [[xTTPlayer getPlayerObj].player skipToPreviousItem];
        }
    }else{
        [[xTTBLE getBLEObj] sendBLEuserData:[xTTBLEdata intToLittle:@"00" length:2]
                                       type:BTR_SET_LAST_NEXT];
    }
}

//下一曲
- (void)nextMusic{
    if (_playerVCType == LocalMusicVCType || _playerVCType == BlueToothVCType) {
        NSUInteger nowPlayingIndex = [[xTTPlayer getPlayerObj].player indexOfNowPlayingItem];
        if(nowPlayingIndex != [xTTPlayer getPlayerObj].musicCount - 1)
        {
            [[xTTPlayer getPlayerObj].player skipToNextItem];
        }
    }else{
        [[xTTBLE getBLEObj] sendBLEuserData:[xTTBLEdata intToLittle:@"01" length:2]
                                       type:BTR_SET_LAST_NEXT];
    }
}

- (void)repeatMode{
    switch ([xTTPlayer getPlayerObj].playerVCType) {
        case LocalMusicVCType:
        case BlueToothVCType:
            switch ([xTTPlayer getPlayerObj].player.repeatMode) {
                case MPMusicRepeatModeAll:
                    [xTTPlayer getPlayerObj].player.shuffleMode = MPMusicShuffleModeSongs;
                    [xTTPlayer getPlayerObj].player.repeatMode = MPMusicRepeatModeNone;
                    break;
                case MPMusicRepeatModeOne:
                    [xTTPlayer getPlayerObj].player.shuffleMode = MPMusicShuffleModeOff;
                    [xTTPlayer getPlayerObj].player.repeatMode = MPMusicRepeatModeAll;
                    break;
                case MPMusicRepeatModeNone:
                    [xTTPlayer getPlayerObj].player.shuffleMode = MPMusicShuffleModeOff;
                    [xTTPlayer getPlayerObj].player.repeatMode = MPMusicRepeatModeOne;
                    break;
                default:
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_PLAY_MODE" object:nil];
            break;
        case TcardVCType:
        case UdiskVCType:
            switch ([xTTPlayer getPlayerObj].BLEplay.repeatMode) {
                case xTTBLERepeatModeDefault://00
                    [[xTTBLE getBLEObj] sendBLEuserData:[xTTBLEdata intToLittle:@"02" length:2]
                                                   type:BTR_SET_PLAY_MODE];
                    break;
                case xTTBLERepeatModeAll://02
                    [[xTTBLE getBLEObj] sendBLEuserData:[xTTBLEdata intToLittle:@"03" length:2]
                                                   type:BTR_SET_PLAY_MODE];
                    break;
                case xTTBLERepeatModeOne://01
                    [[xTTBLE getBLEObj] sendBLEuserData:[xTTBLEdata intToLittle:@"00" length:2]
                                                   type:BTR_SET_PLAY_MODE];
                    break;
                case xTTBLERepeatModeNone://03
                    [[xTTBLE getBLEObj] sendBLEuserData:[xTTBLEdata intToLittle:@"01" length:2]
                                                   type:BTR_SET_PLAY_MODE];
                    break;
                default:
                    break;
            }

            
        default:
            break;
    }
}

- (NSString *)getPlayTime{
    return [xTTPlayer secToStr:[xTTPlayer getPlayerObj].player.currentPlaybackTime];
}

- (NSString *)getLastTime{
    return [xTTPlayer secToStr:[xTTPlayer getPlayerObj].player.nowPlayingItem.playbackDuration
            - [xTTPlayer getPlayerObj].player.currentPlaybackTime];
}

- (NSString *)getTotalTime{
    return [xTTPlayer secToStr:[xTTPlayer getPlayerObj].player.nowPlayingItem.playbackDuration];
}

+ (NSMutableString *)secToStr:(NSTimeInterval)sec{
    NSMutableString *timeStr = [NSMutableString string];
//    int day = sec / (60 * 60 * 24);
//    sec -= day * 60 * 60 * 24;
//    int ousr = sec / (60 * 60);
//    sec -= ousr * 60 * 60;
    int minutes = sec / 60;
    sec -= minutes * 60;
    
//    if (day > 0) {
//        [timeStr appendString:[NSString stringWithFormat:@"%d天",day]];
//    }
//    if (ousr > 0) {
//        [timeStr appendString:[NSString stringWithFormat:@"%d小时",ousr]];
//    }
//    if (day > 0) {
//        [timeStr appendString:[NSString stringWithFormat:@"%d分",minutes]];
//        return  timeStr;
//    }
    if (sec < 10) {
        [timeStr appendString:[NSString stringWithFormat:@"%d:0%d",minutes,(int)sec]];
    }else{
        [timeStr appendString:[NSString stringWithFormat:@"%d:%.0f",minutes,sec]];
    }
    return  timeStr;
}

-(UIImage *)grayImage:(UIImage *)sourceImage
{
    int bitmapInfo = kCGImageAlphaNone;
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}
@end
