//
//  QMCustomSlider.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/14.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMCustomSlider : UIView
@property(nullable, nonatomic, strong) UIColor *minimumTrackTintColor;
@property(nullable, nonatomic, strong) UIColor *maximumTrackTintColor;
@property(nullable, nonatomic, copy) void (^sliderValueChangeBlock)(CGFloat value);
@property(nonatomic, assign) CGFloat value;
- (void)setThumbImage:(nullable UIImage *)image;
- (void)setValue:(CGFloat)value wantCallBack:(BOOL)callback;
@end
