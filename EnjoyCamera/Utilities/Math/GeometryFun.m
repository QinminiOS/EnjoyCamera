//
//  GeometryFun.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "GeometryFun.h"

// 是否为CGPointZero
BOOL isPointZero(CGPoint p)
{
    return fabs(p.x) < (double)__FLT_EPSILON__ && fabs(p.y) < (double)__FLT_EPSILON__;
}

// 是否为CGSizeZero
BOOL isSizeZero(CGSize s)
{
    return fabs(s.width) < (double)__FLT_EPSILON__ && fabs(s.height) < (double)__FLT_EPSILON__;
}

// 是否为CGRectZero
BOOL isRectZero(CGRect r)
{
    return isPointZero(r.origin) && isSizeZero(r.size);
}

//角度转化弧度
CGFloat randian(CGFloat angle)
{
    return (angle * M_PI / 180.0);
}
//弧度转化角度
CGFloat angle(CGFloat radian)
{
    return (radian * 180.0 / M_PI);
}

// 线段与rect的交点 (如果有多个交点只回返第一个点)
CGPoint intersection(CGPoint l1, CGPoint l2, CGRect rect, BOOL *flag)
{
    
    CGPoint p1 = {CGRectGetMinX(rect), CGRectGetMinY(rect)};
    CGPoint p2 = {CGRectGetMaxX(rect), CGRectGetMinY(rect)};
    CGPoint p3 = {CGRectGetMaxX(rect), CGRectGetMaxY(rect)};
    CGPoint p4 = {CGRectGetMinX(rect), CGRectGetMaxY(rect)};
    CGPoint p[5] = {p1, p2, p3, p4, p1};
    
    CGPoint p0 = CGPointZero;
    *flag = NO;
    
    for (int i = 0; i < 4; i++)
    {
        p0 = lineIntersection(l1, l2, p[i], p[i + 1], flag);
        
        //        NSLog(@"line1=%f,%f   %f,%f", l1.x, l1.y, l2.x, l2.y);
        //        NSLog(@"line2=%f,%f   %f,%f", p[i].x, p[i].y, p[i+1].x, p[i+1].y);
        
        if (*flag) {
            break;
        }
    }
    
    return p0;
}

// 交叉乘积 (P1-P0) x (P2-P0)
CGFloat xmult(CGPoint p1, CGPoint p2, CGPoint p0)
{
    return (p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y);
}

BOOL isOnLine(CGPoint p, CGPoint l1, CGPoint l2)
{
    BOOL flag1 = xmult(p, l1, l2) < 0.01;            //平行
    BOOL flag2 = (l1.x - p.x) * (l2.x - p.x) < 0.01; //l的x方向之间
    BOOL flag3 = (l1.y - p.y) * (l2.y - p.y) < 0.01; //l的y方向之间
    
    return flag1 && flag2 && flag3;
}

