//
//  UIImage+Text.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "UIImage+Text.h"
//#import "NSString+Size.h"

@implementation UIImage (Text)

//+ (UIImage *)drawTextWithStroke:(NSString *)string color:(UIColor *)color {
//    UIFont *font = [UIFont systemFontOfSize:18];
//    CGSize textSize = [string mm_sizeWithFont:font];
//    CGRect rect = CGRectMake(0, 0, textSize.width, textSize.height);
//    CGSize size = CGSizeMake(rect.size.width, rect.size.height);
//    
//    if ([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) {
//        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0f);
//    } else {
//        UIGraphicsBeginImageContext(size);
//    }
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextSetLineWidth(context, 0);
//    CGContextSetTextDrawingMode(context, kCGTextStroke);
//    NSDictionary *attributes = @{NSFontAttributeName : font , NSForegroundColorAttributeName : color};
//    [string drawInRect:rect withAttributes:attributes];
//    
//    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
//    CGContextSetTextDrawingMode(context, kCGTextFill);
//    [string drawInRect:rect withAttributes:attributes];
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}

+ (UIImage *)drawText:(NSString *)text inImage:(UIImage *)image atPoint:(CGPoint)point {
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    NSDictionary *attributes = @{NSFontAttributeName : font};
    [text drawInRect:rect withAttributes:attributes];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


+ (UIImage *)drawDate:(NSString *)text InImage:(UIImage *)image font:(UIFont *)font point:(CGPoint)point{
    
    UIGraphicsBeginImageContext(image.size);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:rect];
    
    rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    NSDictionary *attributes = @{NSFontAttributeName : font , NSForegroundColorAttributeName:[UIColor whiteColor]};
    [text drawInRect:rect withAttributes:attributes];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;

    
}


+ (float)getNameCharNum:(NSString *)a_str
{
    if (nil==a_str) {
        return 0;
    }
    float ret_num=0;
    
    NSInteger len=[a_str length];
    for (int i=0; i<len; i++) {
        unichar c = [a_str characterAtIndex:i];
        
        if((c>=97 && c<=122)||(c>=32 && c<=64)){ //小写字母 标点符号
            
            ret_num = ret_num +0.5;
            
        }else if(c <= 90&&c>=65){//大写字母
            ret_num = ret_num +0.8;
        }else{
            ret_num += 1.0;
        }
    }
    return ret_num;
}

@end
