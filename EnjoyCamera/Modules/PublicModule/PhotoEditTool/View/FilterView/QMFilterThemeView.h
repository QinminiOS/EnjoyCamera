//
//  QMThemeListView.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/5.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMBaseThemeView.h"
#import "QMFilterModel.h"

@interface QMFilterThemeView : QMBaseThemeView
@property (nonatomic, strong) NSArray<QMFilterModel *> *filterModels;
@property (nonatomic, strong) void(^sliderValueChangeBlock)(NSInteger index, float value);
@property (nonatomic, strong) void(^filterClickBlock)(QMFilterModel *model);

- (instancetype)init;

- (void)reloadData;
@end
