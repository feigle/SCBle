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

@property (nonatomic, weak) IBOutlet UITableView *leftMusicList;
@property (nonatomic, weak) IBOutlet UITableView *rightMusicList;

@end

@implementation MusicPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [self customNavigationTitleView];
    
    self.tabBarController.tabBar.hidden = YES;
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
    }else {
            self.leadingConstraint.priority = UILayoutPriorityDefaultLow;
            self.trailingConstraint.priority = UILayoutPriorityDefaultHigh;
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
