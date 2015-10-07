//
//  HomepageViewController.m
//  SCBle
//
//  Created by 吗啡 on 15/8/30.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import "HomepageViewController.h"
#import "DeviceOperatorViewController.h"
#import "DeviceStatusCell.h"
#import "UIImage+colorImage.h"
#import "STBleController.h"
#import "STPeripheral.h"


@interface HomepageViewController ()<SWTableViewCellDelegate, STBleCommProtocol>

// 设备列表
@property (nonatomic, weak) IBOutlet UITableView *devicesView;
// 搜索到得所有设备
@property (nonatomic, strong) NSArray *devices;

@end

@implementation HomepageViewController
{
    // 蓝牙连接管理器
    STBleController *bleController;
    xTTBLE * BTTController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // ADD CODE HERE
    // 更换返回按钮背景按钮图片
    UIImage *backButtonImage = [[UIImage imageNamed:@"icon_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] init];
    backBarItem.title = @"";
    [backBarItem setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [backBarItem setBackButtonTitlePositionAdjustment:UIOffsetMake(0, 0) forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    self.navigationItem.titleView = [self customNavigationTitleView];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(scanDevices:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
//    // 初始化蓝牙管理控制器
//    bleController = [STBleController getInstance];
//    bleController.dataDelegate = self;
//    [bleController open];
    
    BTTController = [xTTBLE getBLEObj];
    BTTController.DataDelegate = self;


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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"智能音乐灯"];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:76/255.0 green:223/255.0 blue:190/255.0 alpha:1] range:NSMakeRange(0, 2)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1] range:NSMakeRange(2, 3)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.attributedText = attributedString;
    [titleLabel sizeToFit];
    return titleLabel;
}

#pragma mark -- 搜索设备
- (void)scanDevices:(id)sender
{
    [BTTController scanClick];
}


#pragma mark -- 切换设备状态
- (IBAction)switchDeviceItem:(UIButton *)sender
{
    NSInteger tag = sender.tag - 1000;
    CBPeripheral *peripheral = [self.devices objectAtIndex:tag];
    if (peripheral.state == CBPeripheralStateDisconnected) {
        [BTTController connectClick:peripheral];
    }else {
        [BTTController.manager cancelPeripheralConnection:peripheral];
    }
    [self.devicesView reloadData];
}

#pragma mark -- STBleCommProtocol
- (void)discoverDevice:(NSMutableArray *)mArray
{
    self.devices = mArray;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.devicesView reloadData];
    });
}

- (void)dataArrive:(unsigned char *)buf
{
    
}

//连接成功，可以发送数据
- (void)connectOK
{
    [self.devicesView reloadData];
    
}

//连接丢失
- (void)hasDisconecnt
{
    
}

//连接失败
- (void)connectFail
{
    
}

#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return .0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceStatusCell"];
    CBPeripheral *device = [self.devices objectAtIndex:indexPath.row];
    [cell fillCellWithDeviceInfo:device withTag:indexPath.row];
    
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:58.0f];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral = [self.devices objectAtIndex:indexPath.row];
    if (peripheral.state == CBPeripheralStateDisconnected) {
//        [self showAlert:@"设备未配对，先配对在继续操作"];
        [BTTController connectClick:peripheral];
    }else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DeviceOperatorViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DeviceOperatorIdentify"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                 icon:[UIImage imageNamed:@"cehua_bianji"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                 icon:[UIImage imageNamed:@"cehua_shijian"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                icon:[UIImage imageNamed:@"cehua_shanchu"]];
    
    return rightUtilityButtons;
}

#pragma mark -- 显示提示框
- (void)showAlert:(NSString *)alertMsg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:alertMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSLog(@"0");
            break;
        }
        case 1:
        {
            NSLog(@"1");
            break;
        }
        case 2:
            NSLog(@"2");
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}



@end
