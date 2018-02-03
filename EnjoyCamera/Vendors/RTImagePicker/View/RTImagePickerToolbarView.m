//
//  RTImagePickerToolbarView.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTImagePickerToolbarView.h"
#import "RTImagePickerUtils.h"
#import "RTImagePickerPhotoBrowser.h"
#import "RTCameraViewController.h"
#import "RTShortVideoViewController.h"

@interface RTImagePickerToolbarView() <RTImagePickerPhotoBrowserDelegate>
{
    CGFloat previewImage_width;
    CGFloat previewImage_margin;
    CGFloat previewImage_nextX;
    
    CGFloat button_width;
    CGFloat layoutUpdateAnimateDuration;
    
    RTImagePickerPhotoBrowser *browser;
    RTCameraViewController *camera;
    
    RTImagePickerToolbarMode currentMode;
    
    CGPoint currentCenter;
    CGPoint currentLocation;
    NSInteger currentPanImageViewIndex;
}

@property (nonatomic, strong) NSMutableArray                    *selectedAssets;
@property (nonatomic, strong) NSMutableArray                    *previewImageViewArray;
@property (nonatomic, strong) NSMutableArray                    *previewImageArray;

@property (nonatomic, strong) NSMutableArray                    *previewPhotoArray;

@property (nonatomic, strong) PHCachingImageManager             *imageManager;

/**
 *  Buttons for image picker
 */
@property (nonatomic, strong) UIButton                          *cancelButton;
@property (nonatomic, strong) UIButton                          *cameraButton;
@property (nonatomic, strong) UIButton                          *dvButton;
@property (nonatomic, strong) UIButton                          *sendButton;

/**
 *  Buttons for photo browser
 */
@property (nonatomic, strong) UIButton                          *photoBrowserDeleteButton;
@property (nonatomic, strong) UIButton                          *photoBrowserSendButton;

@end


@implementation RTImagePickerToolbarView

