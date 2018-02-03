//
//  RTImagePickerTapDetectingImageView.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/23/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RTImagePickerTapDetectingImageViewDelegate;

@interface RTImagePickerTapDetectingImageView : UIImageView {}

@property (nonatomic, weak) id <RTImagePickerTapDetectingImageViewDelegate> tapDelegate;

@end

@protocol RTImagePickerTapDetectingImageViewDelegate <NSObject>

@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end