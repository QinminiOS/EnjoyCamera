//
//  Constants.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

// 裁剪比例
typedef enum {
    QMRatioTypeNone = 1,
    QMRatioType11,
    QMRatioType32,
    QMRatioType43,
    QMRatioType54,
    QMRatioType75,
    QMRatioType169,
    QMRatioTypeHorizontal,
    QMRatioTypeVertical,
    QMRatioTypeRotate,
    QMRatioTypeFree
} QMRatioType;

// 闪关灯类型
typedef enum {
    QMFlashTypeNone = 1,
    QMFlashTypeAuto,
    QMFlashTypeAlways,
    QMFlashTypeTorch
} QMFlashType;

// 主题蓝色
#define kMainThemeColor     [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:1.0]

// 滤镜路径
#define kFilterPath         [[NSBundle mainBundle] pathForResource:@"Filters" ofType:nil]

// 屏幕宽高
#define kScreenSize         [UIScreen mainScreen].bounds.size
#define kScreenW            [UIScreen mainScreen].bounds.size.width
#define kScreenH            [UIScreen mainScreen].bounds.size.height

// 强弱引用
#define weakSelf()          __weak typeof(self) wself = self;
#define strongSelf()        __strong typeof(self) self = wself;

// 字符串
#define NSStringMake(str)   @#str

// 设备型号
#define iPhoneX             (kScreenW == 375.f && kScreenH == 812.f)

#endif /* Constants_h */

