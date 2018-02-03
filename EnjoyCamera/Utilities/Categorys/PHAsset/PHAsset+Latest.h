//
//  PHAsset+Latest.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/9.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (Latest)
/**
 *  获取最新一张图片
 */
+ (PHAsset *)latestAsset;

+ (UIImage *)latestOriginImage;

+ (void)latestImageWithSize:(CGSize)size completeBlock:(void(^)(UIImage *image))block;

@end
