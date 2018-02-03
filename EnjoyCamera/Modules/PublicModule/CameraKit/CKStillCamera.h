//
//  CKCamera.h
//  EnjoyCamera
//
//  Created by qinmin on 2016/10/9.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface CKStillCamera : GPUImageStillCamera
@property(nullable, nonatomic, copy) void(^ISOChangeBlock)(float ISO);
@property(nullable, nonatomic, copy) void(^ISOAdjustingBlock)(BOOL adjust);
@property(nullable, nonatomic, copy) void(^FocusAdjustingBlock)(BOOL adjust);

// Focus
- (BOOL)isFocusPointOfInterestSupported;
- (void)focusAtPoint:(CGPoint)point;
- (void)setFocusModel:(AVCaptureFocusMode)focusModel;

- (BOOL)isAutoFocusRangeRestrictionSupported;
- (void)setAutoFocusRangeRestrictionModel:(AVCaptureAutoFocusRangeRestriction)autoFocusModel;

- (BOOL)isSmoothAutoFocusSupported;
- (void)enableSmoothAutoFocus:(BOOL)enable;

// Exposure
- (BOOL)isExposurePointOfInterestSupported;
- (void)setExposeModel:(AVCaptureExposureMode)exposeModel;
- (void)exposeAtPoint:(CGPoint)point;
- (float)exposureTargetOffset;
- (CGFloat)currentISOPercentage;
- (void)setExposureModeCustomWithDuration:(CMTime)duration ISO:(float)ISO completionHandler:(nullable void (^)(CMTime syncTime))handler;

// Flash
- (AVCaptureFlashMode)currentFlashModel;
- (void)setFlashModel:(AVCaptureFlashMode)flashModel;

// WhiteBalance
- (AVCaptureWhiteBalanceMode)currentWhiteBalanceMode;
- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode;

// Torch
- (AVCaptureTorchMode)currentTorchModel;
- (void)setTorchModel:(AVCaptureTorchMode)torchModel;
- (void)setTorchLevel:(float)torchLevel;

// Zoom
- (BOOL)videoCanZoom;
- (float)videoZoomFactor;
- (float)videoMaxZoomFactor;
- (void)setVideoZoomFactor:(float)factor;
- (void)rampZoomToFactor:(float)factor;
@end
