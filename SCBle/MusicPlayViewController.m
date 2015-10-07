//
//  MusicPlayViewController.m
//  SCBle
//
//  Created by 吗啡 on 15/9/22.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import "MusicPlayViewController.h"
#import "UIImage+colorImage.h"

@interface MusicPlayViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    xTTBLE * CMManager;
}
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trailingConstraint;

// 本地音乐列表
@property (nonatomic, weak) IBOutlet UITableView *leftMusicList;
// 卡片音乐列表
@property (nonatomic, weak) IBOutlet UITableView *rightMusicList;
@property (nonatomic, weak) IBOutlet UIScrollView *bgScrollView;

@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, strong) NSMutableArray *localMusicArray;
@end

@implementation MusicPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.localMusicArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.navigationItem.titleView = [self customNavigationTitleView];
    self.tabBarController.tabBar.hidden = YES;
    //1.得到系统模式： <1106003a 00000040 0012>
    //2.得到播放状态： <11060030 00000036 0012>
    //3.切换系统模式： <11070028 00010000 300012>

    CMManager = [xTTBLE getBLEObj];
//    [CMManager sendBLEuserData:@"" type:BTR_GET_STDB_MODE];//得到系统工作模式
//    NSString *str = @"1106003a000000400012";
//    NSData *data = [xTTBLEdata stringToByte:str];
//    
//    NSString *str1 = @"11060030000000360012";
//    NSData *data1 = [xTTBLEdata stringToByte:str1];

//    NSString *str2 = @"1107002800010000300012";
//    NSData *data2 = [xTTBLEdata stringToByte:str2];
//    [CMManager sendBLEData:data];
//    [CMManager sendBLEData:data1];
//    [CMManager sendBLEData:data2];

//    NSString *str3 = @"11060001000000070012";//得到歌曲
//    NSData *data3= [xTTBLEdata stringToByte:str3];
//    [CMManager sendBLEData:data3];
//
//    NSString *str4 = @"1105002d0255890012";//设置当前播放音量
//    NSData *data4= [xTTBLEdata stringToByte:str4];
//    [CMManager sendBLEData:data4];

    


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar
     setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1]]
     forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:[UIColor whiteColor]];
}


// 自定义导航栏标题视图
- (UIView *)customNavigationTitleView
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"播放列表"];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:56/255.0 green:216/255.0 blue:171/255.0 alpha:1] range:NSMakeRange(0, 4)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.attributedText = attributedString;
    [titleLabel sizeToFit];
    return titleLabel;
}

// index=0，表示显示ituns音乐，==1显示内存音乐
- (void)setIndex:(NSInteger)index
{
    [self.view setNeedsLayout];
    if (0 == index) {
        self.leadingConstraint.priority = UILayoutPriorityDefaultHigh;
        self.trailingConstraint.priority = UILayoutPriorityDefaultLow;
        [self.bgScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        //播放本地音乐
        if (CMManager.isConnect){
            
            MPMediaPickerController * mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
            if(mediaPicker != nil)
            {
                NSLog(@"Successfully instantiated a media picker");
                mediaPicker.delegate = self;
                mediaPicker.allowsPickingMultipleItems = YES;
                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:mediaPicker animated:YES completion:nil];
                self.isPlay = true;
            }
            else
            {
                NSLog(@"Could not instantiate a media picker");
            }
            

        }
        else
        {
//            [CMManager getA2DPstate];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请先配置蓝牙连接" message:@"" delegate:nil cancelButtonTitle:@"" otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        
    }else {
        self.leadingConstraint.priority = UILayoutPriorityDefaultLow;
        self.trailingConstraint.priority = UILayoutPriorityDefaultHigh;
        [self.bgScrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
    }
    // 增加动画效果
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

// 选择本地或内存音乐列表
- (IBAction)showMusicList:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag - 1000;
    [self setIndex:tag];
}

#pragma mark -- 上一首
- (IBAction)preMusic:(id)sender
{
    NSLog(@"pre music");
}

#pragma mark -- 播放
- (IBAction)playMusic:(id)sender
{
    NSLog(@"play music");
    if (self.isPlay) {
        [self.myMusicPlayer pause];
        self.isPlay = false;

    }else
    {

        [self.myMusicPlayer play];
        self.isPlay = true;
    }
    
}

#pragma mark -- 下一首
- (IBAction)nextMusic:(id)sender
{
     NSLog(@"next music");
}


#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    if (offset.x == 0) {
        [self setIndex:0];
    }else {
        [self setIndex:1];
    }
}

#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.leftMusicList) {
        return  [self.localMusicArray count];
    }else
        return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"musicCell"];
    if ([self.localMusicArray count]>0 && tableView == self.leftMusicList) {
        cell.textLabel.text = [self.localMusicArray objectAtIndex:indexPath.row];

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//------------
- (IBAction)reback:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    
    
    for (MPMediaItem *item in [mediaItemCollection items]) {
        NSLog(@"item == %@, item==%@", item.title,item);//获取本地歌曲名字
        [self.localMusicArray addObject:item.title];
        
        
    }
    //此处需要更新tableview
    [self.leftMusicList reloadData];
    NSLog(@"Media Picker returned");
    self.myMusicPlayer = nil;
    self.myMusicPlayer = [[MPMusicPlayerController alloc] init];
    [self.myMusicPlayer beginGeneratingPlaybackNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayerStatedChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.myMusicPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowPlayingItemIsChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.myMusicPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeIsChanged:) name:MPMusicPlayerControllerVolumeDidChangeNotification object:self.myMusicPlayer];
    
    [self.myMusicPlayer setQueueWithItemCollection:mediaItemCollection];
    
    [self.myMusicPlayer play];
    
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    NSLog(@"Media Picker was cancelled");
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)musicPlayerStatedChanged:(NSNotification *)paramNotification
{
    NSLog(@"Player State Changed");
    NSNumber * stateAsObject = [paramNotification.userInfo objectForKey:@"MPMusicPlayerControllerPlaybackStateKey"];
    NSInteger state = [stateAsObject integerValue];
    switch (state) {
        case MPMusicPlaybackStateStopped:
            
            break;
        case MPMusicPlaybackStatePlaying:
            break;
            
        case MPMusicPlaybackStatePaused:
            break;
        case MPMusicPlaybackStateInterrupted:
            break;
        case MPMusicPlaybackStateSeekingForward:
            break;
        case MPMusicPlaybackStateSeekingBackward:
            break;
            
        default:
            break;
    }
}

-(void)nowPlayingItemIsChanged:(NSNotification *)paramNotification
{
    NSLog(@"Playing Item is Changed");
    NSString * persistentID = [paramNotification.userInfo objectForKey:@"MPMusicPlayerControllerNowPlayingItemPersistentIDKey"];
    NSLog(@"Persistent ID = %@",persistentID);
    
}

-(void)volumeIsChanged:(NSNotification *)paramNotification
{
    NSLog(@"Volume Is Changed");
}

- (IBAction)stopPlay:(id)sender {
    
    if(self.myMusicPlayer != nil)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.myMusicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.myMusicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:self.myMusicPlayer];
        
        [self.myMusicPlayer stop];
    }
    
}


@end
