//
//  UIImage+DrawImage.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "UIImage+DrawImage.h"
#import <QuartzCore/QuartzCore.h>
#import "CGAffineTransformFun.h"


@implementation UIImage (DrawImage)

- (UIImage *)imageWithSubImage:(UIImage *)image frame:(CGRect)frame {
    UIImage *tmpImg = image;
    
    UIGraphicsBeginImageContextWithOptions(self.size, YES, 1.0);
    
    [self drawInRect:CGRectMake(0, 0, self.size.width , self.size.height )];
    
    [tmpImg drawInRect:frame];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    return resultImage;
}

- (UIImage *)imageMosaicWithSubImage:(UIImage *)image frame:(CGRect)frame{
    UIImage *tmpImg = image;
    
    UIGraphicsBeginImageContextWithOptions(self.size, YES, [UIScreen mainScreen].scale);
    [self drawInRect:CGRectMake(0, 0, self.size.width , self.size.height)];
    [tmpImg drawInRect:CGRectMake(0, 0, self.size.width , self.size.height )];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"[UIScreen mainScreen].scale = %f, self.scale = %f, image.scale = %f", [UIScreen mainScreen].scale, self.scale, image.scale);
    
    return resultImage;
    
}

- (UIImage *)imageWithTransform:(CGAffineTransform)transform drawMode:(UIImageDrawImageMode)mode {
    
    CGSize size = CGSizeMake(self.size.width * self.scale, self.size.height  * self.scale);
    CGSize outputSize = size;
    CGFloat scaleX = [CGAffineTransformFun scaleXWithCGAffineTransform:transform];
    CGFloat scaleY = [CGAffineTransformFun scaleYWithCGAffineTransform:transform];
    CGFloat radian = [CGAffineTransformFun radianWithCGAffineTransform:transform];
    
    if (mode == UIImageDrawImagExpand) {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        rect = CGRectApplyAffineTransform(rect, transform);
        outputSize = CGSizeMake(rect.size.width, rect.size.height);
        
        NSLog(@"size.width=%f,height=%f", size.width, size.height);
        NSLog(@"rect.size.width=%f, height=%f", rect.size.width, rect.size.height);
    }
    
    UIGraphicsBeginImageContextWithOptions(outputSize, NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, outputSize.width /2, outputSize.height /2);
    CGContextRotateCTM(context, radian);
    CGContextScaleCTM(context, scaleX, scaleY);
    CGContextTranslateCTM(context, -size.width/2, -size.height/2);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
