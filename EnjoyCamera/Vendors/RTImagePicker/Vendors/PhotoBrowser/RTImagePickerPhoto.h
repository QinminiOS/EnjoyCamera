//
//  RTImagePickerPhoto.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/23/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "RTImagePickerPhotoProtocol.h"

@interface RTImagePickerPhoto : NSObject <RTImagePickerPhoto>

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;

+ (RTImagePickerPhoto *)photoWithImage:(UIImage *)image;
+ (RTImagePickerPhoto *)photoWithURL:(NSURL *)url;
+ (RTImagePickerPhoto *)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
+ (RTImagePickerPhoto *)videoWithURL:(NSURL *)url;

- (id)init;
- (id)initWithImage:(UIImage *)image;
- (id)initWithURL:(NSURL *)url;
- (id)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
- (id)initWithVideoURL:(NSURL *)url;
@end