- (instancetype)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectedAssets = [NSMutableArray array];
        self.imageManager = [PHCachingImageManager new];
        self.previewImageViewArray = [NSMutableArray array];
        self.previewImageArray = [NSMutableArray array];
        self.previewPhotoArray = [NSMutableArray array];
        currentMode = RTImagePickerToolbarModeImagePicker;
        currentCenter = CGPointMake(0.0f, 0.0f);
        currentPanImageViewIndex = 0;
        
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    previewImage_margin = 4.0f;
    previewImage_nextX = 0.0f;
    previewImage_width = self.height/2.0f - 4.0f;
    
    CGFloat margin_width = (self.width - 46.0f * 3.0f - 44.0f) /2.0f;
    button_width = 46.0f;
    layoutUpdateAnimateDuration = 0.3f;
    
    self.imagePickerToolbarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ScreenWidth, self.height)];
    _imagePickerToolbarBackgroundView.backgroundColor = [UIColor clearColor];
    [self addSubview:_imagePickerToolbarBackgroundView];
    
    self.previewScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, self.height/2.0f, ScreenWidth, self.height/2.0f)];
    _previewScrollView.showsVerticalScrollIndicator = NO;
    _previewScrollView.backgroundColor = [UIColor blackColor];
    _previewScrollView.layer.masksToBounds = NO;
    [_imagePickerToolbarBackgroundView addSubview:_previewScrollView];
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, self.height/2.0f, ScreenWidth, self.height/2.0f)];
    backgroundView.backgroundColor = [UIColor blackColor];
    [_imagePickerToolbarBackgroundView addSubview:backgroundView];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(22.0f, (backgroundView.height - button_width)/2.0f, button_width, button_width)];
    [_cancelButton setImage:[UIImage imageNamed:@"rtimagepicker_cancel"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:_cancelButton];
    
    self.cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(_cancelButton.right + margin_width, _cancelButton.top, button_width, button_width)];
    [_cameraButton setImage:[UIImage imageNamed:@"rtimagepicker_camera"] forState:UIControlStateNormal];
    [_cameraButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:_cameraButton];
    
    self.dvButton = [[UIButton alloc] initWithFrame:CGRectMake(_cameraButton.right + margin_width, _cancelButton.top, button_width, button_width)];
    [_dvButton setImage:[UIImage imageNamed:@"rtimagepicker_dv"] forState:UIControlStateNormal];
    [_dvButton addTarget:self action:@selector(dvButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:_dvButton];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(_dvButton.right + margin_width, _cancelButton.top, button_width, button_width)];
    _sendButton.hidden = YES;
    [_sendButton setImage:[UIImage imageNamed:@"rtimagepicker_send"] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:_sendButton];
    
    /**
     Photo browser subViews
     */
    self.photoBrowserToolbarBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, self.height, ScreenWidth, self.height/2.0f)];
    _photoBrowserToolbarBackgroundView.backgroundColor = [UIColor blackColor];
    [self addSubview:_photoBrowserToolbarBackgroundView];
    
    self.photoBrowserDeleteButton = [[UIButton alloc] initWithFrame:CGRectMake(22.0f, (_photoBrowserToolbarBackgroundView.height - button_width)/2.0f, button_width, button_width)];
    [_photoBrowserDeleteButton setImage:[UIImage imageNamed:@"rtimagepicker_delete"] forState:UIControlStateNormal];
    [_photoBrowserDeleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_photoBrowserToolbarBackgroundView addSubview:_photoBrowserDeleteButton];
    
    self.photoBrowserSendButton = [[UIButton alloc] initWithFrame:CGRectMake(_photoBrowserToolbarBackgroundView.width - 22.0f - button_width, _photoBrowserDeleteButton.top, button_width, button_width)];
    [_photoBrowserSendButton setImage:[UIImage imageNamed:@"rtimagepicker_send"] forState:UIControlStateNormal];
    [_photoBrowserSendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_photoBrowserToolbarBackgroundView addSubview:_photoBrowserSendButton];

    /**
     Camera subViews
     */
    self.cameraToolBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.height, ScreenWidth, self.height)];
    _cameraToolBarBackgroundView.backgroundColor = [UIColor blackColor];
    [self addSubview:_cameraToolBarBackgroundView];
    
    // In order to decrease the complexity of the structure, I moved the event handler to the camera controller, so that the responder chain would be clearer
    
    CGFloat margin_width_camera = (_cameraToolBarBackgroundView.width - 76.0f - 3 * button_width ) / 2.0f;
    self.cameraCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(38.0f, 14.0f, button_width, button_width)];
    [_cameraCancelButton setImage:[UIImage imageNamed:@"rtimagepicker_cancel"] forState:UIControlStateNormal];
    [_cameraCancelButton addTarget:self action:@selector(cameraCancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraToolBarBackgroundView addSubview:_cameraCancelButton];
    
    self.cameraFlashButton = [[UIButton alloc] initWithFrame:CGRectMake(_cameraCancelButton.right + margin_width_camera, 14.0f, button_width, button_width)];
    [_cameraFlashButton setImage:[UIImage imageNamed:@"rtimagepicker_flash_off"] forState:UIControlStateNormal];
    [_cameraToolBarBackgroundView addSubview:_cameraFlashButton];
    
    self.cameraSwitchButton = [[UIButton alloc] initWithFrame:CGRectMake(_cameraFlashButton.right + margin_width_camera, _cameraFlashButton.top, button_width, button_width)];
    [_cameraSwitchButton setImage:[UIImage imageNamed:@"rtimagepicker_switch"] forState:UIControlStateNormal];
    [_cameraToolBarBackgroundView addSubview:_cameraSwitchButton];
    
    self.cameraSnapButton = [[UIButton alloc]initWithFrame:CGRectMake((_cameraToolBarBackgroundView.width - self.height/2.0f)/2.0f, _cameraSwitchButton.bottom, self.height/2.0f, self.height/2.0f)];
    [_cameraSnapButton setImage:[UIImage imageNamed:@"rtimagepicker_snap"] forState:UIControlStateNormal];
    [_cameraToolBarBackgroundView addSubview:_cameraSnapButton];
}

