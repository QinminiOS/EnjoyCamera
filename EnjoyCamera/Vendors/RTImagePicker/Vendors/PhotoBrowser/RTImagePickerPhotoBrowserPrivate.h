//
//  RTImagePickerPhotoBrowserPrivate.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/23/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RTImagePickerZoomingScrollView.h"

// Declare private methods of browser
@interface RTImagePickerPhotoBrowser () {
    
    // Data
    NSUInteger _photoCount;
    NSMutableArray *_photos;
    NSMutableArray *_thumbPhotos;
    NSArray *_fixedPhotosArray; // Provided via init
    
    // Views
    UIScrollView *_pagingScrollView;
    
    // Paging & layout
    NSMutableSet *_visiblePages, *_recycledPages;
    NSUInteger _currentPageIndex;
    NSUInteger _previousPageIndex;
    CGRect _previousLayoutBounds;
    NSUInteger _pageIndexBeforeRotation;
    
    // Navigation & controls
    UIToolbar *_toolbar;
    NSTimer *_controlVisibilityTimer;
    UIBarButtonItem *_previousButton, *_nextButton;
    
    // Appearance
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImageLandscapePhone;
    
    // Video
    MPMoviePlayerViewController *_currentVideoPlayerViewController;
    NSUInteger _currentVideoIndex;
    UIActivityIndicatorView *_currentVideoLoadingIndicator;
    
    // Misc
    BOOL _hasBelongedToViewController;
    BOOL _isVCBasedStatusBarAppearance;
    BOOL _statusBarShouldBeHidden;
    BOOL _displayActionButton;
    BOOL _leaveStatusBarAlone;
    BOOL _performingLayout;
    BOOL _rotating;
    BOOL _viewIsActive; // active as in it's in the view heirarchy
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _skipNextPagingScrollViewPositioning;
    BOOL _viewHasAppearedInitially;
    CGPoint _currentGridContentOffset;
    
}

// Properties
@property (nonatomic) UIActivityViewController *activityViewController;

// Layout
- (void)layoutVisiblePages;
- (void)performLayout;
- (BOOL)presentingViewControllerPrefersStatusBarHidden;

// Nav Bar Appearance
- (void)setNavBarAppearance:(BOOL)animated;
- (void)storePreviousNavBarAppearance;
- (void)restorePreviousNavBarAppearance:(BOOL)animated;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (RTImagePickerZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (RTImagePickerZoomingScrollView *)pageDisplayingPhoto:(id<RTImagePickerPhoto>)photo;
- (RTImagePickerZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(RTImagePickerZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)frameForSelectedButton:(UIButton *)selectedButton atIndex:(NSUInteger)index;

// Navigation
- (void)updateNavigation;
- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

// Controls
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
- (void)toggleControls;
- (BOOL)areControlsHidden;

// Data
- (NSUInteger)numberOfPhotos;
- (id<RTImagePickerPhoto>)photoAtIndex:(NSUInteger)index;
- (id<RTImagePickerPhoto>)thumbPhotoAtIndex:(NSUInteger)index;
- (UIImage *)imageForPhoto:(id<RTImagePickerPhoto>)photo;
- (BOOL)photoIsSelectedAtIndex:(NSUInteger)index;
- (void)setPhotoSelected:(BOOL)selected atIndex:(NSUInteger)index;
- (void)loadAdjacentPhotosIfNecessary:(id<RTImagePickerPhoto>)photo;
- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent;

@end


