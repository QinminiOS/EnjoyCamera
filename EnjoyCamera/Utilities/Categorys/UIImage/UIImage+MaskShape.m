//
//  UIImage+MaskShape.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "UIImage+MaskShape.h"
#import "ColorMatrix.h"

static CGContextRef CreateRGBABitmapContext (CGImageRef inImage)// 返回一个使用RGBA通道的位图上下文
{
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	void *bitmapData; //内存空间的指针，该内存空间的大小等于图像使用RGB通道所占用的字节数。
	int bitmapByteCount;
	int bitmapBytesPerRow;
    
	size_t pixelsWide = CGImageGetWidth(inImage); //获取横向的像素点的个数
	size_t pixelsHigh = CGImageGetHeight(inImage); //纵向
    
	bitmapBytesPerRow	= (pixelsWide * 4); //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
	bitmapByteCount	= (bitmapBytesPerRow * pixelsHigh); //计算整张图占用的字节数
    
	colorSpace = CGColorSpaceCreateDeviceRGB();//创建依赖于设备的RGB通道
	
	bitmapData = malloc(bitmapByteCount); //分配足够容纳图片字节数的内存空间
    
    memset(bitmapData, 0, bitmapByteCount);
    
	context = CGBitmapContextCreate (bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    //创建CoreGraphic的图形上下文，该上下文描述了bitmaData指向的内存空间需要绘制的图像的一些绘制参数
    
	CGColorSpaceRelease( colorSpace );
    //Core Foundation中通过含有Create、Alloc的方法名字创建的指针，需要使用CFRelease()函数释放
    
	return context;
}

static unsigned char *RequestImagePixelData(UIImage *inImage)
// 返回一个指针，该指针指向一个数组，数组中的每四个元素都是图像上的一个像素点的RGBA的数值(0-255)，用无符号的char是因为它正好的取值范围就是0-255
{
	CGImageRef img = [inImage CGImage];
	CGSize size = [inImage size];
    
	CGContextRef cgctx = CreateRGBABitmapContext(img); //使用上面的函数创建上下文
	
	CGRect rect = {{0,0},{size.width, size.height}};
    
	CGContextDrawImage(cgctx, rect, img); //将目标图像绘制到指定的上下文，实际为上下文内的bitmapData。
	unsigned char *data = CGBitmapContextGetData (cgctx);
    
	CGContextRelease(cgctx);//释放上面的函数创建的上下文
	return data;
}


@implementation UIImage (MaskShape)
static void changeRGBA(int *red,int *green,int *blue,int *alpha, const float* f)//修改RGB的值
{
    int redV = *red;
    int greenV = *green;
    int blueV = *blue;
    int alphaV = *alpha;
    
    *red = f[0] * redV + f[1] * greenV + f[2] * blueV + f[3] * alphaV + f[4];
    *green = f[0+5] * redV + f[1+5] * greenV + f[2+5] * blueV + f[3+5] * alphaV + f[4+5];
    *blue = f[0+5*2] * redV + f[1+5*2] * greenV + f[2+5*2] * blueV + f[3+5*2] * alphaV + f[4+5*2];
    *alpha = f[0+5*3] * redV + f[1+5*3] * greenV + f[2+5*3] * blueV + f[3+5*3] * alphaV + f[4+5*3];
    
    if (*red > 255)
    {
        *red = 255;
    }
    if(*red < 0)
    {
        *red = 0;
    }
    if (*green > 255)
    {
        *green = 255;
    }
    if (*green < 0)
    {
        *green = 0;
    }
    if (*blue > 255)
    {
        *blue = 255;
    }
    if (*blue < 0)
    {
        *blue = 0;
    }
    if (*alpha > 255)
    {
        *alpha = 255;
    }
    if (*alpha < 0)
    {
        *alpha = 0;
    }
}


+ (UIImage*)imageWithImage:(UIImage*)inImage withColorMatrix:(const float*) f
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
    
	for(GLuint y = 0;y< h;y++)//双层循环按照长宽的像素个数迭代每个像素点
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++)
		{
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
            int alpha = (unsigned char)imgPixel[pixOff+3];
            changeRGBA(&red, &green, &blue, &alpha, f);
            
            //回写数据
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
            imgPixel[pixOff+3] = alpha;
            
            
			pixOff += 4; //将数组的索引指向下四个元素
		}
        
		wOff += w * 4;
	}
    
	NSInteger dataLength = w * h * 4;
    
    //下面的代码创建要输出的图像的相关参数
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
    
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	
	CGImageRef imageRef = CGImageCreate(w, h, bitsPerComponent, bitsPerPixel, bytesPerRow,colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);//创建要输出的图像
	
	UIImage *myImage = [UIImage imageWithCGImage:imageRef];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return myImage;
}