// 两个线段的交点
CGPoint lineIntersection(CGPoint a1, CGPoint a2, CGPoint b1, CGPoint b2, BOOL *flag)
{
    CGPoint p = CGPointZero;
    CGVector v1 = CGVectorMake(a1.x - a2.x, a1.y - a2.y);
    CGVector v2 = CGVectorMake(b1.x - b2.x, b1.y - b2.y);
    
    // 平行
    if (fabs(v1.dx * v2.dy - v1.dy * v2.dx) < __FLT_EPSILON__)
    {
        *flag = NO;
    }
    // a线段长度为0，
    else if (isPointZero(CGPointMake(a1.x - a2.x, a1.y - a2.y)))
    {
        // 在b线段上
        if (isOnLine(a1, b1, b2))
        {
            *flag = YES;
            p = a1;
        }
        else
        {
            *flag = NO;
        }
    }
    // b线段长度为0
    else if (isPointZero(CGPointMake(a1.x - a2.x, a1.y - a2.y)))
    {
        // 在b线段上
        if (isOnLine(b1, a1, a2))
        {
            *flag = YES;
            p = b1;
        }
        else
        {
            *flag = NO;
        }
    }
    // a线段垂直
    else if (a2.x - a1.x == 0)
    {
        CGFloat kb = (b2.y - b1.y) / (b2.x - b1.x);
        CGFloat x = a1.x;
        CGFloat y = kb * (x - b1.x) + b1.y;
        if (isOnLine(CGPointMake(x, y), a1, a2) && isOnLine(CGPointMake(x, y), b1, b2)) {
            *flag = YES;
            p = CGPointMake(x, y);
        } else {
            *flag = NO;
        }
    }
    // b线段垂直
    else if (b2.x - b1.x == 0)
    {
        CGFloat ka = (a2.y - a1.y) / (a2.x - a1.x);
        CGFloat x = b1.x;
        CGFloat y = ka * (x - a1.x) + a1.y;
        if (isOnLine(CGPointMake(x, y), a1, a2) && isOnLine(CGPointMake(x, y), b1, b2)) {
            *flag = YES;
            p = CGPointMake(x, y);
        } else {
            *flag = NO;
        }
    }
    else
    {
        *flag = YES;
        CGFloat ka = (a2.y - a1.y) / (a2.x - a1.x);//a1(100,100) a2{120,220} b1(0,200) b2(200, 200)
        CGFloat kb = (b2.y - b1.y) / (b2.x - b1.x);
        CGFloat x = (ka * a1.x - kb * b1.x + b1.y - a1.y) / (ka - kb);
        CGFloat y = ka * (x - a1.x) + a1.y;
        
        //NSLog(@"x=%f, y=%f", x, y);
        
        if (isOnLine(CGPointMake(x, y), a1, a2) && isOnLine(CGPointMake(x, y), b1, b2)) {
            *flag = YES;
            p = CGPointMake(x, y);
        } else {
            *flag = NO;
        }
    }
    
    return p;
}

// 两个点的长度
CGFloat length(CGPoint point0, CGPoint point1)
{
    return sqrtf(pow(point0.x - point1.x, 2) + pow(point0.y - point1.y, 2));
}

// 弧度，0 ～ 2pi
CGFloat radian(CGPoint origin, CGPoint point0, CGPoint point1)
{
    CGFloat a = sqrt(pow(point0.x - point1.x, 2) + pow(point0.y - point1.y, 2));
    CGFloat b = sqrt(pow(origin.x - point0.x, 2) + pow(origin.y - point0.y, 2));
    CGFloat c = sqrt(pow(origin.x - point1.x, 2) + pow(origin.y - point1.y, 2));
    
    CGFloat cosA = 0.0;
    if (b != 0 && c != 0) {
        cosA = (pow(b, 2) + pow(c, 2) - pow(a, 2)) / 2 * b * c;
    }
    
    return acosf(cosA);
}

// 线弧度, 0 ~ 2pi
CGFloat lineRadian(CGPoint point0, CGPoint point1)
{
    CGFloat dy = point1.y - point0.y;
    CGFloat dx = point1.x - point0.x;
    
    CGFloat A = atan2f(dy, dx);
    if (dy < 0 && dx < 0) {
        A = M_PI + A;
    }
    if (dx < 0 && dy > 0) {
        A = M_PI + A;
    }
    if (dy == 0 && dx < 0) {
        A = M_PI + A;
    }
    
    if (A < 0) {
        A = A + 2 * M_PI;
    }
    
    return A;
}

