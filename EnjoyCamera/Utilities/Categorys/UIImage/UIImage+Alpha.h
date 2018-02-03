//
//  UIImage+Alpha.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (Alpha)

//是否有alpha通道
- (BOOL)hasAlpha;

//图片的像素值
- (NSData *)ARGBData;

//图片的一个像素point是否透明
- (BOOL)isPointTransparent:(CGPoint)point;

//返回带aplha通道图
- (UIImage *)imageWithAlpha;

- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;

// 边框
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size;

@end
