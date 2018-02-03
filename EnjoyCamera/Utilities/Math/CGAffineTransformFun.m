//
//  CGAffineTransformFun.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "CGAffineTransformFun.h"

@implementation CGAffineTransformFun

/*
 
 错误：
 
 平移：
      | 1  0  dx |   | x |   | x + dx |
 t1 = | 0  1  dy | * | y | = | y + dy |
      | 0  0   1 |   | 1 |   |   1    |
 
 缩放：
      | sx 0  0|
 t2 = | 0  sy 0|
      | 0  0  1|
 
 旋转：
      |  cos(angle)  sin(angle)  0 |
 t3 = | -sin(angle)  cos(angle)  0 |
      |  0           0           1 |
 
 
 平移、缩放、旋转：
                    
 t = t1 * t2 * t3
 
     |  sx * cos(angle)                              sx * sin(angle)                              0 |
   = | -sy * sin(angle)                              sy * cos(angle)                              0 |
     |  sx * dx * cos(angle) - sy * dy * sin(angle)  sx * dx * sin(angle) + sy * dy * cos(angle)  1 |
 
 因为，
     | a  b  0 |
 t = | c  d  0 |
     | tx ty 1 |
 
 所以，
 a = sx * cos(angle)
 b = sx * sin(angle)
 c = -sy * sin(angle)
 d = sy * cos(angle)
 tx = sx * dx * cos(angle) - sy * dy * sin(angle)
 ty = sx * dx * sin(angle) + sy * dy * cos(angle)
 
 */

/*
 
 正确：
 
 缩放：
      | sx 0  0|
 t1 = | 0  sy 0|
      | 0  0  1|
 
 
 旋转：
      |  cos(angle)  sin(angle)  0 |
 t2 = | -sin(angle)  cos(angle)  0 |
      |  0           0           1 |

 
 平移：
      | 1  0  0 |
 t3 = | 0  1  0 |
      | dx dy 1 |
 

 缩放、旋转、平移：
 
 t = t1 * t2 * t3
 
   |  sx * cos(angle)    sx * sin(angle)     0 |
 = | -sy * sin(angle)    sy * cos(angle)     0 |
   |  dx                 dy                  1 |
 
 因为，
     | a  b  0 |
 t = | c  d  0 |
     | tx ty 1 |
 
 所以，
 a = sx * cos(angle)
 b = sx * sin(angle)
 c = -sy * sin(angle)
 d = sy * cos(angle)
 tx = dx
 ty = dy
 
 */


//返回弧度，范围为[0， 2Pi]
+ (CGFloat)radianWithCGAffineTransform:(CGAffineTransform)t {
    double sx = [self scaleXWithCGAffineTransform:t];
    double cos_radian = t.a / sx;
    double sin_radian = t.b / sx;
    double radian = acos(cos_radian);//[0, PI];
    
//    NSLog(@"sx =%f", sx);
//    NSLog(@"cos_randian=%f", cos_radian);
//    NSLog(@"sin_randian=%f", sin_radian);
//    NSLog(@"angle=%f", radian * 180 / M_PI);
    //sin(angle) > 0
    if (sin_radian > 0)
    {
        radian = radian;
    }
    //sin(angle) < 0
    else if (sin_radian < 0)
    {
        radian = 2 * M_PI - radian;
    }
    //sin(angle) = 0
    else  {
        //cos(angle) == 1
        if (cos_radian > 0)
        {
            radian = radian;
        }
        //cos(angle) == -1
        else
        {
            radian = 2* M_PI - radian;
        }
    }
    return radian;
}

+ (CGFloat)scaleXWithCGAffineTransform:(CGAffineTransform)t {
    return sqrt(pow(t.a, 2)  + pow(t.b, 2));
}

+ (CGFloat)scaleYWithCGAffineTransform:(CGAffineTransform)t {
    return sqrt(pow(t.c, 2) + pow(t.d, 2));
}

+ (void)translateWithCGAffineTranform:(CGAffineTransform)t tx:(CGFloat *)tx ty:(CGFloat *)ty {
    float dx = t.tx;
    float dy = t.ty;
    
    *tx = dx;
    *ty = dy;
}


/*
 P(x, y) -> P'(x', y')
 
 x' = a * x + c * y + tx
 y' = b * x + d * y + ty
 
 
 S(w, h) -> S'(w', h')
 
 w' = a * w + c * h'
 h' = b * w + d * h'
 
 */


//获取变换后的point: CGPointApplyAffineTransform(CGPoint point, CGAffineTransform t)
//获取变换后的size: CGSizeApplyAffineTransform(CGSize size, CGAffineTransform t)
//获取变换后的rect: CGRectApplyAffineTransform(CGRect rect, CGAffineTransform t)


//以Rect的中心为原点
+ (CGRect)CGRectForCenterWithAffineTransform:(CGAffineTransform)t CGRect:(CGRect)rect {
    float cx = rect.origin.x + rect.size.width / 2;
    float cy = rect.origin.y + rect.size.height / 2;
    
    //将rect的中心设为原点
    CGPoint center = CGPointMake(cx, cy);
    rect.origin.x = rect.origin.x - center.x;
    rect.origin.y = rect.origin.y - center.y;
    
    //恢恢复rect的中心为原来的位置
    CGRect rect_0 = CGRectApplyAffineTransform(rect, t);
    rect_0.origin.x = rect_0.origin.x + center.x;
    rect_0.origin.y = rect_0.origin.y + center.y;
    
    return rect_0;
}


@end
