//
//  QMFilterThemeBaseView.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/5.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMBaseThemeView : UIView
@property (nonatomic, strong) void(^doneButtonClickBlock)(void);
@property (nonatomic, strong) void(^closeButtonClickBlock)(void);
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *contentView;

- (void)setTitle:(NSString *)title;

- (void)show;
- (void)hide;
@end
