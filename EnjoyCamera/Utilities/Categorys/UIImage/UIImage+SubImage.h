//
//  UIImage+SubImage.h
//  UIImage+Categories
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SubImage)

/** 截取当前image对象rect区域内的图像 */
- (UIImage *)subImageWithRect:(CGRect)rect;

/** 压缩图片至指定尺寸 */
- (UIImage *)rescaleImageToSize:(CGSize)size;

/** 压缩图片至指定像素 */
- (UIImage *)rescaleImageToPX:(CGFloat )toPX;

/** 在指定的size里面生成一个平铺的图片 */
- (UIImage *)getTiledImageWithSize:(CGSize)size;

/** UIView转化为UIImage */
+ (UIImage *)imageFromView:(UIView *)view;

/** 将两个图片生成一张图片 */
+ (UIImage*)mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;

@end
