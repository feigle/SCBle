//
//  MSwitchView.h
//  SCBle
//
//  Created by 吗啡 on 15/8/30.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

// 开关在左表示开，右表示关
#import <UIKit/UIKit.h>

@class MSwitchView;
@protocol switchViewDelegate <NSObject>

@optional
- (void)switchViewStatuChange:(MSwitchView *)switchView;

@end

@interface MSwitchView : UIView

@property (nonatomic, weak) IBOutlet UIView *roundView;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) id<switchViewDelegate> delegate;
// 左边标题
@property (nonatomic, strong) NSString *rightTitle;
// 右边标题
@property (nonatomic, strong) NSString *leftTitle;
// 开关状态标记
@property (nonatomic, assign) BOOL isOn;

- (void)setupWithRightTitle:(NSString *)rTitle leftTitle:(NSString *)lTitle;

@end