#pragma mark - Actions

- (void)cameraCancelButtonPressed:(id)sender
{
    if(camera) {
        [camera.navigationController setNavigationBarHidden:NO animated:YES];
        [camera.navigationController popViewControllerAnimated:YES];
    }
}

- (void)cancelButtonPressed:(id)sender
{
    if(self.viewController) {
        if ([self.viewController.imagePickerController.delegate respondsToSelector:@selector(rt_imagePickerControllerDidCancel:)]) {
            [self.viewController.imagePickerController.delegate rt_imagePickerControllerDidCancel:self.viewController.imagePickerController];
        }
    }
}

- (void)dvButtonPressed:(id)sender
{
    // If selecting shooting short videos, the logic must be implemented in the view controller before. So you have to
    // dismiss the current controller here.
    
//    if(self.viewController) {
//        if ([self.viewController.imagePickerController.delegate respondsToSelector:@selector(rt_imagePickerControllerDidSelectShortVideo:)]) {
//            [self.viewController.imagePickerController.delegate rt_imagePickerControllerDidSelectShortVideo:self.viewController.imagePickerController];
//        }
//    }
    
    RTShortVideoViewController *vc = [[RTShortVideoViewController alloc] init];
    [self.viewController.navigationController pushViewController:vc animated:YES];
    
}

- (void)cameraButtonPressed:(id)sender
{
    camera = [[RTCameraViewController alloc]init];
    [self.viewController.navigationController pushViewController:camera animated:YES];
}

- (void)sendButtonPressed:(id)sender
{
    if(currentMode == RTImagePickerToolbarModeImagePicker || currentMode == RTImagePickerToolbarModePhotoBrowser) {
        if(self.viewController) {
            if ([self.viewController.imagePickerController.delegate respondsToSelector:@selector(rt_imagePickerController:didFinishPickingImages:)]) {
                [self.viewController.imagePickerController.delegate rt_imagePickerController:self.viewController.imagePickerController didFinishPickingImages:self.previewImageArray];
            }
        }
    } else if (currentMode == RTImagePickerToolbarModeCameraPreview) {
        if(self.viewController && self.cameraImage) {
            UIImageWriteToSavedPhotosAlbum(self.cameraImage, nil, nil, nil);
            if ([self.viewController.imagePickerController.delegate respondsToSelector:@selector(rt_imagePickerController:didFinishPickingImages:)]) {
                [self.viewController.imagePickerController.delegate rt_imagePickerController:self.viewController.imagePickerController didFinishPickingImages:@[self.cameraImage]];
            }
        }
    }
}

