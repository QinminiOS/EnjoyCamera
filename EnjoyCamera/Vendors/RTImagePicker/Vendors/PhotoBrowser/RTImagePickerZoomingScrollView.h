//
//  RTImagePickerZoomingScrollView.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/23/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTImagePickerPhotoProtocol.h"
#import "RTImagePickerTapDetectingImageView.h"
#import "RTImagePickerTapDetectingView.h"

@class RTImagePickerPhotoBrowser, RTImagePickerPhoto;

@interface RTImagePickerZoomingScrollView : UIScrollView <UIScrollViewDelegate, RTImagePickerTapDetectingImageViewDelegate, RTImagePickerTapDetectingViewDelegate>

@property () NSUInteger index;
@property (nonatomic) id <RTImagePickerPhoto> photo;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;

- (id)initWithPhotoBrowser:(RTImagePickerPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;

@end
