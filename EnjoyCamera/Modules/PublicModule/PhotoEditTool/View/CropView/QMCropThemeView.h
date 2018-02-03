//
//  QMCropThemeView.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/5.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMBaseThemeView.h"
#import "QMCropModel.h"
#import "Constants.h"

@interface QMCropThemeView : QMBaseThemeView
@property (nonatomic, strong) NSArray<QMCropModel *> *cropModels;
@property (nonatomic, strong) void(^croperClickBlock)(CGSize aspect, CGFloat rotation);
- (void)reloadData;
@end
