//
//  RTImagePickerViewController.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <Photos/Photos.h>

@class RTImagePickerViewController;

@protocol RTImagePickerViewControllerDelegate <NSObject>

@optional
- (void)rt_imagePickerController:(RTImagePickerViewController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;
- (void)rt_imagePickerController:(RTImagePickerViewController *)imagePickerController didFinishPickingImages:(NSArray<UIImage *> *)images;
- (void)rt_imagePickerController:(RTImagePickerViewController *)imagePickerController didFinishPickingVideoWithFileName:(NSString *)fileName withCaptureImage:(UIImage *)image;
- (void)rt_imagePickerControllerDidCancel:(RTImagePickerViewController *)imagePickerController;

- (BOOL)rt_imagePickerController:(RTImagePickerViewController *)imagePickerController shouldSelectAsset:(PHAsset *)asset;
- (void)rt_imagePickerController:(RTImagePickerViewController *)imagePickerController didSelectAsset:(PHAsset *)asset;
- (void)rt_imagePickerController:(RTImagePickerViewController *)imagePickerController didDeselectAsset:(PHAsset *)asset;

@end

typedef NS_ENUM(NSUInteger, RTImagePickerMediaType) {
    RTImagePickerMediaTypeAny = 0,
    RTImagePickerMediaTypeImage,
    RTImagePickerMediaTypeVideo
};

@interface RTImagePickerViewController : UIViewController

@property (nonatomic, weak) id<RTImagePickerViewControllerDelegate>     delegate;

@property (nonatomic, strong, readonly) NSMutableOrderedSet             *selectedAssets;

@property (nonatomic, copy) NSArray                                     *assetCollectionSubtypes;
@property (nonatomic, assign) RTImagePickerMediaType                    mediaType;

@property (nonatomic, assign) BOOL                                      allowsMultipleSelection;
@property (nonatomic, assign) NSUInteger                                minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger                                maximumNumberOfSelection;

@property (nonatomic, copy) NSString                                    *prompt;
@property (nonatomic, assign) BOOL                                      showsNumberOfSelectedAssets;

@property (nonatomic, assign) NSUInteger                                numberOfColumnsInPortrait;
@property (nonatomic, assign) NSUInteger                                numberOfColumnsInLandscape;

@end
