
//
//  MSwitchView.m
//  SCBle
//
//  Created by 吗啡 on 15/8/30.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import "MSwitchView.h"

@interface MSwitchView ()

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *roundViewLeft;
@property (nonatomic, strong) NSLayoutConstraint *roundViewRight;
@property (nonatomic, strong) NSLayoutConstraint *textLeft;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *textRight;


@end

@implementation MSwitchView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _isOn = YES;
    self.roundViewRight = [NSLayoutConstraint
                           constraintWithItem:self.roundView
                           attribute:NSLayoutAttributeTrailing
                           relatedBy:NSLayoutRelationEqual
                           toItem:self
                           attribute:NSLayoutAttributeTrailing
                           multiplier:1
                           constant:-8.0];
    
    self.textLeft = [NSLayoutConstraint
                           constraintWithItem:self.textLabel
                           attribute:NSLayoutAttributeLeading
                           relatedBy:NSLayoutRelationEqual
                           toItem:self
                           attribute:NSLayoutAttributeLeading
                           multiplier:1
                           constant:8.0];
    
}

- (void)initView
{
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor greenColor].CGColor;
    
    self.roundView.backgroundColor = [UIColor colorWithRed:79/255.0 green:221/255.0 blue:181/255.0 alpha:1];
    self.roundView.layer.cornerRadius = (self.frame.size.height - 16) / 2.0;
}

- (void)layoutSubviews
{
    [self initView];
}

- (void)setupWithRightTitle:(NSString *)rTitle leftTitle:(NSString *)lTitle
{
    self.rightTitle = rTitle;
    self.leftTitle = lTitle;
    self.textLabel.text = self.rightTitle;
}

- (IBAction)switchClick:(id)sender
{
    if (self.isOn) {
        self.isOn = NO;
    }else {
        self.isOn = YES;
    }
    if ([self.delegate respondsToSelector:@selector(switchViewStatuChange:)]) {
        [self.delegate switchViewStatuChange:self];
    }
}

- (void)setIsOn:(BOOL)isOn
{
    if (self.isOn == isOn) {
        return;
    }
    if (self.isOn) {
        [UIView animateWithDuration:0.25 animations:^{
            [self removeConstraints:@[self.roundViewLeft]];
            [self removeConstraints:@[self.textRight]];
            [self addConstraint:self.roundViewRight];
            [self addConstraint:self.textLeft];
            self.textLabel.text = self.leftTitle;
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            [self removeConstraints:@[self.roundViewRight]];
            [self removeConstraints:@[self.textLeft]];
            [self addConstraint:self.roundViewLeft];
            [self addConstraint:self.textRight];
            self.textLabel.text = self.rightTitle;
        }];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    _isOn = isOn;
}

@end
