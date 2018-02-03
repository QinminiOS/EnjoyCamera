//
//  QMFocusView.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/14.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface QMCameraFocusView : UIView
@property(nonatomic, assign) CGFloat ISO;
@property(nullable, nonatomic, copy) void (^luminanceChangeBlock)(CGFloat value);

+ (instancetype _Nonnull)focusView;
- (void)foucusAtPoint:(CGPoint)center;
@end
