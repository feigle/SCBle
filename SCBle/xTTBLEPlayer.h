//
//  xTTBLEPlayer.h
//  BluetoothPlayer
//
//  Created by xTT on 14/11/20.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, xTTBLEplayState)
{
    xTTBLEplayStatePlay = 0,
    xTTBLEplayStatePaused,
};

typedef NS_ENUM(NSInteger, xTTBLERepeatMode) {
    xTTBLERepeatModeDefault = 0,
    xTTBLERepeatModeNone,
    xTTBLERepeatModeOne,
    xTTBLERepeatModeAll
};

typedef NS_ENUM(NSInteger, xTTBLEEQ) {
    EQ_MODE_NORMAL = 0,
    EQ_MODE_CLASSIC,
    EQ_MODE_JAZZ,
    EQ_MODE_POP,
    EQ_MODE_ROCK,
    EQ_MODE_EXBASS,
    EQ_MODE_SOFT,
    EQ_MODE_USER
};


@interface xTTBLEPlayer : NSObject
@property (nonatomic,assign) xTTBLEplayState playState;
@property (nonatomic,assign) xTTBLERepeatMode repeatMode;
@property (nonatomic,assign) xTTBLEEQ EQMode;
@property (nonatomic,assign) int volume;
@property (nonatomic,strong) NSString *musicName;
@property (nonatomic,strong) NSString *produceName;
@property (nonatomic,strong) NSString *softwareVersion;
@property (nonatomic,strong) NSString *produceID;

@property (nonatomic,assign) int voltage;
@property (nonatomic,assign) int signal;
@property (nonatomic,assign) NSInteger nowItem;

@property (nonatomic,strong) NSMutableArray *arrTmusics;
@property (nonatomic,strong) NSMutableArray *arrUmusics;

@property (nonatomic,strong) NSMutableArray *userEQ;
@property (nonatomic,assign) float gainEQ;

//@property (nonatomic,assign) int
- (void)sendUserEq;
- (void)loadUserEQ;
- (void)saveUserEQ;
@end

@interface xTTMusicItem : NSObject
@property (nonatomic,strong) NSString *musicName;
@property (nonatomic,assign) NSInteger musicID;

@end