- (void)deleteButtonPressed:(id)sender
{
    if(currentMode == RTImagePickerToolbarModePhotoBrowser) {
        if(browser) {
            NSInteger indexToRemove = browser.currentIndex;

            [self deleteAssetAtIndex:indexToRemove];
            [browser reloadData];
        }
    } else if (currentMode == RTImagePickerToolbarModeCameraPreview) {
        [self.viewController.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Asset updating

- (void)addAsset:(PHAsset *)asset
{
    [self.selectedAssets addObject:asset];
    [self updateLayoutWhenUpdatingAsset];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTap:)];
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imagePan:)];
    UILongPressGestureRecognizer *panGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imagePan:)];

    UIImageView *previewImageView = [[UIImageView alloc]initWithFrame:CGRectMake(previewImage_nextX, 4.0f, previewImage_width, previewImage_width )];
    previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    previewImageView.layer.masksToBounds = YES;
    previewImageView.userInteractionEnabled = YES;
    
    CGSize itemSize = CGSizeMake(ScreenWidth, ScreenHeight);
    
    // If set to default option delivery mode, then the result handler will be called more than once
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    [options setDeliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat];
    self.viewController.collectionView.userInteractionEnabled = NO;
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:itemSize
                                contentMode:PHImageContentModeAspectFill
                                    options:options
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  if(result) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self.previewImageArray addObject:result];
                                          RTImagePickerPhoto *photo = [RTImagePickerPhoto photoWithImage:result];
                                          [self.previewPhotoArray addObject:photo];
                                          previewImageView.image = result;
                                          self.viewController.collectionView.userInteractionEnabled = YES;
                                          
                                          [previewImageView addGestureRecognizer:tapGesture];
                                          [previewImageView addGestureRecognizer:panGesture];
                                          
                                          previewImageView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
                                          previewImageView.alpha = 0.5f;
                                          [self.previewScrollView addSubview:previewImageView];
                                          
                                          CGRect frame = previewImageView.frame;
                                          frame.origin.x += previewImage_width/2.0f;
                                          
                                          [self.previewScrollView scrollRectToVisible:frame animated:YES];
                                          
                                          [UIView animateWithDuration:layoutUpdateAnimateDuration delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                              previewImageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
                                              previewImageView.alpha = 1.0f;
                                          } completion:^(BOOL finished) {
                                          }];
                                          
                                          [self.previewImageViewArray addObject:previewImageView];
                                      });
                                  }
                              }];
    
    previewImage_nextX = previewImage_nextX + previewImage_width + previewImage_margin;
    if(previewImage_nextX > ScreenWidth) {
        [self.previewScrollView setContentSize:CGSizeMake(previewImage_nextX, _previewScrollView.height)];
    }
}

- (void)deleteAsset:(PHAsset *)asset
{
    [self deleteAssetAtIndex:[self.selectedAssets indexOfObject:asset]];
}

