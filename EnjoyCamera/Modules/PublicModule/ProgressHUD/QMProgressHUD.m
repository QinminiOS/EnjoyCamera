//
//  QMHUDProgress.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/19.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMProgressHUD.h"
#import <DGActivityIndicatorView.h>
#import "Constants.h"
#import "UIColor+Additions.h"

#define kProgressHUDColor       [UIColor colorWithRGBHex:0xFB9088]

static DGActivityIndicatorView  *activityIndicatorView;

@implementation QMProgressHUD

+ (void)show
{
    if (activityIndicatorView.animating) {
        return;
    }
    void (^block)(void) = ^{
        if (!activityIndicatorView) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScalePulseOut tintColor:kMainThemeColor size:40.0f];
            activityIndicatorView.frame = [UIScreen mainScreen].bounds;
            [window addSubview:activityIndicatorView];
        }
        [activityIndicatorView startAnimating];
    };
    if([NSThread isMainThread]) {
        block();
    }else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (void)hide
{
    void (^block)(void) = ^{
        [activityIndicatorView stopAnimating];
    };
    if([NSThread isMainThread]) {
        block();
    }else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@end
