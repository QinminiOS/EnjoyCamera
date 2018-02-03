//
//  RTImagePickerNavigationController.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/22/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTImagePickerToolbarView.h"

@interface RTImagePickerNavigationController : UINavigationController

@property (nonatomic, weak) RTImagePickerToolbarView *toolBarView;

- (void)setupToolBarView:(RTImagePickerToolbarView *)toolBarView;

@end
