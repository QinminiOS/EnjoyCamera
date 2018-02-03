//
//  UIImage+backgroundImage.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "UIImage+backgroundImage.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Clip.h"

@implementation UIImage (backgroundImage)

+ (UIImage *)getBackgroundImage:(UIImage *)sourceImage withAlpha:(float)alpha width:(CGFloat)width
{
    return [UIImage backgroundImage:sourceImage alpha:alpha width:width];
}

+ (UIImage *)getBackgroundImage:(UIImage *)sourceImage withAlpha:(float)alpha{
    return [UIImage backgroundImage:sourceImage alpha:alpha width:160];
}


+ (UIImage *)getBackgroundImage:(UIImage *)sourceImage
{
    
    return [UIImage backgroundImage:sourceImage alpha:0.5 width:160];
}


+ (UIImage *)backgroundImage:(UIImage *)sourceImage alpha:(float)alpha width:(CGFloat)width {
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGSize clipSize = [self getSizeWithRate:screenWidth/screenHeight limitSize:sourceImage.size];
    CGFloat clipX = (sourceImage.size.width - clipSize.width) / 2.0;
    CGFloat clipY = (sourceImage.size.height - clipSize.height) / 2.0;
    CGFloat clipW = clipSize.width;
    CGFloat clipH = clipSize.height;
    
//    CFTimeInterval i = CFAbsoluteTimeGetCurrent();
    
    UIImage *clipImage = sourceImage;
    
    if(CGSizeEqualToSize(sourceImage.size, clipSize) == NO){
    
        clipImage = [UIImage clipImage:sourceImage withRect:CGRectMake(clipX, clipY, clipW, clipH)];
    }
    
    
    float rate = clipImage.size.width / clipImage.size.height;
    float w = width;
    float h = width / rate;
    CGSize size = CGSizeMake(w, h);
    
    if(CGSizeEqualToSize(clipImage.size, size) == NO){
        
        clipImage = [UIImage clipImage:clipImage withRect:CGRectMake(0, 0, size.width, size.height)];
    }
        
    NSData *data = UIImageJPEGRepresentation(clipImage, 0.1);
    UIImage *dataImage = [[UIImage alloc] initWithData:data];
    
    UIImage *effectImage = [dataImage applyLightEffect];
    UIImage *effectBgImage = effectImage;
    
    if (alpha > 0.01) {
        effectBgImage = [self getEffectBgImage:effectImage withMaskColor:[UIColor colorWithWhite:1 alpha:alpha]];
    }

    
//    CFTimeInterval i1 = CFAbsoluteTimeGetCurrent();
    //NSLog(@"i1-i=%f", i1 - i);
    
    
    return effectBgImage;
}



+ (UIImage *)getEffectBgImage:(UIImage *)effectBgImage withMaskColor:(UIColor *)maskColor
{
    UIGraphicsBeginImageContextWithOptions(effectBgImage.size, NO, 1);
    
    //CGContextRef ref = UIGraphicsGetCurrentContext();
    
    [effectBgImage drawInRect:CGRectMake(0, 0, effectBgImage.size.width, effectBgImage.size.height)];
    
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ref, maskColor.CGColor);
    CGContextAddRect(ref, CGRectMake(0, 0, effectBgImage.size.width, effectBgImage.size.height));
    CGContextFillPath(ref);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    return newImage;
}


- (UIImage *) imageWithTintColor:(UIColor *)tintColor

{
    
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
    
}

- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor

{
    
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
    
}

- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode

{
    
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    [tintColor setFill];
    
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tintedImage;
    
}


+ (CGSize)getSizeWithRate:(float)rate limitSize:(CGSize)size {
    float width = 0.0f;
    float height = 0.0f;
    
    float height1 = 1.0;
    if (size.height != 0.0) {
        height1 = size.height;
    }
    
    if (rate >= size.width / height1) {
        width = size.width;
        height = width / rate;
    }
    else {
        height = size.height;
        width = height * rate;
    }
    
    return CGSizeMake(width, height);
}

@end
