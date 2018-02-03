//
//  RTAssetCollectionViewController.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTAssetCollectionViewController.h"
#import <Photos/Photos.h>

// Views
#import "RTImagePickerViewController.h"
#import "RTAssetCollectionViewCell.h"
#import "RTVideoIndicatorView.h"
#import "RTAlbumTableViewCell.h"
#import "RTImagePickerTitleButton.h"
#import "RTImagePickerNavigationController.h"
#import "RTImagePickerUnauthorizedView.h"

#import "UIView+Geometry.h"

@interface RTAssetCollectionViewController () <
PHPhotoLibraryChangeObserver,
UICollectionViewDelegateFlowLayout,
UITableViewDataSource,
UITableViewDelegate>
{
    RTImagePickerTitleButton *titleButton;
    CGFloat albumListAnimateDuration;
    BOOL hasAuthorized;
}

@property (nonatomic, strong) PHFetchResult         *fetchResult;

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) CGRect                previousPreheatRect;

@property (nonatomic, assign) BOOL                  disableScrollToBottom;
@property (nonatomic, strong) NSIndexPath           *lastSelectedItemIndexPath;

@property (nonatomic, copy) NSArray                 *fetchResults;
@property (nonatomic, copy) NSArray                 *assetCollections;

@property (nonatomic, strong) UITableView           *albumsTableView;

@property (nonatomic, strong) RTImagePickerToolbarView                *toolBarView;
@property (weak, nonatomic) IBOutlet UIView *titleView;

@property (nonatomic, strong) RTImagePickerUnauthorizedView *unAuthorizedView;
@end

@implementation RTAssetCollectionViewController

static NSString * const reuseIdentifier = @"AssetCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    albumListAnimateDuration = 0.3f;
    hasAuthorized = NO;
    
    switch ([PHPhotoLibrary authorizationStatus]) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if(status == PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        hasAuthorized = YES;
                        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
                        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
                        self.fetchResults = @[smartAlbums, userAlbums];
                        
                        titleButton = [[RTImagePickerTitleButton alloc]initWithFrame:_titleView.bounds];
                        [titleButton addTarget:self action:@selector(titleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [self.titleView addSubview:titleButton];
                        
                        [self updateAssetCollections];
                        [self resetCachedAssets];
                        
                        [titleButton rt_setTitle:self.assetCollection.localizedTitle arrowAppearance:YES];
                        
                        // Configure collection view
                        self.collectionView.allowsMultipleSelection = self.imagePickerController.allowsMultipleSelection;
                        
                        [self.collectionView reloadData];
                        
                        // Scroll to bottom
                        [self scrollToBottomAnimated:NO];
                    });
                } else {
                    [self UnAuthorizedViewHidden:NO];
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized:
        {
            hasAuthorized = YES;
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
            PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
            self.fetchResults = @[smartAlbums, userAlbums];
            
            titleButton = [[RTImagePickerTitleButton alloc]initWithFrame:_titleView.bounds];
            [titleButton addTarget:self action:@selector(titleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.titleView addSubview:titleButton];
            
            [self updateAssetCollections];
            [self resetCachedAssets];
            
        }
            break;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
        {
            [self UnAuthorizedViewHidden:NO];
        }
            break;
    }
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self setupToolBarView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure navigation item
    [titleButton rt_setTitle:self.assetCollection.localizedTitle arrowAppearance:YES];
    
    // Configure collection view
    self.collectionView.allowsMultipleSelection = self.imagePickerController.allowsMultipleSelection;
    self.collectionView.userInteractionEnabled = YES;

    [self.collectionView reloadData];
    
    // Scroll to bottom
    [self scrollToBottomAnimated:NO];
    
    if(self.toolBarView) {
        [self.toolBarView SwitchToMode:RTImagePickerToolbarModeImagePicker];
    }
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    if(self.fetchResult) {
        if (self.fetchResult.count > 0 && !self.disableScrollToBottom) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.fetchResult.count - 1) inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.disableScrollToBottom = YES;
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.disableScrollToBottom = NO;
    
    [self updateCachedAssets];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Save indexPath for the last item
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    
    // Update layout
    [self.collectionViewLayout invalidateLayout];
    
    // Restore scroll position
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }];
}

