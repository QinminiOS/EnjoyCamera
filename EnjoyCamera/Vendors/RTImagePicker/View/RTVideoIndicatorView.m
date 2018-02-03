//
//  RTVideoIndicatorView.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTVideoIndicatorView.h"

@implementation RTVideoIndicatorView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Add gradient layer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[
                             (__bridge id)[[UIColor clearColor] CGColor],
                             (__bridge id)[[UIColor blackColor] CGColor]
                             ];
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

@end
