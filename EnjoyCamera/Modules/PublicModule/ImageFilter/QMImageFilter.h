//
//  QMUImageFilter.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/8/21.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "QMFilterModel.h"

@interface QMImageFilter : GPUImageFilter
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFilterModel:(QMFilterModel *)model;
- (void)setAlpha:(CGFloat)alpha;
@end
