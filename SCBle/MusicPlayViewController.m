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

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trailingConstraint;

// 本地音乐列表
@property (nonatomic, weak) IBOutlet UITableView *leftMusicList;
// 卡片音乐列表
@property (nonatomic, weak) IBOutlet UITableView *rightMusicList;
@property (nonatomic, weak) IBOutlet UIScrollView *bgScrollView;

@end

@implementation MusicPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [self customNavigationTitleView];
    
    self.tabBarController.tabBar.hidden = YES;
    
    
    //1.得到系统模式： <1106003a 00000040 0012>
    //2.得到播放状态： <11060030 00000036 0012>
    //3.切换系统模式： <11070028 00010000 300012>

    xTTBLE * CMManager = [xTTBLE getBLEObj];
    [CMManager sendBLEuserData:@"" type:BTR_GET_STDB_MODE];//得到系统工作模式
    NSString *str = @"1106003a000000400012";
    NSData *data = [xTTBLEdata stringToByte:str];
    
    NSString *str1 = @"11060030000000360012";
    NSData *data1 = [xTTBLEdata stringToByte:str1];

    NSString *str2 = @"1107002800010000300012";
    NSData *data2 = [xTTBLEdata stringToByte:str2];
    [CMManager sendBLEData:data];
    [CMManager sendBLEData:data1];
    [CMManager sendBLEData:data2];

    NSString *str3 = @"11060001000000070012";//得到歌曲
    NSData *data3= [xTTBLEdata stringToByte:str3];
    [CMManager sendBLEData:data3];
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
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"musicCell"];
    cell.textLabel.text = @"王妃";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
