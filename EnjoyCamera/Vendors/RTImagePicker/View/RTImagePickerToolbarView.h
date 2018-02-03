//
//  RTImagePickerToolbarView.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Geometry.h"
#import "RTAssetCollectionViewController.h"

typedef NS_ENUM(NSInteger, RTImagePickerToolbarMode) {
    RTImagePickerToolbarModeImagePicker = 0,
    RTImagePickerToolbarModePhotoBrowser,
    RTImagePickerToolbarModeCamera,
    RTImagePickerToolbarModeCameraPreview,
};

@interface RTImagePickerToolbarView : UIView

@property (nonatomic, strong) UIScrollView                      *previewScrollView;

@property (nonatomic, strong) UIView                            *imagePickerToolbarBackgroundView;
@property (nonatomic, strong) UIView                            *photoBrowserToolbarBackgroundView;
@property (nonatomic, strong) UIView                            *cameraToolBarBackgroundView;

@property (nonatomic, strong) RTAssetCollectionViewController     *viewController;

/**
 *  Buttons for camera
 */
@property (nonatomic, strong) UIButton                          *cameraCancelButton;
@property (nonatomic, strong) UIButton                          *cameraSwitchButton;
@property (nonatomic, strong) UIButton                          *cameraFlashButton;
@property (nonatomic, strong) UIButton                          *cameraSnapButton;

@property (nonatomic, strong) UIImage                           *cameraImage;

- (void)addAsset:(PHAsset *)asset;
- (void)deleteAsset:(PHAsset *)asset;
- (void)SwitchToMode:(RTImagePickerToolbarMode)mode;

- (void)setFlashEnabled:(BOOL)enabled;
- (void)setFlashState:(BOOL)state;

- (void)shakePreviewScrollView;

/**
 *  Method to call when finished selecting video
 *
 *  @param url Video file url
 */
- (void)didSelectVideoWithFileName:(NSString *)fileName captureImage:(UIImage *)image;
@end
