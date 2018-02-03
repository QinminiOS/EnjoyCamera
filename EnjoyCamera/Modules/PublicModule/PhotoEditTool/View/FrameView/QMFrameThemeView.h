//
//  QMFrameThemeView.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/19.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMBaseThemeView.h"
#import "QMFrameModel.h"

@interface QMFrameThemeView : QMBaseThemeView
@property (nonatomic, strong) NSArray<QMFrameModel *> *frameModels;
@property (nonatomic, strong) void(^frameClickBlock)(QMFrameModel *model);
- (void)reloadData;
@end
