//
//  QMShakeButton.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/9.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMShakeButton.h"
#import <ReactiveObjC.h>

#define kShakeButtonAnimationDuration 0.08f
#define kShakeButtonMaxScale          1.1f
#define kShakeButtonMinScale          0.9f

@interface QMShakeButton ()
@property (nonatomic, assign, getter=isAnimationFinished) BOOL animationFinished;
@end

@implementation QMShakeButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        @weakify(self)
        [self setAnimationFinished:YES];
        [[self rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self runShakeAnimation];
        }];
    }
    return self;
}

- (void)runShakeAnimation
{
    if (![self isAnimationFinished]) {
        return;
    }
    self.animationFinished = NO;
    
    [UIView animateWithDuration:kShakeButtonAnimationDuration animations:^{
        self.transform = CGAffineTransformMakeScale(kShakeButtonMaxScale, kShakeButtonMaxScale);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kShakeButtonAnimationDuration animations:^{
            self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kShakeButtonAnimationDuration animations:^{
                self.transform = CGAffineTransformMakeScale(kShakeButtonMinScale, kShakeButtonMinScale);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:kShakeButtonAnimationDuration animations:^{
                    self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:kShakeButtonAnimationDuration animations:^{
                        self.transform = CGAffineTransformMakeScale(kShakeButtonMaxScale, kShakeButtonMaxScale);
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:kShakeButtonAnimationDuration animations:^{
                            self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:kShakeButtonAnimationDuration animations:^{
                                self.transform = CGAffineTransformMakeScale(kShakeButtonMinScale, kShakeButtonMinScale);
                            } completion:^(BOOL finished) {
                                [UIView animateWithDuration:kShakeButtonAnimationDuration animations:^{
                                    self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                } completion:^(BOOL finished) {
                                    self.animationFinished = YES;
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }];
}

@end
