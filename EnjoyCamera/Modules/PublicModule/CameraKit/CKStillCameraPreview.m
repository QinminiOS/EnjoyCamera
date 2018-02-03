//
//  CKStillCameraPreview.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/9.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "CKStillCameraPreview.h"

#define kCameraViewTopBGHeight      70

@interface CKStillCameraPreview()
{
    CGFloat     _lastTwoFingerDistance;
}
@end

@implementation CKStillCameraPreview

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUserInteractionEnabled:YES];
        [self setupGesture];
    }
    
    return self;
}

- (void)setupGesture
{
    // 捏合
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] init];
    [self addGestureRecognizer:pinchGesture];
    _pinchGestureSignal = [pinchGesture rac_gestureSignal];
    
    // 轻敲
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [self addGestureRecognizer:tapGesture];
    _tapGestureSignal = [tapGesture rac_gestureSignal];
    
    // 轻扫
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] init];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGesture];
    _swipeRightGestureSignal = [swipeRightGesture rac_gestureSignal];
    
    // 轻扫
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] init];
    swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeGestureLeft];
    _swipeLeftGestureSignal = [swipeGestureLeft rac_gestureSignal];
}

@end
