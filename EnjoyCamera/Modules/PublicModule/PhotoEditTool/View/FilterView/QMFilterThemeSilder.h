//
//  QMFilterThemeSilder.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/5.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMBaseThemeView.h"

@interface QMFilterThemeSilder : QMBaseThemeView
@property (nonatomic, strong) void(^sliderValueChangeBlock)(NSInteger index, float value);

- (instancetype)init;
- (void)showWithValue:(float)value;

@end
