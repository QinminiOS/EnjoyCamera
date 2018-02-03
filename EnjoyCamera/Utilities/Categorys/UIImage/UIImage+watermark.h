//
//  UIImage+watermark.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (watermark)

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

+ (UIImage *)watermarkImageWithShowImageViewFrame:(CGRect )frame sourceimage:(UIImage *)sourceImage watermarkImage:(UIImage *)watermarkImage time:(BOOL)showTime;

@end
