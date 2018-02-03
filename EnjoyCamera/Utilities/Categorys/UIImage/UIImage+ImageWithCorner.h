//
//  UIImage+ImageWithCorner.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageWithCorner)



/**
 图片高效圆角绘制类

 @param radius 圆角弧度
 @param size 绘制区域大小---(传入图片size即可)
 @return 新生成图片
 */
- (UIImage*)imageWithConrnerWithRadius:(CGFloat)radius sizeToFit:(CGSize)size;

@end