- (void)dealloc
{
    // Deregister observer
//    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Accessors

- (void)setAssetCollection:(PHAssetCollection *)assetCollection
{
    _assetCollection = assetCollection;
    
    [self updateFetchRequest];
    [self.collectionView reloadData];
}

- (PHCachingImageManager *)imageManager
{
    if (_imageManager == nil) {
        _imageManager = [PHCachingImageManager new];
    }
    
    return _imageManager;
}

- (BOOL)isAutoDeselectEnabled
{
    return (self.imagePickerController.maximumNumberOfSelection == 1
            && self.imagePickerController.maximumNumberOfSelection >= self.imagePickerController.minimumNumberOfSelection);
}

#pragma mark - Toolbar

- (void)setupToolBarView
{
    if(!self.toolBarView) {
        self.toolBarView = [[RTImagePickerToolbarView alloc] initWithFrame:CGRectMake(0.0f, ScreenHeight - 150.0f, ScreenWidth, 150.0f)];
        _toolBarView.viewController = self;
        [(RTImagePickerNavigationController *)self.navigationController setupToolBarView:_toolBarView];
    }
}

#pragma mark - Fetching Assets

- (void)updateFetchRequest
{
    if (!hasAuthorized) { return; }
    
    if (self.assetCollection) {
        PHFetchOptions *options = [PHFetchOptions new];
        
        switch (self.imagePickerController.mediaType) {
            case RTImagePickerMediaTypeImage:
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                break;
                
            case RTImagePickerMediaTypeVideo:
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
                break;
                
            default:
                break;
        }
        
        self.fetchResult = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
        
        if ([self isAutoDeselectEnabled] && self.imagePickerController.selectedAssets.count > 0) {
            // Get index of previous selected asset
            PHAsset *asset = [self.imagePickerController.selectedAssets firstObject];
            NSInteger assetIndex = [self.fetchResult indexOfObject:asset];
            self.lastSelectedItemIndexPath = [NSIndexPath indexPathForItem:assetIndex inSection:0];
        }
    } else {
        self.fetchResult = nil;
    }
}

#pragma mark - Checking for Selection Limit

- (BOOL)isMinimumSelectionLimitFulfilled
{
    return (self.imagePickerController.minimumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
}

- (BOOL)isMaximumSelectionLimitReached
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.imagePickerController.minimumNumberOfSelection);
    
    if (minimumNumberOfSelection <= self.imagePickerController.maximumNumberOfSelection) {
        return (self.imagePickerController.maximumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
    }
    
    return NO;
}

#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && self.view.window != nil;
    if (!isViewVisible) { return; }
    
    if (!hasAuthorized) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    
    if (delta > self.collectionView.height / 3.0) {
        // Compute the assets to start caching and to stop caching
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [RTImagePickerUtils computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView rt_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        } removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView rt_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        CGSize itemSize = [(UICollectionViewFlowLayout *)self.collectionViewLayout itemSize];
        CGSize targetSize = CGSizeScale(itemSize, [[UIScreen mainScreen] scale]);
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:targetSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:targetSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item < self.fetchResult.count) {
            PHAsset *asset = self.fetchResult[indexPath.item];
            [assets addObject:asset];
        }
    }
    return assets;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update fetch results
        NSMutableArray *fetchResults = [self.fetchResults mutableCopy];
        
        [self.fetchResults enumerateObjectsUsingBlock:^(PHFetchResult *fetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:fetchResult];
                      
            if (changeDetails) {
                [fetchResults replaceObjectAtIndex:index withObject:changeDetails.fetchResultAfterChanges];
            }
        }];
        
        if (![self.fetchResults isEqualToArray:fetchResults]) {
            self.fetchResults = fetchResults;
            
            // Reload albums
            [self updateAssetCollections];
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *array = [NSMutableArray array];
        for(PHAsset *asset in self.imagePickerController.selectedAssets) {
            PHObjectChangeDetails *detail = [changeInstance changeDetailsForObject:asset];
            if(detail.assetContentChanged || detail.objectWasDeleted) {
                [array addObject:asset];
            }
        }
        
        for(PHAsset *asset in array) {
            [self.toolBarView deleteAsset:asset];
        }
        
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.fetchResult];
        
        if (collectionChanges) {
            // Get the new fetch result
            self.fetchResult = [collectionChanges fetchResultAfterChanges];
            [self.collectionView reloadData];
            
            [self resetCachedAssets];
        }
    });
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.fetchResult) {
        return self.fetchResult.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RTAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    cell.tag = indexPath.item;
    cell.showsOverlayViewWhenSelected = self.imagePickerController.allowsMultipleSelection;
    
    // Image
    PHAsset *asset = self.fetchResult[indexPath.item];
    CGSize itemSize = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize];
    CGSize targetSize = CGSizeScale(itemSize, [[UIScreen mainScreen] scale]);
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  if (cell.tag == indexPath.item) {
                                      cell.imageView.image = result;
                                  }
                              }];
    
    // Video indicator
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.videoIndicatorView.hidden = NO;
        
        NSInteger minutes = (NSInteger)(asset.duration / 60.0);
        NSInteger seconds = (NSInteger)ceil(asset.duration - 60.0 * (double)minutes);
        cell.videoIndicatorView.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
        
        if (asset.mediaSubtypes & PHAssetMediaSubtypeVideoHighFrameRate) {
            cell.videoIndicatorView.videoIcon.hidden = YES;
        }
        else {
            cell.videoIndicatorView.videoIcon.hidden = NO;
        }
    } else {
        cell.videoIndicatorView.hidden = YES;
    }
    
    // Selection state
    if ([self.imagePickerController.selectedAssets containsObject:asset]) {
        [cell setSelected:YES];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.imagePickerController.delegate respondsToSelector:@selector(rt_imagePickerController:shouldSelectAsset:)]) {
        PHAsset *asset = self.fetchResult[indexPath.item];
        return [self.imagePickerController.delegate rt_imagePickerController:self.imagePickerController shouldSelectAsset:asset];
    }
    
    if ([self isAutoDeselectEnabled]) {
        return YES;
    }
    
    BOOL flag = [self isMaximumSelectionLimitReached];
    
    if(flag) {
        [self.toolBarView shakePreviewScrollView];
    }
    
    return !flag;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RTImagePickerViewController *imagePickerController = self.imagePickerController;
    NSMutableOrderedSet *selectedAssets = imagePickerController.selectedAssets;
    
    PHAsset *asset = self.fetchResult[indexPath.item];
    
    if (imagePickerController.allowsMultipleSelection) {
        if ([self isAutoDeselectEnabled] && selectedAssets.count > 0) {
            // Remove previous selected asset from set
            [selectedAssets removeObjectAtIndex:0];
            
            // Deselect previous selected asset
            if (self.lastSelectedItemIndexPath) {
                [collectionView deselectItemAtIndexPath:self.lastSelectedItemIndexPath animated:NO];
            }
        }
        
        // Add asset to set
        [selectedAssets addObject:asset];
        [self.toolBarView addAsset:asset];
        
        self.lastSelectedItemIndexPath = indexPath;
    } else {
        if ([imagePickerController.delegate respondsToSelector:@selector(rt_imagePickerController:didFinishPickingAssets:)]) {
            [imagePickerController.delegate rt_imagePickerController:imagePickerController didFinishPickingAssets:@[asset]];
        }
    }
    
    if ([imagePickerController.delegate respondsToSelector:@selector(rt_imagePickerController:didSelectAsset:)]) {
        [imagePickerController.delegate rt_imagePickerController:imagePickerController didSelectAsset:asset];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.imagePickerController.allowsMultipleSelection) {
        return;
    }
    
    RTImagePickerViewController *imagePickerController = self.imagePickerController;
    NSMutableOrderedSet *selectedAssets = imagePickerController.selectedAssets;
    
    PHAsset *asset = self.fetchResult[indexPath.item];
    
    // Remove asset from set
    [selectedAssets removeObject:asset];
    [self.toolBarView deleteAsset:asset];
    
    self.lastSelectedItemIndexPath = nil;

    if ([imagePickerController.delegate respondsToSelector:@selector(rt_imagePickerController:didDeselectAsset:)]) {
        [imagePickerController.delegate rt_imagePickerController:imagePickerController didDeselectAsset:asset];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:@"FooterView"
                                                                                         forIndexPath:indexPath];
        
        return footerView;
    }
    return nil;
}
#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfColumns = self.imagePickerController.numberOfColumnsInPortrait;
    
    CGFloat width = (self.view.width - 2.0 * (numberOfColumns - 1)) / numberOfColumns;
    
    return CGSizeMake(width, width);
}

