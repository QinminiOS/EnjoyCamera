//
//  CKStillCameraPreview.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/9.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import <ReactiveObjC.h>

@interface CKStillCameraPreview : GPUImageView
@property (nonatomic, strong, readonly) RACSignal *pinchGestureSignal;
@property (nonatomic, strong, readonly) RACSignal *tapGestureSignal;
@property (nonatomic, strong, readonly) RACSignal *swipeRightGestureSignal;
@property (nonatomic, strong, readonly) RACSignal *swipeLeftGestureSignal;
@end
