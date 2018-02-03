//
//  GeometryFun.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 是否为CGPointZero
BOOL isPointZero(CGPoint p);

// 是否为CGSizeZero
BOOL isSizeZero(CGSize s);

// 是否为CGRectZero
BOOL isRectZero(CGRect r);

//角度转化弧度
CGFloat randian(CGFloat angle);

//弧度转化角度
CGFloat angle(CGFloat radian);

// 线段与rect的交点
CGPoint intersection(CGPoint point0, CGPoint point1, CGRect rect, BOOL *flag);

// 两个线段的交点
CGPoint lineIntersection(CGPoint point1, CGPoint point2, CGPoint point3, CGPoint point4, BOOL *flag);

// 两个点的长度
CGFloat length(CGPoint point0, CGPoint point1);

// 弧度，0 ～ 2pi
CGFloat radian(CGPoint origin, CGPoint point0, CGPoint point1);

// 弧度，0 ~ 2pi
CGFloat lineRadian(CGPoint point0, CGPoint point1);

// 沿着startPoint -> endPoint 方向上距离len的点
CGPoint outPoint(CGPoint startPoint, CGPoint endPoint, CGFloat len, BOOL *flag);

// 点point是否在rect上
BOOL isPointInRect(CGPoint point, CGRect rect);

//一个点在一条直线上的投影坐标
CGPoint projectionCoordinateInLine(CGPoint sourcePoint, CGPoint linePoint, CGFloat k);
CGPoint projectionCoordinateInLine2(CGPoint sourcePoint, CGPoint linePoint0, CGPoint linePoint1);

//获取直线上的某个点y坐标
CGFloat getPointXWithPointYAndLine(CGFloat pointY, CGPoint linePoint0, CGPoint linePoint1);

//获取直线上的某个点x坐标
CGFloat getPointYWithPointXAndLine(CGFloat pointX, CGPoint linePoint0, CGPoint linePoint1);


@interface GeometryFun : NSObject



@end
