//
//  UIImageView+DisplayFullScreen.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (GraudatedAnimation)

- (void)setImageWithGraudatedAnimation:(UIImage * )image;

- (void)setImageWithGraudatedAnimation:(UIImage * )image duration:(NSTimeInterval)duration;

- (void)setImageWithGraudatedMainAnimation:(UIImage * )image duration:(NSTimeInterval)duration;

- (void)setImageWithGraudatedMainAnimation:(UIImage * )image duration:(NSTimeInterval)duration completion:(void(^)(void))completion;

- (void)setGraudatedAnimationViewFrame:(CGRect)frame;
- (void)setGraudatedAnimationViewTransform:(CGAffineTransform)transfrom;

- (void)setImageWithGraudatedMainAnimation:(UIImage * )image graduatedView:(UIImageView *)graduatedView duration:(NSTimeInterval)duration;

+ (void)clearCatches;

@end
