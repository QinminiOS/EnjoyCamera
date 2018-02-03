//
//  QMCropThemeView.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/5.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMCropThemeView.h"
#import "QMCropThemeViewCell.h"
#import "QMCropModel.h"

#define kCropThemeCollectionViewCellID @"CropThemeCollectionViewCellID"

@interface QMCropThemeView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation QMCropThemeView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildCollectionView];
        [self setTitle:@"裁剪"];
        [self setCropData];
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
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 20, self.frame.size.width-20,self.frame.size.height) collectionViewLayout:layout];
    collectionView.backgroundColor = self.contentView.backgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"QMCropThemeViewCell" bundle:nil] forCellWithReuseIdentifier:kCropThemeCollectionViewCellID];
    [self.contentView addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)setCropData
{
    _cropModels = [QMCropModel buildCropModels];
    [self reloadData];
}

#pragma mark - PublicMethod
- (void)reloadData
{
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _cropModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QMCropThemeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCropThemeCollectionViewCellID forIndexPath:indexPath];
    QMCropModel *model = _cropModels[indexPath.row];
    cell.label.text = model.name;
    cell.imageView.image = [UIImage imageNamed:model.icon];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    QMCropModel *model = _cropModels[indexPath.row];
    if (self.croperClickBlock) {
        CGSize size = CGSizeZero;
        CGFloat rotation = 0;
        switch (model.type) {
            case QMRatioTypeNone:
                size = CGSizeMake(0.0f, 1.0f);
                break;
            case QMRatioType11:
                size = CGSizeMake(1.0f, 1.0f);
                break;
            case QMRatioType32:
                size = CGSizeMake(3.0f, 2.0f);
                break;
            case QMRatioType43:
                size = CGSizeMake(4.0f, 3.0f);
                break;
            case QMRatioType54:
                size = CGSizeMake(5.0f, 4.0f);
                break;
            case QMRatioType75:
                size = CGSizeMake(7.0f, 5.0f);
                break;
            case QMRatioType169:
                size = CGSizeMake(16.0f, 9.0f);
                break;
            case QMRatioTypeFree:
                size = CGSizeMake(0.0f, 1.0f);
                break;
            case QMRatioTypeRotate:
                rotation = M_PI_2;
                break;
                
            default:
                break;
        }
        self.croperClickBlock(size, rotation);
    }
}

@end
