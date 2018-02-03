//
//  RTImagePickerUnauthorizedView.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/22/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTImagePickerUnauthorizedView : UIView

@property (nonatomic, strong) UIButton *permissionButton;
@property (nonatomic, strong) UILabel  *permissionTitleLabel;
@property (nonatomic, copy) void (^onPermissionButton)(void);

@end
