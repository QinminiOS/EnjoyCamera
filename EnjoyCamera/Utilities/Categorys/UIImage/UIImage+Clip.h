//
//  UIImage+Clip.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Clip)

+ (UIImage *)clipImage:(UIImage *)aImage CGBlendMode:(int)type;
+ (UIImage *)clipImage:(UIImage *)image withRect:(CGRect)rect;
+ (UIImage *)clipImage:(UIImage *)image withRatio:(CGFloat)ratio;

+ (UIImage *)cropImage:(UIImage *)image
                 frame:(CGRect)frame
                 angle:(NSInteger)angle
          circularClip:(BOOL)circular;

+ (UIImage *)getImageWithView:(UIView *)view rect:(CGRect)rect scale:(CGFloat)scale;

+ (UIImage *)getImage:(UIImage *)image mask:(UIImage *)mask;
+ (UIImage *)getCircleImage:(UIImage *)image withParam:(CGFloat)inset;

@end
