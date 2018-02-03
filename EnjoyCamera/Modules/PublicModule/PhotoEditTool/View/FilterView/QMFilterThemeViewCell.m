//
//  QMFilterThemeViewCell.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/8/22.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMFilterThemeViewCell.h"

@implementation QMFilterThemeViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor blackColor]];
    self.maskView.backgroundColor = [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:0.7f];
    self.label.backgroundColor = [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:0.6f];
    self.maskView.hidden = YES;
    self.imageView.alpha = 0.8f;
}

- (void)setSelected:(BOOL)selected
{
    self.maskView.hidden = !selected;
}

@end
