//
//  CKCamera.m
//  EnjoyCamera
//
//  Created by qinmin on 2016/10/9.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import "CKStillCamera.h"

static void* ISOContext;
static void* ISOAdjustingContext;
static void* FocusAdjustingContext;
static void* ExposureTargetOffsetContext;

@implementation CKStillCamera

- (instancetype)init
{
    if (self = [super init]) {
        [self registerObserver];
    }
    return self;
}

- (void)registerObserver
{
    [self.inputCamera addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:&ISOContext];
    [self.inputCamera addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:&FocusAdjustingContext];
    [self.inputCamera addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&ISOAdjustingContext];
    [self.inputCamera addObserver:self forKeyPath:@"exposureTargetOffset" options:NSKeyValueObservingOptionNew context:&ExposureTargetOffsetContext];
}

#pragma mark - 调整焦距
- (BOOL)isFocusPointOfInterestSupported
{
    return [[self inputCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point
{
    if (![[self inputCamera] isFocusPointOfInterestSupported]) {
        return;
    }
    
    // 一定要先设置位置，再设置对焦模式。
    if ([[self inputCamera] isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [self inputCamera].focusPointOfInterest = point;
            [self inputCamera].focusMode = AVCaptureFocusModeAutoFocus;
            [[self inputCamera] unlockForConfiguration];
        }
    }
}

- (void)setFocusModel:(AVCaptureFocusMode)focusModel
{
    if (![[self inputCamera] isFocusPointOfInterestSupported]) {
        return;
    }
    
    if ([[self inputCamera] isFocusModeSupported:focusModel]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [self inputCamera].focusMode = focusModel;
            [[self inputCamera] unlockForConfiguration];
        }
    }
}

- (BOOL)isAutoFocusRangeRestrictionSupported
{
    return [[self inputCamera] isAutoFocusRangeRestrictionSupported];
}

-  (void)setAutoFocusRangeRestrictionModel:(AVCaptureAutoFocusRangeRestriction)autoFocusModel
{
    if (![[self inputCamera] isAutoFocusRangeRestrictionSupported]) {
        return;
    }
    
    if ([[self inputCamera] isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [self inputCamera].autoFocusRangeRestriction = autoFocusModel;
            [[self inputCamera] unlockForConfiguration];
        }
    }
}

- (BOOL)isSmoothAutoFocusSupported
{
    return [[self inputCamera] isSmoothAutoFocusSupported];
}

- (void)enableSmoothAutoFocus:(BOOL)enable
{
    if (![[self inputCamera] isSmoothAutoFocusSupported]) {
        return;
    }
    
    if ([[self inputCamera] isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            self.inputCamera.smoothAutoFocusEnabled = enable;
        }
    }
}

#pragma mark - 曝光
- (BOOL)isExposurePointOfInterestSupported
{
    return [[self inputCamera] isExposurePointOfInterestSupported];
}

- (void)setExposeModel:(AVCaptureExposureMode)exposeModel
{
    if ([[self inputCamera] isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [self inputCamera].exposureMode = AVCaptureExposureModeAutoExpose;
            [[self inputCamera] unlockForConfiguration];
        }
    }
}

- (void)exposeAtPoint:(CGPoint)point
{
    if (![[self inputCamera] isExposurePointOfInterestSupported]) {
        return;
    }
    
    if ([[self inputCamera] isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [self inputCamera].exposurePointOfInterest = point;
            [self inputCamera].exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            [[self inputCamera] unlockForConfiguration];
        }
    }
}

- (float)exposureTargetOffset
{
    return [self.inputCamera exposureTargetOffset];
}

- (void)setExposureModeCustomWithDuration:(CMTime)duration ISO:(float)ISO completionHandler:(void (^)(CMTime))handler
{
    CMTime maxExposureDuration = [self inputCamera].activeFormat.maxExposureDuration;
    CMTime minExposureDuration = [self inputCamera].activeFormat.minExposureDuration;
    CGFloat minISO = [self inputCamera].activeFormat.minISO;
    CGFloat maxISO = [self inputCamera].activeFormat.maxISO;
    
    if (CMTimeCompare(duration, kCMTimeInvalid) == 0 || CMTimeCompare(duration, kCMTimeZero) == 0) {
        duration = minExposureDuration;
    }else if (CMTimeCompare(duration, maxExposureDuration) > 0) {
        duration = maxExposureDuration;
    }else if (CMTimeCompare(duration, minExposureDuration) < 0) {
        duration = minExposureDuration;
    }
    
    ISO = ISO * (maxISO - minISO) + minISO;
    ISO = MAX(MIN(ISO, maxISO), minISO);
    
    NSError *error;
    if ([[self inputCamera] lockForConfiguration:&error]) {
        [[self inputCamera] setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:ISO completionHandler:^(CMTime syncTime) {
            if (handler) {
                handler(syncTime);
            }
        }];
        [[self inputCamera] unlockForConfiguration];
    }else {
        if (handler) {
            handler(kCMTimeInvalid);
        }
    }
}

- (CGFloat)currentISOPercentage
{
    CGFloat minISO = [self inputCamera].activeFormat.minISO;
    CGFloat maxISO = [self inputCamera].activeFormat.maxISO;
    CGFloat current = [self inputCamera].ISO;
    return (current - minISO)/(maxISO - minISO);
}

#pragma mark - 闪光灯
- (AVCaptureFlashMode)currentFlashModel
{
    return [self inputCamera].flashMode;
}

- (void)setFlashModel:(AVCaptureFlashMode)flashModel
{
    if ([self inputCamera].flashMode == flashModel) {
        return;
    }
    
    if ([[self inputCamera] isFlashModeSupported:flashModel]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [self inputCamera].flashMode = flashModel;
            [[self inputCamera] unlockForConfiguration];
        }
    }
}

#pragma mark - 白平衡
- (AVCaptureWhiteBalanceMode)currentWhiteBalanceMode
{
    return [self inputCamera].whiteBalanceMode;
}

- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    if ([self inputCamera].whiteBalanceMode == whiteBalanceMode) {
        return;
    }
    
    if ([[self inputCamera] isWhiteBalanceModeSupported:whiteBalanceMode]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [[self inputCamera] setWhiteBalanceMode:whiteBalanceMode];
            [[self inputCamera] unlockForConfiguration];
        }
    }
}

