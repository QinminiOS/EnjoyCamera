//
//  QMCameraRatioSuspensionView.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/9.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMSuspensionView.h"
#import "Constants.h"

@interface QMCameraRatioSuspensionView : QMSuspensionView
@property (nonatomic, copy) void (^ratioCallBack)(QMSuspensionModel *item);
+ (instancetype)ratioSuspensionView;
@end
