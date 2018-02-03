//
//  QMCameraFilterView.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/11.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMCameraFilterView.h"
#import <UIImageView+WebCache.h>
#import "Constants.h"
#import <Masonry.h>

#define kCameraFilterCollectionViewCellID         @"CameraFilterCollectionViewCellID"
#define kCameraFilterCollectionImageViewTag       100
#define kCameraFilterCollectionLabelTag           101
#define kCameraFilterCollectionMaskViewTag        102

#define kCameraFilterViewHeight                   (kScreenH-kScreenW*4.0f/3.0f)
#define kCameraFilterViewItemSize                 60
#define kCameraFilterCollectionViewHeight         100

@interface QMCameraFilterView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSArray<QMFilterModel *> *filterModels;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *sliderLabel;
@end

@implementation QMCameraFilterView

+ (instancetype)cameraFilterView
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect rect = CGRectMake(0, size.height, size.width, kCameraFilterViewHeight);
    QMCameraFilterView *view = [[QMCameraFilterView alloc] initWithFrame:rect];
    view.filterModels = [QMFilterModel buildFilterModelsWithPath:kFilterPath];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setHidden:YES];
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f]];
        [self buildCollectionView];
    }
    return self;
}

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kCameraFilterViewItemSize, kCameraFilterViewItemSize);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    return layout;
}

- (void)buildCollectionView
{
    // collectionView
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, kCameraFilterCollectionViewHeight) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCameraFilterCollectionViewCellID];
    [self addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)toggleSliderView
{
    if (!self.slider) {
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(30, self.frame.origin.y-45, kScreenW-60, 30)];
        self.slider.hidden = YES;
        self.slider.tintColor = [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:1.0];
        self.slider.maximumTrackTintColor = [UIColor whiteColor];
        [self.superview addSubview:self.slider];
        
        self.sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.slider.frame.origin.x+self.slider.value*(kScreenW-90)-8, self.slider.frame.origin.y-30, 40, 30)];
        self.sliderLabel.textAlignment = NSTextAlignmentCenter;
        self.sliderLabel.font = [UIFont systemFontOfSize:22];
        self.sliderLabel.textColor = [UIColor whiteColor];
        self.sliderLabel.text = [NSString stringWithFormat:@"%.0f", floor(self.slider.value*100)];
        [self.superview addSubview:self.sliderLabel];
        
        weakSelf();
//        [[self.slider rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(__kindof UIControl * _Nullable x) {
//            strongSelf();
//            wself.sliderLabel.frame = CGRectMake(wself.slider.frame.origin.x+wself.slider.value*(kScreenW-90)-8, wself.slider.frame.origin.y-30, 40, 30);
//            wself.sliderLabel.text = [NSString stringWithFormat:@"%.0f", floor(self.slider.value*100)];
//        }];
//        
//        [RACObserve(self.slider, value) subscribeNext:^(id  _Nullable x) {
//            @strongify(self);
//            self.sliderLabel.frame = CGRectMake(self.slider.frame.origin.x+self.slider.value*(kScreenW-90)-8, self.slider.frame.origin.y-30, 40, 30);
//            self.sliderLabel.text = [NSString stringWithFormat:@"%.0f", floor(self.slider.value*100)];
//        }];
//        
//        [[self.slider rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//            @strongify(self);
//            QMFilterModel *model = self.filterModels[self.lastSelectedIndexPath.row];
//            model.currentAlphaValue = self.slider.value;
//            if (self.filterValueDidChangeBlock) {
//                self.filterValueDidChangeBlock(model.currentAlphaValue);
//            }
//        }];
    }
    
    self.slider.alpha = 1.0f;
    self.sliderLabel.alpha = 1.0f;
    self.slider.hidden = !self.slider.hidden;
    self.sliderLabel.hidden = self.slider.hidden;
}

#pragma mark - PublicMethod
- (void)reloadData
{
    [_collectionView reloadData];
}

- (void)toggleInView:(UIView *)view
{
    if (self.hidden) {
        [self showInView:view];
    }else {
        [self hide];
    }
}

- (void)showInView:(UIView *)view
{
    if (!self.superview) {
        [view addSubview:self];
    }
    
    if (!self.hidden) {
        return;
    }
    
    if (_filterWillShowBlock) {
        _filterWillShowBlock();
    }
    self.hidden = NO;
    CGSize size = [UIScreen mainScreen].bounds.size;
    [UIView animateWithDuration:0.4f animations:^{
        self.frame = CGRectMake(0, size.height-kCameraFilterViewHeight, size.width, kCameraFilterViewHeight);
    } completion:^(BOOL finished) {
        [_collectionView scrollToItemAtIndexPath:_lastSelectedIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self selectConllectionViewAtIndex:_lastSelectedIndexPath];
    }];
}