- (void)deleteAssetAtIndex:(NSInteger)index
{
    PHAsset *asset = [self.selectedAssets objectAtIndex:index];
    
    [self.selectedAssets removeObjectAtIndex:index];
    
    NSMutableOrderedSet *selectedAssets = self.viewController.imagePickerController.selectedAssets;
    [selectedAssets removeObject:asset];
    
    [self updateLayoutWhenUpdatingAsset];
    
    UIImageView *f = [self.previewImageViewArray objectAtIndex:index];
    [f removeFromSuperview];
    
    previewImage_nextX = previewImage_nextX - previewImage_width - previewImage_margin;
    
    [self.previewImageViewArray removeObjectAtIndex:index];
    [self.previewImageArray removeObjectAtIndex:index];
    [self.previewPhotoArray removeObjectAtIndex:index];

    // release the memory by setting the pointer to nil
    // f = nil;
    
    // Animation for updating all the imageView o nthe right side of the view that was removed
    [UIView animateWithDuration:layoutUpdateAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if(previewImage_nextX > ScreenWidth) {
            [self.previewScrollView setContentSize:CGSizeMake(previewImage_nextX, _previewScrollView.height)];
        } else {
            [self.previewScrollView setContentSize:CGSizeMake(ScreenWidth, _previewScrollView.height)];
        }
        
        for(NSInteger i=0;i<self.previewImageViewArray.count;i++) {
            if (i>=index) {
                UIImageView *imageView = (UIImageView *)[self.previewImageViewArray objectAtIndex:i];
                imageView.left = imageView.left - previewImage_width - previewImage_margin;
            }
        }
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Layout updating

- (void)SwitchToMode:(RTImagePickerToolbarMode)mode
{
    switch (mode) {
        case RTImagePickerToolbarModeImagePicker: {
            currentMode = mode;
            [self bringSubviewToFront:_imagePickerToolbarBackgroundView];
            [UIView animateWithDuration:layoutUpdateAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _photoBrowserToolbarBackgroundView.top = self.height;
                _imagePickerToolbarBackgroundView.top = self.height - _imagePickerToolbarBackgroundView.height;
                _cameraToolBarBackgroundView.top = self.height;
            } completion:^(BOOL finished) {
                camera = nil;
            }];
        }
            break;
        case RTImagePickerToolbarModePhotoBrowser: {
            currentMode = mode;
            [self bringSubviewToFront:_photoBrowserToolbarBackgroundView];
            [UIView animateWithDuration:layoutUpdateAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _photoBrowserToolbarBackgroundView.top = self.height - _photoBrowserToolbarBackgroundView.height;
                _imagePickerToolbarBackgroundView.top = self.height;
                _cameraToolBarBackgroundView.top = self.height;
            } completion:^(BOOL finished) {
                camera = nil;
            }];
        }
            break;
        case RTImagePickerToolbarModeCamera: {
            currentMode = mode;
            [self bringSubviewToFront:_cameraToolBarBackgroundView];
            [UIView animateWithDuration:layoutUpdateAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _photoBrowserToolbarBackgroundView.top = self.height;
                _imagePickerToolbarBackgroundView.top = self.height;
                _cameraToolBarBackgroundView.top = self.height - _cameraToolBarBackgroundView.height;
            } completion:^(BOOL finished) {
                browser = nil;
            }];
        }
            break;
        case RTImagePickerToolbarModeCameraPreview: {
            currentMode = mode;
            [self bringSubviewToFront:_photoBrowserToolbarBackgroundView];
            [UIView animateWithDuration:layoutUpdateAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _photoBrowserToolbarBackgroundView.top = self.height - _photoBrowserToolbarBackgroundView.height;
                _imagePickerToolbarBackgroundView.top = self.height;
                _cameraToolBarBackgroundView.top = self.height;
            } completion:^(BOOL finished) {
                browser = nil;
            }];
        }
            break;
        default:
            break;
    }
}

/**
 *  Updating layout when new selection or deselection happens, main job for this RTImagePickerToolbarView, seperate from 
 *  the logic in controller.
 */
