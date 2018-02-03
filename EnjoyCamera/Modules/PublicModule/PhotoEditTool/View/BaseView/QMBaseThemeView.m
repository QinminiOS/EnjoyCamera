//
//  QMFilterThemeBaseView.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/5.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMBaseThemeView.h"
#import <Masonry.h>

#define kQMBaseThemeCloseButtonTag      1
#define kQMBaseThemeDoneButtonTag       2

#define kFilterThemeViewDefaultHeight    180
#define kSliderDefaultValue              0.6f

@implementation QMBaseThemeView

- (instancetype)initWithFrame:(CGRect)frame
{
    float height = [UIScreen mainScreen].bounds.size.height;
    float width = [UIScreen mainScreen].bounds.size.width;
    frame = CGRectMake(0, height, width, kFilterThemeViewDefaultHeight);
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor colorWithRed:25/255.0 green:25/255.0f blue:25/255.0f alpha:1.0f]];
        [self setHidden:YES];
        [self buildContentView];
        [self buildToolBar];
    }
    return self;
}

- (void)buildContentView
{
    float width = [UIScreen mainScreen].bounds.size.width;
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, kFilterThemeViewDefaultHeight)];
    _contentView.backgroundColor = self.backgroundColor;
    [self addSubview:_contentView];
}

- (void)buildToolBar
{
    // topBar
    UIView *topBg = [[UIView alloc] initWithFrame:CGRectZero];
    topBg.backgroundColor = [UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:1.0f];
    [self addSubview:topBg];
    [topBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(self);
        make.top.left.mas_equalTo(0);
    }];
    
    // title
    UIView *slideView = [[UIView alloc] initWithFrame:CGRectZero];
    slideView.backgroundColor = [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:1.0];
    [self addSubview:slideView];
    [slideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(100);
        make.top.mas_equalTo(40);
        make.centerX.mas_equalTo(0);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:1.0];
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(200);
        make.top.mas_equalTo(5);
        make.centerX.mas_equalTo(0);
    }];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [closeBtn setImage:[UIImage imageNamed:@"qmkit_bar_close_btn"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTag:kQMBaseThemeCloseButtonTag];
    [self addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(5);
    }];
    
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [okBtn setImage:[UIImage imageNamed:@"qmkit_bar_ok_btn"] forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [okBtn setTag:kQMBaseThemeDoneButtonTag];
    [self addSubview:okBtn];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(5);
    }];
}

#pragma mark - Events
- (void)buttonTapped:(UIButton *)sender
{
    switch (sender.tag) {
        case kQMBaseThemeCloseButtonTag:
            [self hide];
            if (self.closeButtonClickBlock) {
                self.closeButtonClickBlock();
            }
            break;
        case kQMBaseThemeDoneButtonTag:
            [self hide];
            if (self.doneButtonClickBlock) {
                self.doneButtonClickBlock();
            }
            break;
        default:
            break;
    }
}

#pragma mark - PublicMethod
- (void)show
{
    [self setHidden:NO];
    [UIView animateWithDuration:0.4 animations:^{
        float height = [UIScreen mainScreen].bounds.size.height;
        float width = [UIScreen mainScreen].bounds.size.width;
        self.frame = CGRectMake(0, height-kFilterThemeViewDefaultHeight, width, kFilterThemeViewDefaultHeight);
    } completion:NULL];
}

- (void)hide
{
    [UIView animateWithDuration:0.4 animations:^{
        float height = [UIScreen mainScreen].bounds.size.height;
        float width = [UIScreen mainScreen].bounds.size.width;
        self.frame = CGRectMake(0, height, width, kFilterThemeViewDefaultHeight);
    } completion:^(BOOL finished) {
        [self setHidden:YES];
    }];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

@end