- (void)updateAssetCollections
{
    // Filter albums
    NSArray *assetCollectionSubtypes = self.imagePickerController.assetCollectionSubtypes;
    NSMutableDictionary *smartAlbums = [NSMutableDictionary dictionaryWithCapacity:assetCollectionSubtypes.count];
    NSMutableArray *userAlbums = [NSMutableArray array];
    
    for (PHFetchResult *fetchResult in self.fetchResults) {
        [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
            PHAssetCollectionSubtype subtype = assetCollection.assetCollectionSubtype;
            
            if (subtype == PHAssetCollectionSubtypeAlbumRegular) {
                [userAlbums addObject:assetCollection];
            } else if ([assetCollectionSubtypes containsObject:@(subtype)]) {
                if (!smartAlbums[@(subtype)]) {
                    smartAlbums[@(subtype)] = [NSMutableArray array];
                }
                [smartAlbums[@(subtype)] addObject:assetCollection];
            }
        }];
    }
    
    NSMutableArray *assetCollections = [NSMutableArray array];
    
    // Fetch smart albums
    for (NSNumber *assetCollectionSubtype in assetCollectionSubtypes) {
        NSArray *collections = smartAlbums[assetCollectionSubtype];
        
        if (collections) {
            [assetCollections addObjectsFromArray:collections];
        }
    }
    
    // Fetch user albums
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
        [assetCollections addObject:assetCollection];
    }];
    
    self.assetCollections = assetCollections;
    self.assetCollection = (PHAssetCollection *)self.assetCollections[0];
    
    [titleButton rt_setTitle:[NSString stringWithFormat:@"%@",self.assetCollection.localizedTitle] arrowAppearance:YES];
    
    if(!self.albumsTableView) {
        self.albumsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, -ScreenHeight, ScreenWidth, ScreenHeight - self.navigationController.navigationBar.height) style:UITableViewStylePlain];
        _albumsTableView.delegate = self;
        _albumsTableView.dataSource = self;
        _albumsTableView.backgroundColor = [UIColor blackColor];
        _albumsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self.view addSubview:_albumsTableView];
    }
    [self.collectionView reloadData];
}