- (void)updateLayoutWhenUpdatingAsset
{
    if(self.selectedAssets.count > 0) {
        if(self.sendButton.hidden) {
            CGFloat margin_width = (self.width - 46.0f * 4.0f - 44.0f) /3.0f;
            
            CGFloat cameraButtonLeft_new = _cancelButton.right + margin_width;
            CGFloat dvButtonLeft_new = cameraButtonLeft_new + button_width + margin_width;
            CGFloat sendButtonLeft_new = dvButtonLeft_new + button_width + margin_width;
            self.sendButton.hidden = NO;
            
            UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.viewController.collectionView.collectionViewLayout;
            [collectionViewLayout setFooterReferenceSize:CGSizeMake(ScreenWidth, self.height)];
            
            [UIView animateWithDuration:layoutUpdateAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.cameraButton.left = cameraButtonLeft_new;
                self.dvButton.left = dvButtonLeft_new;
                self.sendButton.left = sendButtonLeft_new;
                _previewScrollView.top = 0.0f;
            } completion:^(BOOL finished) {
                
            }];
        }
    } else {
        if(!self.sendButton.hidden) {
            CGFloat margin_width = (self.width - 46.0f * 3.0f - 44.0f) /2.0f;
            
            CGFloat cameraButtonLeft_new = _cancelButton.right + margin_width;
            CGFloat dvButtonLeft_new = cameraButtonLeft_new + button_width + margin_width;
            CGFloat sendButtonLeft_new = dvButtonLeft_new + button_width + margin_width;
            
            UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.viewController.collectionView.collectionViewLayout;
            [collectionViewLayout setFooterReferenceSize:CGSizeMake(ScreenWidth, self.height/2.0f)];
            
            self.viewController.collectionView.userInteractionEnabled = NO;
            [UIView animateWithDuration:layoutUpdateAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.cameraButton.left = cameraButtonLeft_new;
                self.dvButton.left = dvButtonLeft_new;
                self.sendButton.left = sendButtonLeft_new;
                _previewScrollView.top = self.height/2.0f;
            } completion:^(BOOL finished) {
                for(UIImageView *imageView in self.previewImageViewArray) {
                    [imageView removeFromSuperview];
                }
                [self.previewImageViewArray removeAllObjects];
                [self.previewImageArray removeAllObjects];
                self.viewController.collectionView.userInteractionEnabled = YES;
                self.sendButton.hidden = YES;
            }];
        }
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(event.type == UIEventTypeTouches) {
        if(point.y < 0) {
            return NO;
        } else if(point.y >= 0 && point.y < 75.0f) {
            switch (currentMode) {
                case RTImagePickerToolbarModeCamera: {
                    return YES;
                }
                    break;
                case RTImagePickerToolbarModeCameraPreview:
                case RTImagePickerToolbarModePhotoBrowser: {
                    return NO;
                }
                    break;
                case RTImagePickerToolbarModeImagePicker: {
                    if(_previewScrollView.top < 10.0f) {
                        return YES;
                    } else {
                        return NO;
                    }
                }
                    break;
                default: {
                    return NO;
                }
                    break;
            }
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

#pragma mark - Image Action

- (void)imageTap:(UITapGestureRecognizer *)gesture
{
    UIImage *currentImage = [(UIImageView *)gesture.view image];
    NSInteger currentIndex = 0;
    
    for(NSInteger i=0;i<self.previewImageArray.count;i++) {
        UIImage *image = [self.previewImageArray objectAtIndex:i];
        if([image isEqual:currentImage]) {
            currentIndex = i;
        }
    }
    
    browser = [[RTImagePickerPhotoBrowser alloc] initWithDelegate:self];
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.autoPlayOnAppear = NO;
    [browser setCurrentPhotoIndex:currentIndex];

    [self.viewController.navigationController pushViewController:browser animated:YES];
}

- (void)imagePan:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            UIImageView *imageView = (UIImageView *)gesture.view;
            currentPanImageViewIndex = [self.previewImageViewArray indexOfObject:imageView];
            currentLocation = [gesture locationInView:self.previewScrollView];
            
            [self.previewScrollView bringSubviewToFront:imageView];
            currentCenter = imageView.center;
            [imageView.layer addAnimation:[self animationForImageViewToSelected] forKey:@"fuck"];
            self.viewController.collectionView.userInteractionEnabled = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self.previewScrollView];
            CGPoint translation = CGPointMake(point.x - currentLocation.x, point.y - currentLocation.y);
            NSLog(@"pan changed with x:%f,y:%f.",translation.x,translation.y);
            UIImageView *imageView = (UIImageView *)gesture.view;
            imageView.center = CGPointMake(currentCenter.x + translation.x, currentCenter.y + (translation.y > 0 ? 0.0f : translation.y));
            
            if(translation.y > - previewImage_width) {
                if(![imageView.layer animationForKey:@"scaleBigger"]) {
                    if([imageView.layer animationForKey:@"scaleSmaller"]) {
                        [imageView.layer removeAnimationForKey:@"scaleSmaller"];
                        [imageView.layer addAnimation:[self animationForImageViewToScaleToThumb:NO] forKey:@"scaleBigger"];
                    }
                }
                if(self.viewController.view.alpha < 0.7f) {
                    [UIView animateWithDuration:0.15f animations:^{
                        self.viewController.view.alpha = 1.0f;
                    }];
                }
                [self rearrangePreviewImageView:imageView];
            } else {
                // Drag the imageView upward into the DELETE area
                if(![imageView.layer animationForKey:@"scaleSmaller"]) {
                    [imageView.layer removeAnimationForKey:@"scaleBigger"];
                    [imageView.layer addAnimation:[self animationForImageViewToScaleToThumb:YES] forKey:@"scaleSmaller"];
                }
                if(self.viewController.view.alpha > 0.7f) {
                    [UIView animateWithDuration:0.15f animations:^{
                        self.viewController.view.alpha = 0.6f;
                    }];
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            self.viewController.view.alpha = 1.0f;
            UIImageView *imageView = (UIImageView *)gesture.view;
            CGPoint point = [gesture locationInView:self.previewScrollView];
            CGPoint translation = CGPointMake(point.x - currentLocation.x, point.y - currentLocation.y);
            if(translation.y <  - previewImage_width) {
                // Pan upward to delete asset
                [UIView animateWithDuration:0.2f animations:^{
                    imageView.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    [imageView.layer removeAllAnimations];
                    [self deleteAssetAtIndex:currentPanImageViewIndex];
                    [self.viewController.collectionView reloadData];
                    [self rearrangePreviewImageView:nil];
                    self.viewController.collectionView.userInteractionEnabled = YES;
                }];
            } else {
                CGFloat t_x = currentCenter.x + translation.x;
                NSInteger index_end = t_x / (previewImage_width + previewImage_margin);
                if(index_end == currentPanImageViewIndex) {
                    // Not changing index
                    imageView.center = currentCenter;
                } else {
                    // Change its index, replace everything
                    UIImage *t_image = [self.previewImageArray objectAtIndex:currentPanImageViewIndex];
                    RTImagePickerPhoto *t_photo = [self.previewPhotoArray objectAtIndex:currentPanImageViewIndex];
                    
                    [self.previewImageViewArray removeObject:imageView];
                    if (index_end >= _previewImageViewArray.count) {
                        [_previewImageViewArray addObject:imageView];
                    } else {
                        [_previewImageViewArray insertObject:imageView atIndex:index_end];
                    }
                    
                    [self.previewImageArray removeObject:t_image];
                    if (index_end >= _previewImageArray.count) {
                        [_previewImageArray addObject:t_image];
                    } else {
                        [_previewImageArray insertObject:t_image atIndex:index_end];
                    }
                    
                    [self.previewPhotoArray removeObject:t_photo];
                    if (index_end >= _previewPhotoArray.count) {
                        [_previewPhotoArray addObject:t_photo];
                    } else {
                        [_previewPhotoArray insertObject:t_photo atIndex:index_end];
                    }
                }
                [self rearrangePreviewImageView:nil];
                self.viewController.collectionView.userInteractionEnabled = YES;
            }
        }
            break;
        default:
        {
            // reset state
            self.viewController.collectionView.userInteractionEnabled = YES;
            UIImageView *imageView = (UIImageView *)gesture.view;
            imageView.center = currentCenter;
            [imageView.layer removeAllAnimations];
            [self rearrangePreviewImageView:imageView];
        }
            break;
    }
}

