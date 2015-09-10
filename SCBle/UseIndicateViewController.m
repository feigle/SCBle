//
//  UseIndicateViewController.m
//  SCBle
//
//  Created by 吗啡 on 15/8/31.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import "UseIndicateViewController.h"

@interface UseIndicateViewController ()

@end

@implementation UseIndicateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [self customNavigationTitleView];
    
    self.tabBarController.tabBar.hidden = YES;
}

// 自定义导航栏标题视图
- (UIView *)customNavigationTitleView
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"使用说明"];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:56/255.0 green:216/255.0 blue:171/255.0 alpha:1] range:NSMakeRange(0, 4)];
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


@end
