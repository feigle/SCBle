//
//  DeviceOperatorViewController.m
//  SCBle
//
//  Created by 吗啡 on 15/8/30.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import "DeviceOperatorViewController.h"
#import "UIImage+colorImage.h"
#import "MSwitchView.h"

@interface DeviceOperatorViewController ()<switchViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *leftBtn;
@property (nonatomic, weak) IBOutlet UIView *rightBtn;
@property (nonatomic, weak) IBOutlet UIView *musicBgView;
// 开关按钮
@property (nonatomic, weak) IBOutlet UIButton *ligthSwitch;
// 取色背景图
@property (nonatomic, weak) IBOutlet UIImageView *colorPanImageView;

@end

@implementation DeviceOperatorViewController
{
    // 现在显示的彩灯or白光 yes表示彩灯，no表示白光
    BOOL isColor;
    xTTBLE * CMManager;
}

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
    
    // 初始化蓝颜控制类
    CMManager = [xTTBLE getBLEObj];
    
    // 获取颜色
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeColor:) name:@"GET_IMAGECOLOR_SUCCESS" object:nil];
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
    [self.navigationController.navigationBar
     setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]]
     forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
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
    leftSwitchView.delegate = self;
    leftSwitchView.isOn = NO;
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
    rightSwitchView.delegate = self;
    rightSwitchView.isOn = NO;
    [rightSwitchView setupWithRightTitle:@"       " leftTitle:@"律动同步"];
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

    leftSwitchView.tag = 999 + 0;
    rightSwitchView.tag = 999 + 1;
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

- (void)changeColor:(NSNotification *)notification
{
//    CANSEND_COLOR = true;
    if(CANSEND_COLOR)
    {
        NSString *object = (NSString *)notification.object;
        [CMManager sendBLEuserData:object type:BTR_USERDEFINE];
        CANSEND_COLOR = true;
    }
}

#pragma mark -- 开关按钮
- (IBAction)switchMode:(id)sender
{
    isColor = !isColor;
    if (isColor) {
//        [self.colorPanImageView setImage:[UIImage imageNamed:@"caiguang"]];
        [self.ligthSwitch setTitle:@"OFF" forState:UIControlStateNormal];
        // 关灯
        [CMManager sendBLEuserData:@"0000" type:BTR_USERDEFINE];
    }else {
//        [self.colorPanImageView setImage:[UIImage imageNamed:@"baiguang"]];
        [self.ligthSwitch setTitle:@"ON" forState:UIControlStateNormal];
        // 开灯
        [CMManager sendBLEuserData:@"0001" type:BTR_USERDEFINE];
    }
}

#pragma mark -- 改变显示状态
- (void)switchViewStatuChange:(MSwitchView *)switchView
{
    NSInteger tag = switchView.tag - 999;
    if (tag == 0) {
        // 白光or彩灯
        NSLog(@"白光or彩灯");
        if (switchView.isOn) {
            // 设置彩灯模式
            [CMManager sendBLEuserData:@"0400040464" type:BTR_USERDEFINE];
            [self.colorPanImageView setImage:[UIImage imageNamed:@"caiguang"]];
        }else {
            // 设置白光模式
            [CMManager sendBLEuserData:@"04285F5016" type:BTR_USERDEFINE];
            [self.colorPanImageView setImage:[UIImage imageNamed:@"baiguang"]];
        }
    }else if (tag == 1) {
        // 律动
        NSLog(@"律动");
        if (switchView.isOn) {
            // 开启律动模式
            [CMManager sendBLEuserData:@"060000" type:BTR_USERDEFINE];
        }else {
            // 关闭律动模式
            [CMManager sendBLEuserData:@"060001" type:BTR_USERDEFINE];
        }
    }
}


@end