- (void)titleButtonPressed:(id)sender {
    if(self.albumsTableView.top < 0.0f) {
        
        [titleButton rt_setTitle:[NSString stringWithFormat:@"相簿"] arrowAppearance:NO];
        
        [UIView animateWithDuration:albumListAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.albumsTableView.top = 0.0f;
            self.toolBarView.top = ScreenHeight;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [titleButton rt_setTitle:[NSString stringWithFormat:@"%@",self.assetCollection.localizedTitle] arrowAppearance:YES];

        [UIView animateWithDuration:albumListAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.albumsTableView.top = -ScreenHeight;
            self.toolBarView.top = ScreenHeight - _toolBarView.height;
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetCollections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.assetCollection = self.assetCollections[self.albumsTableView.indexPathForSelectedRow.row];
    [titleButton rt_setTitle:[NSString stringWithFormat:@"%@",self.assetCollection.localizedTitle] arrowAppearance:YES];
    
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:NO];
    
    if(self.albumsTableView.top >= 0.0f) {
        [UIView animateWithDuration:albumListAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.albumsTableView.top = -ScreenHeight;
            self.toolBarView.top = ScreenHeight - _toolBarView.height;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RTAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell"];
    if(!cell)
    {
        cell = [[RTAlbumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AlbumCell"];
    }
    
    cell.tag = indexPath.row;
    
    // Thumbnail
    PHAssetCollection *assetCollection = self.assetCollections[indexPath.row];
    
    PHFetchOptions *options = [PHFetchOptions new];
    
    switch (self.imagePickerController.mediaType) {
        case RTImagePickerMediaTypeImage:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            break;
            
        case RTImagePickerMediaTypeVideo:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            break;
            
        default:
            break;
    }
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    if (fetchResult.count >= 4) {
        cell.imageView4.hidden = NO;
        
        [imageManager requestImageForAsset:fetchResult[fetchResult.count - 4]
                                targetSize:CGSizeScale(CGSizeMake(50.0f,50.0f), [[UIScreen mainScreen] scale])
                               contentMode:PHImageContentModeAspectFill
                                   options:nil
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 if (cell.tag == indexPath.row) {
                                     cell.imageView4.image = result;
                                 }
                             }];
    } else {
        cell.imageView4.hidden = YES;
    }
    
    if (fetchResult.count >= 3) {
        cell.imageView3.hidden = NO;
        
        [imageManager requestImageForAsset:fetchResult[fetchResult.count - 3]
                                targetSize:CGSizeScale(CGSizeMake(60.0f,60.0f), [[UIScreen mainScreen] scale])
                               contentMode:PHImageContentModeAspectFill
                                   options:nil
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 if (cell.tag == indexPath.row) {
                                     cell.imageView3.image = result;
                                 }
                             }];
    } else {
        cell.imageView3.hidden = YES;
    }
    
    if (fetchResult.count >= 2) {
        cell.imageView2.hidden = NO;
        
        [imageManager requestImageForAsset:fetchResult[fetchResult.count - 2]
                                targetSize:CGSizeScale(CGSizeMake(70.0f,70.0f), [[UIScreen mainScreen] scale])
                               contentMode:PHImageContentModeAspectFill
                                   options:nil
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 if (cell.tag == indexPath.row) {
                                     cell.imageView2.image = result;
                                 }
                             }];
    } else {
        cell.imageView2.hidden = YES;
    }
    
    if (fetchResult.count >= 1) {
        [imageManager requestImageForAsset:fetchResult[fetchResult.count - 1]
                                targetSize:CGSizeScale(CGSizeMake(80.0f,80.0f), [[UIScreen mainScreen] scale])
                               contentMode:PHImageContentModeAspectFill
                                   options:nil
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 if (cell.tag == indexPath.row) {
                                     cell.imageView1.image = result;
                                 }
                             }];
    }
    
    if (fetchResult.count == 0) {
        cell.imageView3.hidden = YES;
        cell.imageView2.hidden = YES;
        cell.imageView4.hidden = YES;
        
        // Set placeholder image
        UIImage *placeholderImage = [RTImagePickerUtils placeholderImageWithSize:CGSizeMake(80.0f,80.0f)];
        cell.imageView1.image = placeholderImage;
    }
    
    // Album title
    cell.titleLabel.text = assetCollection.localizedTitle;
    
    // Number of photos
    cell.countLabel.text = [NSString stringWithFormat:@"%lu", (long)fetchResult.count];
    
    return cell;
}

- (void)UnAuthorizedViewHidden:(BOOL)hidden
{
    if(!self.unAuthorizedView) {
        self.unAuthorizedView = [[RTImagePickerUnauthorizedView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, ScreenWidth, ScreenHeight - self.toolBarView.height)];
        _unAuthorizedView.permissionTitleLabel.text = @"Flow想开启你的相册";
        _unAuthorizedView.onPermissionButton = ^(){
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        };
        _unAuthorizedView.alpha = 0.0f;
        _unAuthorizedView.hidden = YES;
        [self.view addSubview:_unAuthorizedView];
    }
    
    if(hidden) {
        _unAuthorizedView.hidden = NO;
        [UIView animateWithDuration:0.4f animations:^{
            _unAuthorizedView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _unAuthorizedView.hidden = YES;
        }];
    } else {
        _unAuthorizedView.hidden = YES;
        [UIView animateWithDuration:0.4f animations:^{
            _unAuthorizedView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            _unAuthorizedView.hidden = NO;
        }];
    }
}
@end
