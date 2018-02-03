//
//  RTImagePickerUnauthorizedView.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/22/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTImagePickerUnauthorizedView.h"
#import "UIView+Geometry.h"

@interface RTImagePickerUnauthorizedView()

@end

@implementation RTImagePickerUnauthorizedView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.permissionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 200.0f, self.width - 200.0f, 25.0f)];
        _permissionTitleLabel.font = [UIFont systemFontOfSize:17.0f];
        _permissionTitleLabel.textColor = [UIColor colorWithRed:113.0f/255.0f green:113.0f/255.0f blue:113.0f/255.0f alpha:1.0f];
        _permissionTitleLabel.textAlignment = NSTextAlignmentCenter;
        _permissionTitleLabel.numberOfLines = 0;
        _permissionTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self addSubview:_permissionTitleLabel];
        
        self.permissionButton = [[UIButton alloc] initWithFrame:CGRectMake(100.0f, _permissionTitleLabel.bottom + 100.0f, self.width - 200.0f, 28.0f)];
        [_permissionButton setTitle:@"允许开启" forState:UIControlStateNormal];
        [_permissionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_permissionButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateHighlighted];
        _permissionButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        _permissionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_permissionButton addTarget:self action:@selector(permissionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_permissionButton];
    }
    return self;
}

- (void)permissionButtonPressed:(id)sender
{
    if(self.onPermissionButton) {
        self.onPermissionButton();
    }
}
@end
