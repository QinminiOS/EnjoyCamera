// UIImage+Resize.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    NYXCropModeTopLeft,
    NYXCropModeTopCenter,
    NYXCropModeTopRight,
    NYXCropModeBottomLeft,
    NYXCropModeBottomCenter,
    NYXCropModeBottomRight,
    NYXCropModeLeftCenter,
    NYXCropModeRightCenter,
    NYXCropModeCenter
} NYXCropMode;

@interface UIImage (Resize)
- (UIImage *)resizedCameraIconImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedAndClipImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

- (UIImage *)setImageScale:(float)scale;
-(UIImage*)cropToSize:(CGSize)newSize usingMode:(NYXCropMode)cropMode;

+ (CGSize)getSizeWithRate:(float)rate limitSize:(CGSize)size;

+ (CGSize)getSizeWithRate:(float)rate limitLargeSize:(CGSize)size;

@end
