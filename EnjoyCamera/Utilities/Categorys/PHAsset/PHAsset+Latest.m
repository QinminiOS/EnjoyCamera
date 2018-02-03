//
//  PHAsset+Latest.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/9.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "PHAsset+Latest.h"

@implementation PHAsset (Latest)

+ (PHAsset *)latestAsset
{
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    return [assetsFetchResults firstObject];
}

+ (UIImage *)latestOriginImage
{
    PHAsset *asset = [self latestAsset];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
     CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    
    __block UIImage *image = nil;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        image = result;
    }];
    
    return image;
}

+ (void)latestImageWithSize:(CGSize)size completeBlock:(void (^)(UIImage *))block
{
    PHAsset *asset = [self latestAsset];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (block) {
            block(result);
        }
    }];
}

@end
