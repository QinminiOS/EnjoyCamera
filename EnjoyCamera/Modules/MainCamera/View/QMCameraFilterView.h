//
//  QMCameraFilterView.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/11.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMFilterModel.h"

@interface QMCameraFilterView : UIView
@property (nonatomic, copy) void (^filterItemClickBlock)(QMFilterModel *item, NSInteger selectIndex);
@property (nonatomic, copy) void (^filterValueDidChangeBlock)(CGFloat value);
@property (nonatomic, copy) void (^filterWillShowBlock)(void);
@property (nonatomic, copy) void (^filterWillHideBlock)(void);

+ (instancetype)cameraFilterView;

- (void)setFilterValue:(CGFloat)value animated:(BOOL)animated;
- (BOOL)selectFilterAtIndex:(NSInteger)index;

- (void)toggleInView:(UIView *)view;
- (void)showInView:(UIView *)view;
- (BOOL)hide;

- (void)reloadData;
@end
