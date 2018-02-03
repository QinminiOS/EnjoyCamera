//
//  QMThemeListView.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/5.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMFilterThemeView.h"
#import "QMFilterThemeViewCell.h"
#import "QMFilterThemeSilder.h"
#import <UIImageView+WebCache.h>

#define kFilterThemeCollectionViewCellID @"FilterThemeCollectionViewCellID"

@interface QMFilterThemeView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *lastSelectIndexPath;
@property (nonatomic, strong) QMFilterThemeSilder *sliderThemeView;
@end

@implementation QMFilterThemeView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildCollectionView];
        [self setTitle:@"滤镜"];
    }
    return self;
}

- (void)buildCollectionView
{
    // collectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(80, 100);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 20, self.frame.size.width,self.frame.size.height) collectionViewLayout:layout];
    collectionView.backgroundColor = self.contentView.backgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"QMFilterThemeViewCell" bundle:nil] forCellWithReuseIdentifier:kFilterThemeCollectionViewCellID];
    [self.contentView addSubview:collectionView];
    _collectionView = collectionView;
}

#pragma mark - PublicMethod
- (void)reloadData
{
    [_collectionView reloadData];
}

#pragma mark - PrivateMethod
- (QMFilterThemeSilder *)sliderThemeView
{
    if (!_sliderThemeView) {
        _sliderThemeView = [[QMFilterThemeSilder alloc] init];
        __weak typeof(self) wself = self;
        [_sliderThemeView setSliderValueChangeBlock:^(NSInteger index, float value) {
            if (wself.sliderValueChangeBlock) {
                wself.filterModels[wself.lastSelectIndexPath.row].currentAlphaValue = value;
                wself.sliderValueChangeBlock(index, value);
            }
        }];
        [self.superview addSubview:_sliderThemeView];
    }
    
    return _sliderThemeView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _filterModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QMFilterThemeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFilterThemeCollectionViewCellID forIndexPath:indexPath];
    QMFilterModel *model = _filterModels[indexPath.row];
    cell.label.text = model.name;
    [cell.imageView sd_setImageWithURL:[NSURL fileURLWithPath:model.icon]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *lastSelectCell = [collectionView cellForItemAtIndexPath:self.lastSelectIndexPath];
    [lastSelectCell setSelected:NO];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:YES];
    
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if (self.lastSelectIndexPath == indexPath) {
        float value = self.filterModels[self.lastSelectIndexPath.row].currentAlphaValue;
        [self.sliderThemeView showWithValue:value];
    }else {
        if (self.filterClickBlock) {
            self.filterClickBlock(_filterModels[indexPath.row]);
        }
    }
    
    _lastSelectIndexPath = indexPath;
}

@end
