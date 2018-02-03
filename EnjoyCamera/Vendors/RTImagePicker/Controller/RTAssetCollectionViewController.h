//
//  RTAssetCollectionViewController.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTImagePickerUtils.h"

@class RTImagePickerViewController;
@class PHAssetCollection;

@interface RTAssetCollectionViewController : UICollectionViewController

@property (nonatomic, weak) RTImagePickerViewController     *imagePickerController;
@property (nonatomic, strong) PHAssetCollection             *assetCollection;

- (void)scrollToBottomAnimated:(BOOL)animated;
@end