- (BOOL)hide
{
    if (self.hidden) {
        return NO;
    }
    
    if (_filterWillHideBlock) {
        _filterWillHideBlock();
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    [UIView animateWithDuration:0.4f animations:^{
        self.slider.alpha = 0.0f;
        self.sliderLabel.alpha = 0.0f;
        self.frame = CGRectMake(0, size.height, size.width, kCameraFilterViewHeight);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.slider.hidden = YES;
        self.sliderLabel.hidden = self.slider.hidden;
    }];
    
    return YES;
}

- (void)setFilterValue:(CGFloat)value animated:(BOOL)animated
{
    [self.slider setValue:MAX(MIN(value, 1), 0) animated:animated];
    self.slider.value = MAX(MIN(value, 1), 0);
    self.sliderLabel.text = [NSString stringWithFormat:@"%.0f", floor(self.slider.value*100)];
}

- (BOOL)selectFilterAtIndex:(NSInteger)index
{
    if (index < 0) {
        return NO;
    }
    
    index = MAX(MIN(index, _filterModels.count-1), 0);
    if (_filterItemClickBlock) {
        _filterItemClickBlock(_filterModels[index], index);
    }
    
    if (!self.hidden) {
        [self deselectConllectionViewAtIndex:_lastSelectedIndexPath];
        _lastSelectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self selectConllectionViewAtIndex:_lastSelectedIndexPath];
        [_collectionView scrollToItemAtIndexPath:_lastSelectedIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }else {
        [self deselectConllectionViewAtIndex:_lastSelectedIndexPath];
        _lastSelectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    }
    
    return YES;
}

#pragma mark - UICollectionViewSelect
- (void)selectConllectionViewAtIndex:(NSIndexPath *)indexPath
{
    UICollectionViewCell *lastCell = [_collectionView cellForItemAtIndexPath:_lastSelectedIndexPath];
    UIView *lastMaskView = [lastCell viewWithTag:kCameraFilterCollectionMaskViewTag];
    lastMaskView.hidden = NO;
}

- (void)deselectConllectionViewAtIndex:(NSIndexPath *)indexPath
{
    UICollectionViewCell *lastCell = [_collectionView cellForItemAtIndexPath:_lastSelectedIndexPath];
    UIView *lastMaskView = [lastCell viewWithTag:kCameraFilterCollectionMaskViewTag];
    lastMaskView.hidden = YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _filterModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCameraFilterCollectionViewCellID forIndexPath:indexPath];
    UIImageView *imageView = [cell.contentView viewWithTag:kCameraFilterCollectionImageViewTag];
    UILabel *label = [cell.contentView viewWithTag:kCameraFilterCollectionLabelTag];
    UIView *maskView = [cell.contentView viewWithTag:kCameraFilterCollectionMaskViewTag];
    if (!imageView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = kCameraFilterCollectionImageViewTag;
        imageView.contentMode = UIViewContentModeScaleToFill;
        [cell.contentView addSubview:imageView];
    }
    
    if (!label) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, layout.itemSize.height-18, layout.itemSize.width, 18);
        label = [[UILabel alloc] initWithFrame:rect];
        label.tag = kCameraFilterCollectionLabelTag;
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:0.6f];
        [cell.contentView addSubview:label];
    }
    
    if (!maskView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height)];
        maskView.tag = kCameraFilterCollectionMaskViewTag;
        maskView.backgroundColor = [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:0.5f];
        [cell.contentView addSubview:maskView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = [UIImage imageNamed:@"qmkit_filter_adjust"];
        [maskView addSubview:imageView];
    }
    
    cell.layer.cornerRadius = 22.0f;
    cell.layer.masksToBounds = YES;
    
    if (_lastSelectedIndexPath == indexPath) {
        maskView.hidden = NO;
    }else {
        maskView.hidden = YES;
    }
    
    QMFilterModel *model = _filterModels[indexPath.row];
    label.text = model.name;
    [imageView sd_setImageWithURL:[NSURL fileURLWithPath:model.icon]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *lastCell = [collectionView cellForItemAtIndexPath:_lastSelectedIndexPath];
    UIView *lastMaskView = [lastCell viewWithTag:kCameraFilterCollectionMaskViewTag];
    lastMaskView.hidden = YES;
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIView *maskView = [cell viewWithTag:kCameraFilterCollectionMaskViewTag];
    maskView.hidden = NO;
    
    if (_lastSelectedIndexPath == indexPath) {
        [self toggleSliderView];
    }
    
    QMFilterModel *model = _filterModels[indexPath.row];
    [self setFilterValue:model.currentAlphaValue animated:YES];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    if (_filterItemClickBlock) {
        _filterItemClickBlock(model, indexPath.row);
    }
    
    _lastSelectedIndexPath = indexPath;
}

@end
