//
//  UIColor+Additions.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)

+ (UIColor *)colorWithRGBHex:(unsigned int)rgbValue;
+ (UIColor *)colorWithRGBAHex:(unsigned int)rgbaValue;
+ (UIColor *)colorWithRGBHexString:(NSString*)rgbStrValue;
+ (UIColor *)colorWithRGBAHexString:(NSString*)rgbaStrValue;
+ (UIColor *)colorWithRGBDecimalString:(NSString*)rgbaStrValue;
+ (UIColor *)colorWithRGBDecimalString:(NSString*)rgbaStrValue value:(float)value;

+ (UIColor *)colorWithRed255:(CGFloat)red green255:(CGFloat)green blue255:(CGFloat)blue alpha255:(CGFloat)alpha;

- (BOOL)getRGBHex:(unsigned int*)rgbHex;
- (BOOL)getRGBAHex:(unsigned int*)rgbaHex;
- (NSString *)RGBHexString;
- (NSString *)RGBAHexString;
- (NSString *)RGBHexADecString;
- (NSString *)RGBAHexStringWithAplhaOffset:(float)alphaOffset;

- (UIColor *)colorWithSaturation:(CGFloat)newSaturation;
- (UIColor *)colorWithBrightness:(CGFloat)newBrightness;

- (UIColor *)lightenColorWithValue:(CGFloat)value;
- (UIColor *)darkenColorWithValue:(CGFloat)value;
- (BOOL)isLightColor;

- (unsigned int)getRedValue;
- (unsigned int)getGreenValue;
- (unsigned int)getBlueValue;

@end
