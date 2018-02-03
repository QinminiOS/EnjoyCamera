//
//  QMBaseImageView.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/28.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMBaseImageView.h"

@interface QMBaseImageView ()
@property (nonatomic, assign) CGSize constraintSize;
@end

@implementation QMBaseImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _constraintSize = frame.size;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    size_t w = CGImageGetWidth(image.CGImage);
    size_t h = CGImageGetHeight(image.CGImage);
    
    CGFloat scaleX = _constraintSize.width/w;
    CGFloat scaleY = _constraintSize.height/h;
    CGFloat scale = MIN(scaleX, scaleY);
    
    CGPoint center = self.center;
    CGRect resizeRect = self.frame;
    resizeRect.size.width = (int)(scale * w + 0.5);
    resizeRect.size.height = (int)(scale * h + 0.5);
    
    self.frame = resizeRect;
    self.center = center;
    
    [super setImage:image];
}

@end
