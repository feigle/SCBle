//
//  ColorPickImageView.m
//  SCBle
//
//  Created by My MacPro on 15/10/7.
//  Copyright © 2015年 ___M.T.F___. All rights reserved.
//

#import "ColorPickImageView.h"

@implementation ColorPickImageView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CANSEND_COLOR = true;
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint point = [touch locationInView:self];
    NSLog(@"touch point %@", NSStringFromCGPoint(point));
    // 获取点击点的颜色
    UIColor *color = [self getPixelColorAtLocation:point];
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = .0;
    CGFloat alpha = .0;
    if ([color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        NSLog(@"颜色获取成功！");
        NSString *sRed = [NSString stringWithFormat:@"%02lx", (long)(red * 255)];
        NSString *sGreen = [NSString stringWithFormat:@"%02lx", (long)(green * 255)];
        NSString *sBlue = [NSString stringWithFormat:@"%02lx", (long)(blue * 255)];
        NSString *sAplha = [NSString stringWithFormat:@"%02lx", (long)(alpha * 255)];
        NSString *colorString = [NSString stringWithFormat:@"0400%@%@%@", sRed, sGreen, sBlue];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_IMAGECOLOR_SUCCESS" object:colorString];
    
    }else {
        NSLog(@"颜色获取失败！");
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint point = [touch locationInView:self];
    NSLog(@"touch point %@", NSStringFromCGPoint(point));
    // 获取点击点的颜色
    UIColor *color = [self getPixelColorAtLocation:point];
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = .0;
    CGFloat alpha = .0;
    if ([color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        NSLog(@"颜色获取成功！");
        NSString *sRed = [NSString stringWithFormat:@"%02lx", (long)(red * 255)];
        NSString *sGreen = [NSString stringWithFormat:@"%02lx", (long)(green * 255)];
        NSString *sBlue = [NSString stringWithFormat:@"%02lx", (long)(blue * 255)];
        NSString *sAplha = [NSString stringWithFormat:@"%02lx", (long)(alpha * 255)];
        NSString *colorString = [NSString stringWithFormat:@"0400%@%@%@", sRed, sGreen, sBlue];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_IMAGECOLOR_SUCCESS" object:colorString];
        
    }else {
        NSLog(@"颜色获取失败！");
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CANSEND_COLOR = true;
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint point = [touch locationInView:self];
    NSLog(@"touch point %@", NSStringFromCGPoint(point));
    // 获取点击点的颜色
    UIColor *color = [self getPixelColorAtLocation:point];
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = .0;
    CGFloat alpha = .0;
    if ([color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        NSLog(@"颜色获取成功！");
        NSString *sRed = [NSString stringWithFormat:@"%02lx", (long)(red * 255)];
        NSString *sGreen = [NSString stringWithFormat:@"%02lx", (long)(green * 255)];
        NSString *sBlue = [NSString stringWithFormat:@"%02lx", (long)(blue * 255)];
        NSString *sAplha = [NSString stringWithFormat:@"%02lx", (long)(alpha * 255)];
        NSString *colorString = [NSString stringWithFormat:@"0400%@%@%@", sRed, sGreen, sBlue];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_IMAGECOLOR_SUCCESS" object:colorString];
        
    }else {
        NSLog(@"颜色获取失败！");
    }

}
// 获取point上的颜色
- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
    UIColor* color = nil;
    CGImageRef inImage = self.image.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil;  }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        @try {
            int offset = 4*((w*round(point.y))+round(point.x));
            NSLog(@"offset: %d", offset);
            int alpha =  data[offset];
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
            color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        }
        @catch (NSException * e) {
            NSLog(@"%@",[e reason]);
        }
        @finally {
        }
        
    }
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color spacen");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}


@end
