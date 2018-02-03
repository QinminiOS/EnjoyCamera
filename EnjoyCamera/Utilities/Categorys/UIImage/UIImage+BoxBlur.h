//
//  UIImage+BoxBlur.h
///  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BoxBlur)

// blur = 0 ~ 1.0
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur;
@end