#pragma mark - Animation method

- (CABasicAnimation *)animationForImageViewToScaleToThumb:(BOOL)isThumb
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    if(isThumb) {
        animation.fromValue = [NSNumber numberWithFloat:1.0f];
        animation.toValue = [NSNumber numberWithFloat:0.5f];
    } else {
        animation.fromValue = [NSNumber numberWithFloat:0.5f];
        animation.toValue = [NSNumber numberWithFloat:1.0f];
    }
    animation.duration = 0.15f;
    animation.repeatCount = 1;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.speed = 1.0f;
    animation.beginTime = 0.0f;
    return animation;
}

- (CABasicAnimation *)animationForImageViewToSelected
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithFloat:0.9f];
    animation.toValue = [NSNumber numberWithFloat:1.2f];
    animation.duration = 0.15f;
    animation.repeatCount = 1;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = YES;
    animation.removedOnCompletion = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.speed = 1.0f;
    animation.beginTime = 0.0f;
    return animation;
}

- (void)rearrangePreviewImageView:(UIImageView *)targetImageView
{
    [UIView animateWithDuration:0.2f animations:^{
        CGFloat nextX = 0.0f;
        CGFloat centerX = targetImageView.center.x;
        
        for(UIImageView *imageView in self.previewImageViewArray) {
            if(![imageView isEqual:targetImageView]) {
                imageView.top = previewImage_margin;
                if(centerX - nextX <  previewImage_width && centerX - nextX > 0) {
                    nextX += previewImage_margin + previewImage_width;
                    imageView.left = nextX;
                } else {
                    imageView.left = nextX;
                }
                nextX += previewImage_margin + previewImage_width;
            }
        }
    }];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser {
    return _previewPhotoArray.count;
}

- (id <RTImagePickerPhoto>)photoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _previewPhotoArray.count)
        return [_previewPhotoArray objectAtIndex:index];
    return nil;
}

