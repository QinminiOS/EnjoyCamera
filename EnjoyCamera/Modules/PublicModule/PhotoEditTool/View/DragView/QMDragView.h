//
//  QMDragView.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/21.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMDragView : UIView
@property (nonatomic, strong, readonly) UIImageView *imageView;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (instancetype)copyWithScaleFactor:(CGFloat)factor relativedView:(UIView *)imageView;

- (void)hideToolBar;
- (void)showToolBar;
- (BOOL)isToolBarHidden;
@end
