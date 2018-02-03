//
//  UIImage+Alpha.m
///  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "UIImage+Alpha.h"

@implementation UIImage (Alpha)

//创建图片上下文
static CGContextRef CreateARGBBitmapContextWithCGImage(CGImageRef inImage)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    size_t bitmapBytesPerRow = (pixelsWide * 4);
    size_t bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        return nil;
    }
    
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) {
        CGColorSpaceRelease( colorSpace );
        return nil;
    }
    
    context = CGBitmapContextCreate (bitmapData,    //指向要渲染的绘制内存的地址。
                                     pixelsWide,    //bitmap的宽度,单位为像素
                                     pixelsHigh,    //bitmap的高度,单位为像素
                                     8,             //内存中像素的每个组件的位数
                                     bitmapBytesPerRow,//bitmap的每一行在内存所占的比特数
                                     colorSpace,    //bitmap上下文使用的颜色空间
                                     kCGImageAlphaPremultipliedFirst);//指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
    
    if (context == NULL) {
        fprintf (stderr, "Context not created!");
    }
    
    free (bitmapData);
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

//获取图片的像素值
- (NSData *)ARGBData
{
    CGContextRef cgctx = CreateARGBBitmapContextWithCGImage(self.CGImage);
    
    if (cgctx == NULL) {
        return nil;
    }
    
    size_t w = CGImageGetWidth(self.CGImage);
    size_t h = CGImageGetHeight(self.CGImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, self.CGImage);

    void *data = CGBitmapContextGetData (cgctx);
    
    CGContextRelease(cgctx);
    
    if (!data) {
        return nil;
    }
    
    size_t dataSize = 4 * w * h; // ARGB = 4 8-bit components
    
    return [NSData dataWithBytes:data length:dataSize];
}

//图片的某一点point是否透明
- (BOOL)isPointTransparent:(CGPoint)point
{
    NSData *rawData = [self ARGBData];  // See about caching this
    if (rawData == nil) {
        return NO;
    }

    size_t bitPerPoint = 4;//每个像素有4位
    size_t bitPerRow = self.size.width * 4; //每一行的像素
    
    NSUInteger index = point.x * bitPerPoint + (point.y * bitPerRow);
    
    char *rawDataBytes = ( char *)[rawData bytes];
    
    NSLog(@"rawDataBytes[index]=%d",rawDataBytes[index]);
    
    //NSLog(@"rawData = %@",rawData);
    
    return rawDataBytes[index] == 0;
}

// Returns true if the image has an alpha layer
- (BOOL)hasAlpha
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

// Returns a copy of the given image, adding an alpha channel if it doesn't already have one
- (UIImage *)imageWithAlpha
{
    if ([self hasAlpha]) {
        return self;
    }
    
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

// Returns a copy of the image with a transparent border of the given size added around its edges.
// If the image has no alpha layer, one will be added to it.
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize
{
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    CGRect newRect = CGRectMake(0, 0, image.size.width + borderSize * 2, image.size.height + borderSize * 2);
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(self.CGImage),
                                                0,
                                                CGImageGetColorSpace(self.CGImage),
                                                CGImageGetBitmapInfo(self.CGImage));
    
    // Draw the image in the center of the context, leaving a gap around the edges
    CGRect imageLocation = CGRectMake(borderSize, borderSize, image.size.width, image.size.height);
    CGContextDrawImage(bitmap, imageLocation, self.CGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
    
    // Create a mask to make the border transparent, and combine it with the image
    CGImageRef maskImageRef = [self newBorderMask:borderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}

// Creates a mask that makes the outer edges transparent and everything else opaque
// The size must include the entire mask (opaque part + transparent border)
// The caller is responsible for releasing the returned reference by calling CGImageRelease
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Build a context that's the same dimensions as the new size
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
                                                     size.width,
                                                     size.height,
                                                     8, // 8-bit grayscale
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    
    // Start with a mask that's entirely transparent
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
    
    // Make the inner part (within the border) opaque
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
    
    // Get an image of the context
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
    
    // Clean up
    CGContextRelease(maskContext);
    CGColorSpaceRelease(colorSpace);
    
    return maskImageRef;
}

@end
