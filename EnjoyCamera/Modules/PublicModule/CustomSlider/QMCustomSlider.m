//
//  QMCustomSlider.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/14.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMCustomSlider.h"
#import <ReactiveObjC.h>

#define kCustomSliderHeight     2
#define kCustomSliderMargin     0.01f

@interface QMCustomSlider ()
{
    UIView      *_leftLineView;
    UIView      *_rightLineView;
    UIImageView *_imageView;
}
@end

@implementation QMCustomSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _value = 0.0f;
        [self setBackgroundColor:[UIColor clearColor]];
        
        _leftLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _leftLineView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_leftLineView];
        
        CGFloat imageViewSize = frame.size.height;
        _rightLineView = [[UIView alloc] initWithFrame:CGRectMake(imageViewSize+kCustomSliderMargin, imageViewSize/2-kCustomSliderHeight/2, frame.size.width-imageViewSize, kCustomSliderHeight)];
        _rightLineView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_rightLineView];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewSize, imageViewSize)];
        [self addSubview:_imageView];
        _imageView.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureRecognizerTrick:)];
        [_imageView addGestureRecognizer:panGesture];
    }
    
    return self;
}

- (void)onPanGestureRecognizerTrick:(UIPanGestureRecognizer *)gesture
{
    CGFloat imageSize = self.bounds.size.height;
    CGFloat x = MAX(MIN([gesture locationInView:self].x, self.bounds.size.width-imageSize/2), imageSize/2);
    [self render:x completeCallback:_sliderValueChangeBlock];
}

- (void)render:(CGFloat)x completeCallback:(void(^)(CGFloat value))sliderValueChangeBlock
{
    CGFloat imageSize = self.bounds.size.height;
    CGFloat sliderAvailabelLength = self.bounds.size.width-imageSize;
    CGFloat value = (x-imageSize/2)/sliderAvailabelLength;
    
    _imageView.center = CGPointMake(x, imageSize/2);
    
    _leftLineView.frame = CGRectMake(0, imageSize/2-kCustomSliderHeight/2, _imageView.frame.origin.x-kCustomSliderMargin, kCustomSliderHeight);
    
    _rightLineView.frame = CGRectMake(_imageView.frame.origin.x+imageSize+kCustomSliderMargin, imageSize/2-kCustomSliderHeight/2, self.bounds.size.width-(_imageView.frame.origin.x+imageSize+kCustomSliderMargin), kCustomSliderHeight);
    
    _value = value;
    if (sliderValueChangeBlock) {
        sliderValueChangeBlock(_value);
    }
}

#pragma mark - PublicMethod
- (void)setValue:(CGFloat)value
{
    _value = value;
    CGFloat imageSize = self.bounds.size.height;
    CGFloat sliderAvailabelLength = self.bounds.size.width-imageSize;
    CGFloat x = value*sliderAvailabelLength + imageSize/2;
    [self render:x completeCallback:_sliderValueChangeBlock];
}

- (void)setThumbImage:(UIImage *)image
{
    _imageView.image = image;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor
{
    _rightLineView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor
{
    _leftLineView.backgroundColor = minimumTrackTintColor;
}

- (void)setValue:(CGFloat)value wantCallBack:(BOOL)callback
{
    CGFloat imageSize = self.bounds.size.height;
    CGFloat sliderAvailabelLength = self.bounds.size.width-imageSize;
    CGFloat x = value*sliderAvailabelLength + imageSize/2;
    if (callback) {
        [self render:x completeCallback:_sliderValueChangeBlock];
    }else {
        [self render:x completeCallback:nil];
    }
}

@end
