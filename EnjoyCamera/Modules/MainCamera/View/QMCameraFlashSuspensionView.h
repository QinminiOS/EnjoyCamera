//
//  QMCameraFlashSuspensionView.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/10.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMSuspensionView.h"
#import "Constants.h"
#import <AVFoundation/AVFoundation.h>

@interface QMCameraFlashSuspensionView : QMSuspensionView
@property (nonatomic, copy) void (^flashCallBack)(AVCaptureFlashMode flash, AVCaptureTorchMode torch, NSString *icon);
+ (instancetype)flashSuspensionView;
@end
