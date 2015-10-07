//
//  MusicPlayViewController.h
//  SCBle
//
//  Created by 吗啡 on 15/9/22.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MusicPlayViewController : UIViewController<UIScrollViewDelegate,MPMediaPickerControllerDelegate>

@property (nonatomic,strong) MPMusicPlayerController * myMusicPlayer;

@end
