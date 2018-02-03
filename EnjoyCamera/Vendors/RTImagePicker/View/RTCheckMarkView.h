//
//  RTCheckMarkView.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface RTCheckMarkView : UIView

@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable CGFloat checkmarkLineWidth;

@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, strong) IBInspectable UIColor *bodyColor;
@property (nonatomic, strong) IBInspectable UIColor *checkmarkColor;

@end
