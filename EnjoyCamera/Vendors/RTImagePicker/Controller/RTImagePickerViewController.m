//
//  RTImagePickerViewController.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTImagePickerViewController.h"

// ViewControllers
#import "RTAssetCollectionViewController.h"
#import "RTImagePickerNavigationController.h"

@interface RTImagePickerViewController ()

@property (nonatomic, strong) RTImagePickerNavigationController *assetNavigationController;

@property (nonatomic, strong) NSBundle *assetBundle;

@end

@implementation RTImagePickerViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // Set default values
        
        self.assetCollectionSubtypes = @[
                                         @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                         @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
                                         @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                         @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                         @(PHAssetCollectionSubtypeSmartAlbumBursts)
                                         ];
        self.minimumNumberOfSelection = 1;
        self.numberOfColumnsInPortrait = 3;
        self.numberOfColumnsInLandscape = 7;
        
        _selectedAssets = [NSMutableOrderedSet orderedSet];
        
        // Get asset bundle
        self.assetBundle = [NSBundle bundleForClass:[self class]];
        NSString *bundlePath = [self.assetBundle pathForResource:@"RTImagePicker" ofType:@"bundle"];
        if (bundlePath) {
            self.assetBundle = [NSBundle bundleWithPath:bundlePath];
        }
        
        [self setUpAlbumsViewController];
        
        // Set instance
        RTAssetCollectionViewController *albumsViewController = (RTAssetCollectionViewController *)self.assetNavigationController.topViewController;
        albumsViewController.imagePickerController = self;
    }
    
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)setUpAlbumsViewController
{
    // Add QBAlbumsViewController as a child
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"RTImagePicker" bundle:self.assetBundle];
    RTImagePickerNavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"RTAssetNavigationController"];
    
    [self addChildViewController:navigationController];
    
    navigationController.view.frame = self.view.bounds;
    [self.view addSubview:navigationController.view];
    
    [navigationController didMoveToParentViewController:self];
    
    self.assetNavigationController = navigationController;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

@end
