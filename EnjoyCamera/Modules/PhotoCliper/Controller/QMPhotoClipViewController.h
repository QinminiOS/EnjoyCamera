//
//  QMPhotoClipViewController.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/26.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMPhotoClipViewController : UIViewController
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void(^completionBlock)(UIImage *image, CGSize size, CGFloat rotate);
@end
