//
//  UIImage+Clip.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "UIImage+Clip.h"

@implementation UIImage (Clip)

static CGContextRef CreateRGBABitmapContextWithCGImage(CGImageRef aCGImage)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    unsigned char *bitmapData = NULL;
    
    size_t widthPixels = CGImageGetWidth(aCGImage);
    size_t higthPixels = CGImageGetHeight(aCGImage);
    size_t allPixels = widthPixels * higthPixels;
    size_t allBytes = allPixels * 4;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL) {
        return NULL;
    }
    
    bitmapData = malloc(allBytes);
    memset(bitmapData, 0, allBytes);
    
    if (bitmapData == NULL) {
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    
    context = CGBitmapContextCreate(bitmapData,
                                    widthPixels,
                                    higthPixels,
                                    8,
                                    widthPixels * 4,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);
    if (context == NULL) {
        fprintf (stderr, "Context not created!");
    }
    
    free (bitmapData);
    bitmapData = NULL;
    
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

+ (UIImage *)clipImage:(UIImage *)aImage CGBlendMode:(int)type
{
    //    CGImageRef cgImage = CGImageCreateWithImageInRect(aImage.CGImage, CGRectMake(0, 0, aImage.size.width, aImage.size.height));
    //    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
    //
    //    CGImageRelease(cgImage);
    
    CGContextRef context = CreateRGBABitmapContextWithCGImage(aImage.CGImage);
    
    if (context == NULL) {
        return nil;
    }
    
    size_t w = CGImageGetWidth(aImage.CGImage);
    size_t h = CGImageGetHeight(aImage.CGImage);
    CGRect rect = {{0, 0}, {w, h}};
    
    CGContextSetBlendMode(context, type);
    CGContextDrawImage(context, rect, aImage.CGImage);
    
    
    CGImageRef aCGImage = CGBitmapContextCreateImage(context);
    
    UIImage *newImage = [UIImage imageWithCGImage:aCGImage];
    
    CGImageRelease(aCGImage);
    CGContextRelease(context);
    
    return newImage;
}

+ (UIImage *)clipImage:(UIImage *)image withRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *tmpImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return tmpImage;
}

+ (UIImage *)clipImage:(UIImage *)image withRatio:(CGFloat)ratio
{
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    CGFloat ratioHeight = width * ratio;
    CGRect rect;
    if (ratioHeight <= height) {
        rect = CGRectMake(0, height/2 - ratioHeight/2, width, ratioHeight);
    }else {
        CGFloat ratioWidth = height/ratio;
        rect = CGRectMake(width/2-ratioWidth/2, 0, ratioWidth, height);
    }
    return [UIImage clipImage:image withRect:rect];
}

+ (UIImage *)getImage:(UIImage *)image mask:(UIImage *)mask
{
    CGImageRef imageRef = CGImageCreateWithMask(image.CGImage, mask.CGImage);
    UIImage *tmpImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return tmpImage;
}

+ (UIImage *)getImageWithView:(UIView *)view rect:(CGRect)rect scale:(CGFloat)scale
{
    UIView *tmpView = view;
    CGSize size = rect.size;
    CGSize scaleSize = CGSizeMake((int)(size.width * scale), (int)(size.height * scale));
    
    UIGraphicsBeginImageContext(scaleSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(context, scale, scale);

    CGContextTranslateCTM(context, -CGRectGetMinX(rect), -CGRectGetMinY(rect));

    [tmpView.layer renderInContext:context];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return resultImage;
}

+ (UIImage *)getCircleImage:(UIImage *)image withParam:(CGFloat)inset
{
//    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat edge = (width < height ? width : height);
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.1);
    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
//    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGRect rect = CGRectMake(width / 2.0f - edge / 2.0, height / 2.0 - edge / 2.0, edge, edge);
//    CGContextAddEllipseInRect(context, rect);
    CGContextAddArc(context, width / 2.0f, height / 2.0, edge / 2.0, 0, 2*M_PI, YES);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextAddArc(context, width / 2.0f, height / 2.0, edge / 2.0, 0, 2 * M_PI, YES);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

+ (UIImage *)cropImage:(UIImage *)image
                 frame:(CGRect)frame
                 angle:(NSInteger)angle
          circularClip:(BOOL)circular
{
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = (alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaLast ||
                     alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaPremultipliedLast);
    
    UIImage *croppedImage = nil;
    UIGraphicsBeginImageContextWithOptions(frame.size, !hasAlpha && !circular, [UIScreen mainScreen].scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (circular) {
            CGContextAddEllipseInRect(context, (CGRect){CGPointZero, frame.size});
            CGContextClip(context);
        }
        
        //To conserve memory in not needing to completely re-render the image re-rotated,
        //map the image to a view and then use Core Animation to manipulate its rotation
        if (angle != 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.layer.minificationFilter = kCAFilterNearest;
            imageView.layer.magnificationFilter = kCAFilterNearest;
            imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle * (M_PI/180.0f));
            CGRect rotatedRect = CGRectApplyAffineTransform(imageView.bounds, imageView.transform);
            UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, rotatedRect.size}];
            [containerView addSubview:imageView];
            imageView.center = containerView.center;
            CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
            [containerView.layer renderInContext:context];
        }
        else {
            CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
            [image drawAtPoint:CGPointZero];
        }
        
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:croppedImage.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
}

@end
