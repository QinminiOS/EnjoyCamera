//
//  UIImage+DrawImage.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    UIImageDrawImageClipped,//the image size will be equal to orignal image, some part of image may be clipped
    UIImageDrawImagExpand,  //the image size will expand to contain the whole image, remain area will be transparent
} UIImageDrawImageMode;



@interface UIImage (DrawImage)

- (UIImage *)imageWithSubImage:(UIImage *)image frame:(CGRect)frame;

- (UIImage *)imageMosaicWithSubImage:(UIImage *)image frame:(CGRect)frame;

- (UIImage *)imageWithTransform:(CGAffineTransform)transform drawMode:(UIImageDrawImageMode)mode;

@end
