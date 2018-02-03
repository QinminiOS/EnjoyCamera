//
//  UIImage+Mosaic.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "UIImage+Mosaic.h"

static CGContextRef CreateRGBABitmapContext (CGImageRef inImage)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData; //内存空间的指针，该内存空间的大小等于图像使用RGB通道所占用的字节数。
    size_t bitmapByteCount;
    size_t bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage); //获取横向的像素点的个数
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    bitmapBytesPerRow    = (pixelsWide * 4); //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
    bitmapByteCount    = (bitmapBytesPerRow * pixelsHigh); //计算整张图占用的字节数
    
    colorSpace = CGColorSpaceCreateDeviceRGB();//创建依赖于设备的RGB通道
    //分配足够容纳图片字节数的内存空间
    bitmapData = malloc( bitmapByteCount );
    //创建CoreGraphic的图形上下文，该上下文描述了bitmaData指向的内存空间需要绘制的图像的一些绘制参数
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    //Core Foundation中通过含有Create、Alloc的方法名字创建的指针，需要使用CFRelease()函数释放
    CGColorSpaceRelease( colorSpace );
    return context;
}


static unsigned char *RequestImagePixelData(UIImage *inImage)
{
    CGImageRef img = [inImage CGImage];
    CGSize size = [inImage size];
    //使用上面的函数创建上下文
    CGContextRef cgctx = CreateRGBABitmapContext(img);
    
    CGRect rect = {{0,0},{size.width, size.height}};
    //将目标图像绘制到指定的上下文，实际为上下文内的bitmapData。
    CGContextDrawImage(cgctx, rect, img);
    unsigned char *data = CGBitmapContextGetData (cgctx);
    //释放上面的函数创建的上下文
    CGContextRelease(cgctx);
    return data;
}

@implementation UIImage (Mosaic)


- (UIImage *)mosaicImage_all_WithLevel:(int)level
{
    unsigned char *imgPixel = RequestImagePixelData(self);
    CGImageRef inImageRef = [self CGImage];
    size_t width = CGImageGetWidth(inImageRef);
    size_t height = CGImageGetHeight(inImageRef);
    unsigned char prev[4] = {0};
    size_t bytewidth = width * 4;
    int i,j;
    int val = level;
    
    for(i=0;i<height;i++) {
        if (((i+1)%val) == 0) {
            memcpy(imgPixel+bytewidth*i, imgPixel+bytewidth*(i-1), bytewidth);
            continue;
        }
        for(j=0;j<width;j++) {
            if (((j+1)%val) == 1) {
                memcpy(prev, imgPixel+bytewidth*i+j*4, 4);
                continue;
            }
            memcpy(imgPixel+bytewidth*i+j*4, prev, 4);
        }
    }
    NSInteger dataLength = width*height* 4;
    //下面的代码创建要输出的图像的相关参数
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    //创建要输出的图像
    CGImageRef imageRef = CGImageCreate(width, height,
                                        bitsPerComponent,
                                        bitsPerPixel,
                                        bytewidth,
                                        colorSpaceRef,
                                        bitmapInfo,
                                        provider,
                                        NULL, NO, renderingIntent);
    UIImage *my_Image = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    return my_Image;
}

- (UIImage *)mosaicImage_ios_6_0_WithLevel:(int)level
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter= [CIFilter filterWithName:@"CIPixellate"];
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    CIVector *vector = [CIVector vectorWithX:self.size.width /2.0f Y:self.size.height /2.0f];
    [filter setDefaults];
    [filter setValue:vector forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithDouble:level] forKey:@"inputScale"];
    [filter setValue:inputImage forKey:@"inputImage"];
    
    CGImageRef cgiimage = [context createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage scale:self.scale orientation:self.imageOrientation];
    
    CGImageRelease(cgiimage);
    
    return newImage;
}

- (UIImage *)mosaicImageWithLevel:(int)level
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
        return [self mosaicImage_all_WithLevel:level];
    }

    return [self mosaicImage_ios_6_0_WithLevel:level];
}

- (UIImage *)mosaicDefaultImage
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
        return [self mosaicImage_all_WithLevel:24.0];
    }
    
    return [self defaultMosaic_ios_6_0];
}

- (UIImage *)defaultMosaic_ios_6_0
{
    // 0. 导入CIImage图片
    
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:self.CGImage];
    

    // 1. 创建出Filter滤镜
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setDefaults];
    CIVector *vector = [CIVector vectorWithX:self.size.width /2.0f Y:self.size.height /2.0f];

    [filter setValue:vector forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithDouble:24] forKey:@"inputScale"];
    

    
    CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
    
    // 2. 用CIContext将滤镜中的图片渲染出来
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outImage fromRect:[ciImage extent]];
    
    // 3. 导出图片
    UIImage *showImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return showImage;
}

@end
