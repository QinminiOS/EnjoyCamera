//
//  SuspensionView.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/9.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMSuspensionView.h"

#define kSuspensionCollectionViewCellID           @"SuspensionCollectionViewCellID"
#define kSuspensionCollectionImageViewTag         123
#define kCameraRatioSuspensionViewMargin          11
#define kSuspensionIndicatorViewHeight            10

@interface QMSuspensionView() <UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation QMSuspensionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
        [self buildCollectionView];
    }
    return self;
}

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.frame.size.height-20,self.frame.size.height-20);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    return layout;
}

- (void)buildCollectionView
{
    // collectionView
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width-20,self.frame.size.height) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kSuspensionCollectionViewCellID];
    [self addSubview:collectionView];
    _collectionView = collectionView;
}

#pragma mark - PublicMethod
- (void)reloadData
{
    [_collectionView reloadData];
}

- (void)toggleBelowInView:(UIView *)view
{
    if (!self.superview) {
        [self showBelowInView:view];
    }else {
        self.hidden = !self.hidden;
    }
}

- (void)showBelowInView:(UIView *)view
{
    if (self.superview) {
        return;
    }
    
    self.hidden = NO;
    CGFloat x = view.center.x;
    CGFloat y = view.frame.origin.y + view.frame.size.height + kCameraRatioSuspensionViewMargin;
    CGRect originRect = self.frame;
    originRect.origin.y = y;
    self.frame = originRect;
    [view.superview addSubview:self];
    
    UIView *indicatorView = [self indicatorViewWithPosition:CGPointMake(x, y)];
    [indicatorView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
    [self addSubview:indicatorView];
}

- (BOOL)hide
{
    if (self.isHidden) {
        return NO;
    }else {
        self.hidden = YES;
        return YES;
    }
}

- (UIView *)indicatorViewWithPosition:(CGPoint)point
{
    CGFloat x = point.x - self.frame.origin.x;
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(x-(kSuspensionIndicatorViewHeight+5)/2, -kSuspensionIndicatorViewHeight, kSuspensionIndicatorViewHeight+5, kSuspensionIndicatorViewHeight)];
    indicator.backgroundColor = [UIColor orangeColor];
    CGSize size = indicator.frame.size;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, size.width, size.height);
    CGPathAddLineToPoint(path, NULL, size.width/2, 0.0);
    CGPathAddLineToPoint(path, NULL, 0.0, size.height);
    CGPathCloseSubpath(path);
    [shapeLayer setPath:path];
    CFRelease(path);
    
    indicator.layer.mask = shapeLayer;
    
    return indicator;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _suspensionModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSuspensionCollectionViewCellID forIndexPath:indexPath];
    UIImageView *imageView = [cell.contentView viewWithTag:kSuspensionCollectionImageViewTag];
    if (!imageView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = kSuspensionCollectionImageViewTag;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
    }
    QMSuspensionModel *model = _suspensionModels[indexPath.row];
    imageView.image = [UIImage imageNamed:model.icon];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QMSuspensionModel *model = _suspensionModels[indexPath.row];
    if (_suspensionItemClickBlock) {
        _suspensionItemClickBlock(model);
    }
}

@end

///////////// QMSuspensionModel //////////////
@implementation QMSuspensionModel
+ (NSArray<QMSuspensionModel *> *)buildSuspensionModelsWithJson:(NSString *)jsonStr
{
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    if (!array) {
        return nil;
    }
    
    NSMutableArray *cropsArr = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        QMSuspensionModel *model = [QMSuspensionModel yy_modelWithDictionary:dict];
        if (model) {
            [cropsArr addObject:model];
        }
    }
    return cropsArr;
}

+ (NSArray<QMSuspensionModel *> *)buildSuspensionModelsWithConfig:(NSString *)path
{
    NSData *jsonConfig = [NSData dataWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonConfig options:NSJSONReadingMutableContainers error:nil];
    if (!array) {
        return nil;
    }
    
    NSMutableArray *cropsArr = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        QMSuspensionModel *model = [QMSuspensionModel yy_modelWithDictionary:dict];
        if (model) {
            [cropsArr addObject:model];
        }
    }
    return cropsArr;
}
@end

