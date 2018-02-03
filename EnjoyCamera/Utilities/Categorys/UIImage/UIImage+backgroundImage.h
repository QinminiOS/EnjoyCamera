//
//  UIImage+backgroundImage.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (backgroundImage)

+ (UIImage *)getBackgroundImage:(UIImage *)sourceImage withAlpha:(float)alpha width:(CGFloat)width;
+ (UIImage *)getBackgroundImage:(UIImage *)sourceImage withAlpha:(float)alpha;
+ (UIImage *)getBackgroundImage:(UIImage *)sourceImage;
+ (UIImage *)getEffectBgImage:(UIImage *)effectBgImage withMaskColor:(UIColor *)maskColor;

- (UIImage *) imageWithTintColor:(UIColor *)tintColor;

- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;
@end