// 沿着startPoint -> endPoint 方向上距离len的点
CGPoint outPoint(CGPoint startPoint, CGPoint endPoint, CGFloat len, BOOL *flag)
{
    //    NSLog(@"startPoint=%f,%f", startPoint.x, startPoint.y);
    //    NSLog(@"endPoint=%f,%f", endPoint.x, endPoint.y);
    
    CGFloat l0 = sqrt(pow(startPoint.x - endPoint.x, 2) + pow(startPoint.y - endPoint.y, 2));
    CGFloat l1 = l0 + len;
    
    if (l0 < 0.01) {
        *flag = NO;
        return CGPointZero;
    } else {
        *flag = YES;
    }
    
    CGFloat sinA = (endPoint.y - startPoint.y) / l0;
    CGFloat cosA = (endPoint.x - startPoint.x) / l0;
    
    CGFloat x = l1 * cosA + startPoint.x;
    CGFloat y = l1 * sinA + startPoint.y;
    
    return CGPointMake(x, y);
}

BOOL isPointInRect(CGPoint point, CGRect rect)
{
    CGFloat pX = point.x;
    CGFloat pY = point.y;
    
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
    if (pX > minX && pX < maxX && pY > minY && pY < maxY) {
        return YES;
    }
    
    return NO;
}

CGPoint projectionCoordinateInLine(CGPoint sourcePoint, CGPoint linePoint, CGFloat k)
{
    //y = k * x - linePoint.x * k + linePoint.y
    //y = -1/k * x - sourcePoint.x * -1/k + sourcePoint.y;
    //(k + 1/k) * x = linePoint.x * k - linePoint.y  - sourcePoint.x * -1/k + sourcePoint.y
    
    CGFloat x = 0;
    CGFloat y = 0;
    
    if (fabs(k) < 0.001) {
        y = linePoint.y;
        x = sourcePoint.x;
    }
    else {
        x = (linePoint.x * k - linePoint.y + sourcePoint.x /k + sourcePoint.y) / (k + 1/k);
        y = k * x - linePoint.x * k + linePoint.y;
    }
    
    return CGPointMake(x, y);
}


CGPoint projectionCoordinateInLine2(CGPoint sourcePoint, CGPoint linePoint0, CGPoint linePoint1)
{
    if (fabs(linePoint1.x - linePoint0.x) < 1) {
        CGFloat x = linePoint0.x;
        CGFloat y = sourcePoint.y;
        
        return CGPointMake(x, y);
    }
    
    CGFloat k = (linePoint1.y - linePoint0.y) / (linePoint1.x - linePoint0.x);
    
    return projectionCoordinateInLine(sourcePoint, linePoint0, k);
}


//获取直线上的某个点y坐标
CGFloat getPointXWithPointYAndLine(CGFloat pointY, CGPoint linePoint0, CGPoint linePoint1)
{
    // k = (linePoint1.y - linePoint1.y)/(linePoint1.x - linePoint0.x);
    // y = k * (x - linePoint0.x) + linePoint0.y;
    if (fabs(linePoint1.x - linePoint0.x) < 1) {
        NSLog(@"error: linePoint0.x == linePoint1.x");
        return linePoint0.x;
    }
    
    if (fabs(linePoint1.y - linePoint0.y) < 1) {
        NSLog(@"error: linePoint0.y == linePoint1.y");
        
        return linePoint0.x;
    }
    
    CGFloat k = (linePoint1.y - linePoint0.y)/(linePoint1.x - linePoint0.x);
    
    CGFloat x = (pointY - linePoint0.y) / k + linePoint0.x;
    
    return x;
}

//获取直线上的某个点x坐标
CGFloat getPointYWithPointXAndLine(CGFloat pointX, CGPoint linePoint0, CGPoint linePoint1)
{
    if (fabs(linePoint0.x - linePoint1.x) < 1) {
        NSLog(@"error:getPointYWithPointXAndLine()");
        return 0;
    }
    if (fabs(linePoint0.y - linePoint1.y) < 1) {
        return linePoint0.y;
    }
    
    CGFloat k = (linePoint1.y - linePoint0.y)/(linePoint1.x - linePoint0.x);
    
    CGFloat y = k * (pointX - linePoint0.x) + linePoint0.y;
    
    return y;
}


@implementation GeometryFun

@end
