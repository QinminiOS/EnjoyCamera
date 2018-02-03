//
//  QMFrameModel.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/19.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMBaseThemeView.h"

@interface QMFrameModel : QMBaseThemeView
@property (nonatomic, strong) NSString *icon;
+ (NSArray<QMFrameModel *> *)buildFrameModels;
@end
