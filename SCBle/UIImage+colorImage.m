//
//  UIImage+colorImage.m
//  SCBle
//
//  Created by 吗啡 on 15/9/4.
//  Copyright (c) 2015年 ___M.T.F___. All rights reserved.
//

#import "UIImage+colorImage.h"

@implementation UIImage (colorImage)

+(UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