#pragma mark - 手电筒
- (AVCaptureTorchMode)currentTorchModel
{
    return [self inputCamera].torchMode;
}

- (void)setTorchModel:(AVCaptureTorchMode)torchModel
{
    if ([self inputCamera].torchMode == torchModel) {
        return;
    }
    
    if ([[self inputCamera] isTorchModeSupported:torchModel]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [self inputCamera].torchMode = torchModel;
            [[self inputCamera] unlockForConfiguration];
        }
    }
}

- (void)setTorchLevel:(float)torchLevel
{
    if ([[self inputCamera] isTorchActive]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [[self inputCamera] setTorchModeOnWithLevel:torchLevel error:&error];
            [[self inputCamera] unlockForConfiguration];
        }
    }
}

#pragma mark - 视频缩放
- (BOOL)videoCanZoom
{
    return [self inputCamera].activeFormat.videoMaxZoomFactor > 1.0f;
}

- (float)videoMaxZoomFactor
{
    return MIN([self inputCamera].activeFormat.videoMaxZoomFactor, 4.0f);
}

- (float)videoZoomFactor
{
    return [self inputCamera].videoZoomFactor;
}

- (void)setVideoZoomFactor:(float)factor
{
    if ([self inputCamera].isRampingVideoZoom) {
        return;
    }
    
    NSError *error;
    if ([[self inputCamera] lockForConfiguration:&error]) {
        factor = MAX(MIN(factor, [self videoMaxZoomFactor]), 1.0f);
        [self inputCamera].videoZoomFactor = factor;
        [[self inputCamera] unlockForConfiguration];
    }
}

- (void)rampZoomToFactor:(float)factor
{
    if ([self inputCamera].isRampingVideoZoom) {
        return;
    }
    
    NSError *error;
    if ([[self inputCamera] lockForConfiguration:&error]) {
        [[self inputCamera] rampToVideoZoomFactor:pow([self videoMaxZoomFactor], factor) withRate:50.0f];
        [[self inputCamera] unlockForConfiguration];
    }
}

- (void)rotateCamera
{
    [super rotateCamera];
    [self registerObserver];
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"key = %@", keyPath);
    
    if (&ISOContext == context) {
        if (_ISOChangeBlock) {
            _ISOChangeBlock([change[NSKeyValueChangeNewKey] floatValue]);
        }
    }else if (&ISOAdjustingContext == context) {
        if (_ISOAdjustingBlock) {
            _ISOAdjustingBlock([change[NSKeyValueChangeNewKey] boolValue]);
        }
    }else if (&FocusAdjustingContext == context) {
        if (_FocusAdjustingBlock) {
            _FocusAdjustingBlock([change[NSKeyValueChangeNewKey] boolValue]);
        }
    }else if (&ExposureTargetOffsetContext == context) {
        
    }
}

@end
