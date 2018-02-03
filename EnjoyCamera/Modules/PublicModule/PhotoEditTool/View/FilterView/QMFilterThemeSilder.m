//
//  QMFilterThemeSilder.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/5.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMFilterThemeSilder.h"
#import <Masonry.h>

#define kThemeSliderDefaultValue     0.5f
#define kFilterThemeSilderTag        1

@interface QMFilterThemeSilder()
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *sliderLabel;
@end

@implementation QMFilterThemeSilder

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildOneSlider];
        [self setTitle:@"滤镜调节"];
    }
    return self;
}

- (void)buildOneSlider
{
    // UISlider
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
    slider.tintColor = [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:1.0];
    slider.maximumTrackTintColor = [UIColor whiteColor];
    slider.value = kThemeSliderDefaultValue;
    [slider setTag:kFilterThemeSilderTag];
    self.slider = slider;
    [slider addTarget:self action:@selector(sliderTouchEnd:)
                 forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(sliderValueChange:)
                 forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(50);
        make.right.offset(-50);
        make.bottom.offset(-50);
        make.height.mas_equalTo(20);
    }];
    
    // UISliderTextBg
    UIView *sliderLabelBg = [[UIView alloc] initWithFrame:CGRectZero];
    sliderLabelBg.backgroundColor = [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:1.0];
    sliderLabelBg.layer.cornerRadius = 15.0f;
    [self.contentView addSubview:sliderLabelBg];
    [sliderLabelBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(70);
        make.bottom.offset(-80);
        make.height.mas_equalTo(30);
        make.centerX.mas_equalTo(0);
    }];
    
    // UISliderText
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    sliderLabel.textAlignment = NSTextAlignmentCenter;
    sliderLabel.font = [UIFont systemFontOfSize:20];
    sliderLabel.textColor = [UIColor whiteColor];
    sliderLabel.text = [NSString stringWithFormat:@"%.0f", floor(slider.value*100)];
    self.sliderLabel = sliderLabel;
    [self.contentView addSubview:sliderLabel];
    [sliderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.bottom.offset(-80);
        make.height.mas_equalTo(30);
        make.centerX.mas_equalTo(0);
    }];
}

#pragma mark - Events
- (void)sliderValueChange:(UISlider *)slider
{
    self.sliderLabel.text = [NSString stringWithFormat:@"%.0f", floor(slider.value*100)];
}

- (void)sliderTouchEnd:(UISlider *)slider
{
    self.sliderLabel.text = [NSString stringWithFormat:@"%.0f", floor(slider.value*100)];
    if (_sliderValueChangeBlock) {
        _sliderValueChangeBlock(slider.tag, slider.value);
    }
}

#pragma mark - Public
- (void)showWithValue:(float)value
{
    self.slider.value = value;
    self.sliderLabel.text = [NSString stringWithFormat:@"%.0f", floor(self.slider.value*100)];
    [self show];
}

@end