- (id <RTImagePickerPhoto>)photoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _previewPhotoArray.count)
        return [_previewPhotoArray objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(RTImagePickerPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
}

- (void)photoBrowserDidChangeHidden:(RTImagePickerPhotoBrowser *)photoBrowser State:(BOOL)state
{
    if(state) {
        [UIView animateWithDuration:layoutUpdateAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.top = ScreenHeight;
        } completion:^(BOOL finished) {
        }];
    } else {
        [UIView animateWithDuration:layoutUpdateAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.top = ScreenHeight - self.height;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)setFlashEnabled:(BOOL)enabled
{
    self.cameraFlashButton.hidden = !enabled;
}

- (void)setFlashState:(BOOL)state
{
    if(state) {
        [self.cameraFlashButton setImage:[UIImage imageNamed:@"rtimagepicker_flash_on"] forState:UIControlStateNormal];
    } else {
        [self.cameraFlashButton setImage:[UIImage imageNamed:@"rtimagepicker_flash_off"] forState:UIControlStateNormal];
    }
}

- (void)shakePreviewScrollView
{
    // 晃动次数
    static int numberOfShakes = 4;
    // 晃动幅度（相对于总宽度）
    static float vigourOfShake = 0.02f;
    // 晃动延续时常（秒）
    static float durationOfShake = 0.4f;
    
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    CGPoint layerPosition = self.previewScrollView.layer.position;
    
    NSValue *value1=[NSValue valueWithCGPoint:self.previewScrollView.layer.position];
    NSMutableArray *values = [[NSMutableArray alloc] initWithObjects:value1, nil];
    for (int i = 0; i<numberOfShakes; i++) {
        NSValue *valueLeft = [NSValue valueWithCGPoint:CGPointMake(layerPosition.x-self.previewScrollView.frame.size.width*vigourOfShake*(1-(float)i/numberOfShakes), layerPosition.y)];
        NSValue *valueRight = [NSValue valueWithCGPoint:CGPointMake(layerPosition.x+self.previewScrollView.frame.size.width*vigourOfShake*(1-(float)i/numberOfShakes), layerPosition.y)];
        
        [values addObject:valueLeft];
        [values addObject:valueRight];
    }
    [values addObject:value1];
    
    shakeAnimation.values = values;
    shakeAnimation.duration = durationOfShake;
    
    [self.previewScrollView.layer addAnimation:shakeAnimation forKey:kCATransition];
}

- (void)didSelectVideoWithFileName:(NSString *)fileName captureImage:(UIImage *)image
{
    if(self.viewController) {
        if([self.viewController.imagePickerController.delegate respondsToSelector:@selector(rt_imagePickerController:didFinishPickingVideoWithFileName:withCaptureImage:)]) {
            [self.viewController.imagePickerController.delegate rt_imagePickerController:self.viewController.imagePickerController didFinishPickingVideoWithFileName:fileName withCaptureImage:image];
        }
    }
}
@end