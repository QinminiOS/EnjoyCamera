//
//  RTImagePickerPhotoBrowser.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/23/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTImagePickerPhoto.h"
#import "RTImagePickerPhotoProtocol.h"
#import "UIView+Geometry.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define MWLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MWLog(x, ...)
#endif


@class RTImagePickerPhotoBrowser;

@protocol RTImagePickerPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser;
- (id <RTImagePickerPhoto>)photoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (id <RTImagePickerPhoto>)photoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(RTImagePickerPhotoBrowser *)photoBrowser;
- (void)photoBrowserDidChangeHidden:(RTImagePickerPhotoBrowser *)photoBrowser State:(BOOL)state;

@end

@interface RTImagePickerPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet id<RTImagePickerPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL displayNavArrows;
@property (nonatomic) BOOL displaySelectionButtons;
@property (nonatomic) BOOL alwaysShowControls;
@property (nonatomic) BOOL autoPlayOnAppear;
@property (nonatomic) NSUInteger delayToHideElements;
@property (nonatomic, readonly) NSUInteger currentIndex;

// Customise image selection icons as they are the only icons with a colour tint
// Icon should be located in the app's main bundle
@property (nonatomic, strong) NSString *customImageSelectedIconName;
@property (nonatomic, strong) NSString *customImageSelectedSmallIconName;

// Init
- (id)initWithPhotos:(NSArray *)photosArray;
- (id)initWithDelegate:(id <RTImagePickerPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end
