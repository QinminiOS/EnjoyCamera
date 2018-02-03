//
//  RTImagePickerTapDetectingView.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/23/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol RTImagePickerTapDetectingViewDelegate;

@interface RTImagePickerTapDetectingView : UIView

@property (nonatomic, weak) id <RTImagePickerTapDetectingViewDelegate> tapDelegate;

@end

@protocol RTImagePickerTapDetectingViewDelegate <NSObject>

@optional

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end