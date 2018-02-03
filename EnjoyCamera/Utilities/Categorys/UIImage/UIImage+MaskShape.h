//
//  UIImage+MaskShape.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGContextRef CreateRGBABitmapContext (CGImageRef inImage);
static unsigned char *RequestImagePixelData(UIImage *inImage);

@interface UIImage (MaskShape)

+ (UIImage*)imageChangeBlackToTransparent:(UIImage*)inImage;
- (UIImage *)imageWithMaskImage:(UIImage *)maskImage;
- (UIImage *)imageWithMaskImage:(UIImage *)maskImage maskColor:(UIColor *)maskColor;//ios7以下
- (UIImage *)imageWithLayerMaskImage:(UIImage *)maskImage maskColor:(UIColor *)maskColor;//ios7

- (UIImage *)imageWithColor:(UIColor *)color;
@end