+ (UIImage *)imageChangeBlackToTransparent:(UIImage *)maskImage
{
    if (!maskImage) {
        return nil;
    }
    
    unsigned char *sourcePixel = RequestImagePixelData(maskImage);
//    unsigned char *imgPixel = RequestImagePixelData(maskImage);
    CGImageRef inImageRef = [maskImage CGImage];
    GLuint w = CGImageGetWidth(inImageRef);
    GLuint h = CGImageGetHeight(inImageRef);
    
    int wOff = 0;
    int pixOff = 0;
    
    
    for(GLuint y = 0;y< h;y++)//双层循环按照长宽的像素个数迭代每个像素点
    {
        pixOff = wOff;
        
        for (GLuint x = 0; x<w; x++)
        {
   
            unsigned char pixelAlpha = sourcePixel[pixOff+3];
//            if(pixelAlpha != 0){
                sourcePixel[pixOff+3] = 255-pixelAlpha;
//            }else{
//                sourcePixel[pixOff+3] = 255;
//            }
            
            pixOff += 4; //将数组的索引指向下四个元素
        }
        
        wOff += w * 4;
    }
    
    NSInteger dataLength = w * h * 4;
    
    //下面的代码创建要输出的图像的相关参数
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, sourcePixel, dataLength, NULL);
    
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * w;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    
    CGImageRef imageRef = CGImageCreate(w, h, bitsPerComponent, bitsPerPixel, bytesPerRow,colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);//创建要输出的图像
    
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    return myImage;
}


- (UIImage *)imageWithMaskImage:(UIImage *)maskImage
{
    if (!maskImage) {
        return self;
    }
 
    unsigned char *sourcePixel = RequestImagePixelData(self);
    unsigned char *imgPixel = RequestImagePixelData(maskImage);
	CGImageRef inImageRef = [maskImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
    
	for(GLuint y = 0;y< h;y++)//双层循环按照长宽的像素个数迭代每个像素点
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++)
		{
//            sourcePixel[pixOff+0] = imgPixel[pixOff+0];
//            sourcePixel[pixOff+1] = imgPixel[pixOff+1];
//            sourcePixel[pixOff+2] = imgPixel[pixOff+2];
            sourcePixel[pixOff+3] = imgPixel[pixOff+3];
            
            
			pixOff += 4; //将数组的索引指向下四个元素
		}
        
		wOff += w * 4;
	}
    
	NSInteger dataLength = w * h * 4;
    
    //下面的代码创建要输出的图像的相关参数
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, sourcePixel, dataLength, NULL);
    
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	
	CGImageRef imageRef = CGImageCreate(w, h, bitsPerComponent, bitsPerPixel, bytesPerRow,colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);//创建要输出的图像
	
	UIImage *myImage = [UIImage imageWithCGImage:imageRef];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return myImage;
}

//for all
- (UIImage *)imageWithMaskImage:(UIImage *)maskImage maskColor:(UIColor *)maskColor
{
    UIImage *sourceImage = self;
    if (maskColor) {
        UIGraphicsBeginImageContext(self.size);
        
        [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        
        CGContextRef ref = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ref, maskColor.CGColor);
        CGContextAddRect(ref, CGRectMake(0, 0, self.size.width, self.size.height));
        CGContextFillPath(ref);
        
        sourceImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    UIImage * newImage = [self imageWithMaskImage:sourceImage];
    
    return newImage;
}

//for ios7
- (UIImage *)imageWithLayerMaskImage:(UIImage *)maskImage maskColor:(UIColor *)maskColor
{    
    //maskLayer
    CALayer *maskLayer = [CALayer layer];
    if (maskImage) {
        maskLayer.frame = CGRectMake(0, 0, maskImage.size.width, maskImage.size.height);
        maskLayer.contents = (id)maskImage.CGImage;
    }

    //sourceImage add maskColor
    
    UIImage *newImage = nil;

    if (maskColor) {
        UIGraphicsBeginImageContext(self.size);
    
        [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
        CGContextRef ref = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ref, maskColor.CGColor);
        CGContextAddRect(ref, CGRectMake(0, 0, self.size.width, self.size.height));
        CGContextFillPath(ref);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    else {
        newImage = self;
    }
    
    //sourceLayer
    CALayer *sourceLayer = [CALayer layer];
    sourceLayer.frame = CGRectMake(0, 0, newImage.size.width, newImage.size.height);
    sourceLayer.contents = (id)newImage.CGImage;
    
    //set maskLayer to sourceLayer
    sourceLayer.mask = maskLayer;
    
    //render the layer for the Image
    UIGraphicsBeginImageContext(newImage.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [sourceLayer renderInContext:context];

    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
