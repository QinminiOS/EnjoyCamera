//
//  UIImage+mask.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "UIImage+Mask.h"

@implementation UIImage(Masking)


-(UIImage*)maskWithImage:(UIImage*)maskImage{
//    float scale = [[UIScreen mainScreen] scale];
    const size_t originalWidth = (size_t)(self.size.width * self.scale);
    const size_t originalHeight = (size_t)(self.size.height * self.scale);
    CGContextRef bmContext = CGBitmapContextCreate(NULL, self.size.width, self.size.height, 8, 0, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    if (!bmContext){
        CGContextRelease(bmContext);
        return nil;
    }
    
    /// Image quality
    CGContextSetShouldAntialias(bmContext, false);
    CGContextSetAllowsAntialiasing(bmContext, false);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    
    /// Image mask
    CGImageRef cgMaskImage = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate((size_t)maskImage.size.width, (size_t)maskImage.size.height, CGImageGetBitsPerComponent(cgMaskImage), CGImageGetBitsPerPixel(cgMaskImage), CGImageGetBytesPerRow(cgMaskImage), CGImageGetDataProvider(cgMaskImage), NULL, false);
    
    /// Draw the original image in the bitmap context
    const CGRect r = (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight};
    CGContextClipToMask(bmContext, r, cgMaskImage);
    CGContextDrawImage(bmContext, r, self.CGImage);
    
    /// Get the CGImage object
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(bmContext);
    /// Apply the mask
    CGImageRef maskedImageRef = CGImageCreateWithMask(imageRefWithAlpha, mask);
    
    NSLog(@"self.scale:%d",self.scale);
    UIImage* result = [UIImage imageWithCGImage:maskedImageRef scale:3.0 orientation:self.imageOrientation];
    
    /// Cleanup
    CGImageRelease(maskedImageRef);
    CGImageRelease(imageRefWithAlpha);
    CGContextRelease(bmContext);
    CGImageRelease(mask);
    
    return result;

}

@end
