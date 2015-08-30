//
//  DeviceOperatorViewController.m
//  SCBle
//
//  Created by 吗啡 on 15/8/30.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import "DeviceOperatorViewController.h"

@interface DeviceOperatorViewController ()

@property (nonatomic, weak) IBOutlet UIButton *leftBtn;
@property (nonatomic, weak) IBOutlet UIButton *rightBtn;
@property (nonatomic, weak) IBOutlet UIView *musicBgView;

@end

@implementation DeviceOperatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // ADD CODE HERE
    self.leftBtn.layer.cornerRadius = 23;
    self.leftBtn.layer.borderColor = [UIColor greenColor].CGColor;
    self.leftBtn.layer.borderWidth = 1.0;
    
    self.rightBtn.layer.cornerRadius = 23;
    self.rightBtn.layer.borderColor = [UIColor greenColor].CGColor;
    self.rightBtn.layer.borderWidth = 1.0;
    
    self.musicBgView.layer.cornerRadius = 3;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
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

@end
