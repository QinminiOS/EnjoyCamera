//
//  QMFocusView.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/14.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMCameraFocusView.h"
#import "Constants.h"
#import "QMCustomSlider.h"

#define kFocusViewMaxSize 100
#define kFocusViewMinSize 50

@interface QMCameraFocusView()
@property (nonatomic, strong) QMCustomSlider *luminanceView;
@end

@implementation QMCameraFocusView

+ (instancetype)focusView
{
    QMCameraFocusView *focusView = [[QMCameraFocusView alloc] initWithFrame:CGRectMake(0, 0, kFocusViewMaxSize, kFocusViewMaxSize)];
    focusView.hidden = YES;
    return focusView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self render];
    }
    return self;
}

- (void)render
{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 圆
    CGFloat lineWidth = 2;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(lineWidth, lineWidth, kFocusViewMaxSize-2*lineWidth, kFocusViewMaxSize-2*lineWidth));
    
    CGFloat lineLength = 10.0;
    CGPathMoveToPoint(path, NULL, lineWidth, kFocusViewMaxSize/2);
    CGPathAddLineToPoint(path, NULL, lineLength, kFocusViewMaxSize/2);
    
    // 四条线段
    CGPathMoveToPoint(path, NULL, kFocusViewMaxSize - lineLength, kFocusViewMaxSize/2);
    CGPathAddLineToPoint(path, NULL, kFocusViewMaxSize - lineWidth, kFocusViewMaxSize/2);
    
    CGPathMoveToPoint(path, NULL, kFocusViewMaxSize/2, lineWidth);
    CGPathAddLineToPoint(path, NULL, kFocusViewMaxSize/2, lineLength);
    
    CGPathMoveToPoint(path, NULL, kFocusViewMaxSize/2, kFocusViewMaxSize - lineLength);
    CGPathAddLineToPoint(path, NULL, kFocusViewMaxSize/2, kFocusViewMaxSize - lineWidth);
    
    // 绘制
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGPathRelease(path);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.layer.contents = (__bridge id _Nullable)(image.CGImage);
}

#pragma mark - Public
- (void)setISO:(CGFloat)ISO
{
    _ISO = ISO;
    [self.luminanceView setValue:ISO wantCallBack:NO];
}

- (void)foucusAtPoint:(CGPoint)center
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.luminanceView.hidden = NO;
    self.luminanceView.alpha = 1.0f;
    self.hidden = NO;
    self.alpha = 1.0f;
    self.frame = CGRectMake(0, 0, kFocusViewMaxSize, kFocusViewMaxSize);
    self.center = center;
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = CGRectMake(0, 0, kFocusViewMinSize, kFocusViewMinSize);
        self.center = center;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideFoucusView) withObject:nil afterDelay:0.9f];
    }];
}

#pragma mark - Private
- (void)hideFoucusView
{
    [UIView animateWithDuration:0.1f animations:^{
        self.luminanceView.alpha = 0.1f;
        self.alpha = 0.1f;
    } completion:^(BOOL finished) {
        self.luminanceView.hidden = YES;
        self.hidden = YES;
    }];
}

- (UIView *)luminanceView
{
    if (!_luminanceView) {
        weakSelf();
        _luminanceView = [[QMCustomSlider alloc] initWithFrame:CGRectMake(30, kScreenW*4.0f/3.0f-60, kScreenW-60, 30)];
        _luminanceView.hidden = YES;
        [_luminanceView setThumbImage:[UIImage imageNamed:@"qmkit_luminance_adjust"]];
        [self.superview addSubview:_luminanceView];
        [_luminanceView setSliderValueChangeBlock:^(CGFloat value) {
            wself.alpha = 0.8f;
            [NSObject cancelPreviousPerformRequestsWithTarget:wself];
            [wself performSelector:@selector(hideFoucusView) withObject:nil afterDelay:0.9f];
            if (wself.luminanceChangeBlock) {
                wself.luminanceChangeBlock(value);
            }
        }];
    }
    
    return _luminanceView;
}

@end
