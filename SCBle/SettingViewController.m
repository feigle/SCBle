//
//  SettingViewController.m
//  SCBle
//
//  Created by 吗啡 on 15/8/31.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = [self customNavigationTitleView];
    
    // 更换返回按钮背景按钮图片
    UIImage *backButtonImage = [[UIImage imageNamed:@"icon_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] init];
    backBarItem.title = @"";
    [backBarItem setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [backBarItem setBackButtonTitlePositionAdjustment:UIOffsetMake(0, 0) forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = backBarItem;
}

// 自定义导航栏标题视图
- (UIView *)customNavigationTitleView
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"设置"];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:56/255.0 green:216/255.0 blue:171/255.0 alpha:1] range:NSMakeRange(0, 2)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.attributedText = attributedString;
    [titleLabel sizeToFit];
    return titleLabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

@end
