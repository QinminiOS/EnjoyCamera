//
//  QMPhotoEffectViewController.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/26.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMPhotoEffectViewController : UIViewController
@property (nonatomic, strong) UIImage *image;
- (instancetype)initWithImage:(UIImage *)image;
@end
