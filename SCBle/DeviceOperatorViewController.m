//
//  DeviceOperatorViewController.m
//  SCBle
//
//  Created by 吗啡 on 15/8/30.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import "DeviceOperatorViewController.h"
#import "MSwitchView.h"
#import "UIImage+colorImage.h"

@interface DeviceOperatorViewController ()

@property (nonatomic, weak) IBOutlet UIView *leftBtn;
@property (nonatomic, weak) IBOutlet UIView *rightBtn;
@property (nonatomic, weak) IBOutlet UIView *musicBgView;
// 开关按钮
@property (nonatomic, weak) IBOutlet UIButton *ligthSwitch;

@end

@implementation DeviceOperatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // ADD CODE HERE
    [self initSwitchBtn];
    self.musicBgView.layer.cornerRadius = 3;
    self.ligthSwitch.layer.cornerRadius = self.ligthSwitch.frame.size.height / 2.0;
    self.ligthSwitch.clipsToBounds = YES;
    
    self.navigationItem.titleView = [self customNavigationTitleView];
    
    self.tabBarController.tabBar.hidden = YES;
    
    [self.navigationController.navigationBar
     setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]]
     forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
}

// 自定义导航栏标题视图
- (UIView *)customNavigationTitleView
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"灯光控制"];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] range:NSMakeRange(0, 4)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.attributedText = attributedString;
    [titleLabel sizeToFit];
    return titleLabel;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)initSwitchBtn
{
    MSwitchView *leftSwitchView = [[[NSBundle mainBundle] loadNibNamed:@"MSwitchView" owner:self options:nil] firstObject];
    leftSwitchView.frame = self.leftBtn.bounds;
    [leftSwitchView setupWithRightTitle:@"白光" leftTitle:@"彩灯"];
    [self.leftBtn addSubview:leftSwitchView];
    self.leftBtn.clipsToBounds = YES;
    NSArray *constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftSwitchView]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(self.leftBtn, leftSwitchView)];
    
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[leftSwitchView]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(self.leftBtn, leftSwitchView)];
    [self.leftBtn addConstraints:constraint_V];
    [self.leftBtn addConstraints:constraint_H];
    
    MSwitchView *rightSwitchView = [[[NSBundle mainBundle] loadNibNamed:@"MSwitchView" owner:self options:nil] firstObject];
    rightSwitchView.frame = self.rightBtn.bounds;
    [rightSwitchView setupWithRightTitle:@"律动同步" leftTitle:@"律动同步"];
    [self.rightBtn addSubview:rightSwitchView];
    self.rightBtn.clipsToBounds = YES;
    NSArray *constraint_rV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightSwitchView]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(self.rightBtn, rightSwitchView)];
    
    NSArray *constraint_rH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[rightSwitchView]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(self.rightBtn, rightSwitchView)];
    [self.rightBtn addConstraints:constraint_rV];
    [self.rightBtn addConstraints:constraint_rH];

}

- (UIView *)customNavigationTitleView:(NSString *)titleStr
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = titleStr;
    [titleLabel sizeToFit];
    return titleLabel;
}

#pragma mark -- 退出当前视图
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
