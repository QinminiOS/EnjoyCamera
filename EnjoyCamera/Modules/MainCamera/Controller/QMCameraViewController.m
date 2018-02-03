//
//  QMCameraViewController.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMCameraViewController.h"
#import "QMPhotoClipViewController.h"
#import "QMPhotoEffectViewController.h"
#import "RTImagePickerViewController.h"
#import "UIColor+Additions.h"
#import "QMCameraSettingViewController.h"
#import <Photos/Photos.h>
#import <TOCropViewController.h>
#import <GPUImage.h>
#import <Masonry.h>
#import "QMShakeButton.h"
#import "CKStillCamera.h"
#import "CKStillCameraPreview.h"
#import "PHAsset+Latest.h"
#import "QMCameraRatioSuspensionView.h"
#import "QMCameraFlashSuspensionView.h"
#import "QMCameraFilterView.h"
#import "QMImageFilter.h"
#import "QMPhotoDisplayViewController.h"
#import "UIImage+Rotate.h"
#import "UIImage+Clip.h"
#import "QMCameraFocusView.h"
#import "QMProgressHUD.h"

#define kCameraViewBottomBGHeight   ((kScreenH)-(kScreenW)*(4.0f/3.0f))
#define kCameraTakePhotoIconSize   75

@interface QMCameraViewController ()<RTImagePickerViewControllerDelegate,TOCropViewControllerDelegate>
{
    QMCameraRatioSuspensionView *_ratioSuspensionView;
    QMCameraFlashSuspensionView *_flashSuspensionView;
    QMCameraFocusView *_foucusView;
    QMCameraFilterView *_cameraFilterView;
    CGFloat _currentCameraViewRatio;
    CGFloat _lastTwoFingerDistance;
}
@property (nonatomic, strong) CKStillCamera *stillCamera;
@property (nonatomic, strong) CKStillCameraPreview *imageView;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, assign) CGFloat currentSwipeFilterIndex;

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIView *bottomBg;
@property (nonatomic, strong) UIView *topBg;
@property (nonatomic, strong) UIButton *takePhotoBtn;
@property (nonatomic, strong) UIButton *picBtn;

@property (nonatomic, assign) AVCaptureTorchMode currentTorchModel;
@property (nonatomic, assign) AVCaptureFlashMode currentFlashModel;
@end

@implementation QMCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupVar];
    [self setupUI];
    [self setupCamera];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.takePhotoBtn.userInteractionEnabled = NO;
    
    // 开始捕捉
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [self startCameraCapture];
    });
    
    // 相册加载
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self asyncLoadLatestImageFromPhotoLib];
            }
        }];
    }else {
        [self asyncLoadLatestImageFromPhotoLib];
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (iPhoneX) {
        return NO;
    }
    
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - SETUP
- (void)setupVar
{
    _currentCameraViewRatio = 1.33f;
    _currentFlashModel = AVCaptureFlashModeOff;
    _currentTorchModel = AVCaptureTorchModeOff;
}

- (void)setupUI
{
    weakSelf();
    
    // NavigationBar
    [self.navigationController setNavigationBarHidden:YES];
    
    // GPUImageView
    _imageView = [[CKStillCameraPreview alloc] initWithFrame:CGRectZero];
    _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    _imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*4.0/3.0);
    [self.view addSubview:_imageView];
    
    // 自动对焦
    [_imageView.tapGestureSignal subscribeNext:^(UITapGestureRecognizer* _Nullable x) {
        BOOL ratioHidden = [wself.ratioSuspensionView hide];
        BOOL flashHidden = [wself.flashSuspensionView hide];
        BOOL cameraHidden = [wself.cameraFilterView hide];
        if (ratioHidden || flashHidden || cameraHidden) {
            return;
        }
        
        // foucus
        CGPoint center = [x locationInView:wself.view];
        CGPoint foucus = CGPointMake(center.x/wself.imageView.frame.size.width, 1.0-center.y/wself.imageView.frame.size.height);
        [wself.stillCamera setExposeModel:AVCaptureExposureModeContinuousAutoExposure];
        [wself.stillCamera focusAtPoint:foucus];
        [wself.cameraFocusView foucusAtPoint:center];
    }];
    
    // 视频缩放
    [[_imageView.pinchGestureSignal filter:^BOOL(UIPinchGestureRecognizer* _Nullable value) {
        return value.numberOfTouches == 2;
    }] subscribeNext:^(UIPinchGestureRecognizer* _Nullable x) {
        CGPoint first = [x locationOfTouch:0 inView:wself.imageView];
        CGPoint second = [x locationOfTouch:1 inView:wself.imageView];
        if (x.state == UIGestureRecognizerStateBegan) {
            _lastTwoFingerDistance = sqrt(pow(first.x - second.x, 2) + pow(first.y-second.y, 2));
        }else if (x.state == UIGestureRecognizerStateChanged) {
            CGFloat twoFingerDistance = sqrt(pow(first.x - second.x, 2) + pow(first.y-second.y, 2));
            CGFloat scale = (twoFingerDistance - _lastTwoFingerDistance)/_lastTwoFingerDistance;
            [wself.stillCamera setVideoZoomFactor:scale+wself.stillCamera.videoZoomFactor];
            _lastTwoFingerDistance = twoFingerDistance;
        }else if (x.state == UIGestureRecognizerStateEnded) {
            _lastTwoFingerDistance = sqrt(pow(first.x - second.x, 2) + pow(first.y-second.y, 2));
        }else if (x.state == UIGestureRecognizerStateCancelled) {
            _lastTwoFingerDistance = sqrt(pow(first.x - second.x, 2) + pow(first.y-second.y, 2));
        }
    }];
    
    // 轻扫右
    [_imageView.swipeRightGestureSignal subscribeNext:^(UISwipeGestureRecognizer*  _Nullable x) {
        wself.currentSwipeFilterIndex -= 1;
        wself.currentSwipeFilterIndex = ([[wself cameraFilterView] selectFilterAtIndex:wself.currentSwipeFilterIndex]) ? wself.currentSwipeFilterIndex : wself.currentSwipeFilterIndex + 1;
        
    }];
    
    // 轻扫左
    [_imageView.swipeLeftGestureSignal subscribeNext:^(UISwipeGestureRecognizer*  _Nullable x) {
        wself.currentSwipeFilterIndex += 1;
        wself.currentSwipeFilterIndex = ([[wself cameraFilterView] selectFilterAtIndex:wself.currentSwipeFilterIndex]) ? wself.currentSwipeFilterIndex : wself.currentSwipeFilterIndex - 1;
    }];
    
    // 顶部背景
    _topBg = [[UIView alloc] initWithFrame:CGRectZero];
    _topBg.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:255.0];
    [self.view addSubview:_topBg];
    
    
    // iPhoneX 适配
    CGFloat topOffset = iPhoneX ? 45 : 20;
    
    // 闪光灯
    UIButton *flashBtn = [[QMShakeButton alloc] initWithFrame:CGRectZero];
    [flashBtn setImage:[UIImage imageNamed:@"qmkit_no_flash_btn"] forState:UIControlStateNormal];
    [flashBtn setImage:[UIImage imageNamed:@"qmkit_no_flash_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:flashBtn];
    [flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(topOffset);
    }];
    [[flashBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.flashSuspensionView setFlashCallBack:^(AVCaptureFlashMode flash, AVCaptureTorchMode torch, NSString *icon) {
            wself.currentTorchModel = torch;
            wself.currentFlashModel = flash;
            [flashBtn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
            [flashBtn setImage:[UIImage imageNamed:icon] forState:UIControlStateHighlighted];
            [wself.stillCamera setFlashModel:flash];
            [wself.stillCamera setTorchModel:torch];
        }];
        [wself.ratioSuspensionView hide];
        [wself.flashSuspensionView toggleBelowInView:flashBtn];
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        [wself.stillCamera setFlashModel:wself.currentFlashModel];
        [wself.stillCamera setTorchModel:wself.currentTorchModel];
    }];
    
    // 比例按钮
    UIButton *scaleBtn = [[QMShakeButton alloc] initWithFrame:CGRectZero];
    [scaleBtn setTitle:@"3:4" forState:UIControlStateNormal];
    scaleBtn.titleLabel.font = [UIFont systemFontOfSize:8.0f];
    scaleBtn.layer.borderWidth = 1.1f;
    scaleBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:scaleBtn];
    [scaleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat x = self.view.frame.size.width/3;
        make.left.mas_equalTo(@(x));
        make.width.mas_equalTo(22);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(topOffset+5);
    }];
    [[scaleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.ratioSuspensionView setRatioCallBack:^(QMSuspensionModel *item) {
            [wself setCameraRatio:item.value];
            [scaleBtn setTitle:item.name forState:UIControlStateNormal];
        }];
        [wself.flashSuspensionView hide];
        [wself.ratioSuspensionView toggleBelowInView:scaleBtn];
    }];
    
    // 设置按钮
    UIButton *settingBtn = [[QMShakeButton alloc] initWithFrame:CGRectZero];
    [settingBtn setImage:[UIImage imageNamed:@"qmkit_setting_btn"] forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"qmkit_setting_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:settingBtn];
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat x = self.view.frame.size.width/3;
        make.right.mas_equalTo(@(-x));
        make.width.height.mas_equalTo(30);
        make.top.mas_equalTo(topOffset);
    }];
    [[settingBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        QMCameraSettingViewController *settingVC = [[QMCameraSettingViewController alloc] init];
        [wself.navigationController pushViewController:settingVC animated:YES];
    }];
    
    // 前后镜头
    UIButton *rotateBtn = [[QMShakeButton alloc] initWithFrame:CGRectZero];
    [rotateBtn setImage:[UIImage imageNamed:@"qmkit_rotate_btn"] forState:UIControlStateNormal];
    [rotateBtn setImage:[UIImage imageNamed:@"qmkit_rotate_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:rotateBtn];
    [rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.right.mas_offset(-20);
        make.top.mas_equalTo(topOffset);
    }];
    [[rotateBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.stillCamera rotateCamera];
    }];
    
    // 底部背景
    UIView *bottomBg = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH-kCameraViewBottomBGHeight, kScreenW, kCameraViewBottomBGHeight)];
    bottomBg.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:255.0];
    [self.view addSubview:bottomBg];
    _bottomBg = bottomBg;
    
    // 拍照
    _takePhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenW/2-kCameraTakePhotoIconSize/2, kScreenH-kCameraViewBottomBGHeight/2-kCameraTakePhotoIconSize/2, kCameraTakePhotoIconSize, kCameraTakePhotoIconSize)];
    [_takePhotoBtn setImage:[UIImage imageNamed:@"qmkit_takephoto_btn"] forState:UIControlStateNormal];
    [_takePhotoBtn setImage:[UIImage imageNamed:@"qmkit_takephoto_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:_takePhotoBtn];
    [[_takePhotoBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        wself.takePhotoBtn.userInteractionEnabled = NO;
        [wself stopCameraCapture];
    }];
    
    // 相册选择
    CGFloat picBtnWidth = 25; CGFloat picBtnHeight = 30;
    CGFloat picBtnX = kScreenW/2 - kCameraTakePhotoIconSize/2;
    UIButton *picBtn = [[QMShakeButton alloc] initWithFrame:CGRectMake(picBtnX/2-picBtnWidth/2, kScreenH-kCameraViewBottomBGHeight/2-picBtnWidth/2, picBtnWidth, picBtnHeight)];
    picBtn.layer.borderWidth = 1.3f;
    picBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:picBtn];
    _picBtn = picBtn;
    [[picBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself choseImageFromPhotoLibrary];
    }];
    
    // 滤镜
    CGFloat filterSize = 35;
    CGFloat filterX = kScreenW/2 - kCameraTakePhotoIconSize/2;
    UIButton *filterBtn = [[QMShakeButton alloc] initWithFrame:CGRectMake(kScreenW-filterX/2-filterSize/2, kScreenH-kCameraViewBottomBGHeight/2-filterSize/2, filterSize, filterSize)];
    [filterBtn setImage:[UIImage imageNamed:@"qmkit_fiter_btn"] forState:UIControlStateNormal];
    [filterBtn setImage:[UIImage imageNamed:@"qmkit_fiter_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:filterBtn];
    [[filterBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.cameraFilterView toggleInView:wself.view];
    }];
    
    // 点击滤镜
    [[self cameraFilterView] setFilterItemClickBlock:^(QMFilterModel *item, NSInteger index) {
        wself.currentSwipeFilterIndex = index;
        [wself.stillCamera removeAllTargets];
        wself.filter = [[QMImageFilter alloc] initWithFilterModel:item];
        [(QMImageFilter *)self.filter setAlpha:item.currentAlphaValue];
        [wself.stillCamera addTarget:_filter];
        [wself.filter addTarget:_imageView];
    }];
    
    // 滤镜变化
    [[self cameraFilterView] setFilterValueDidChangeBlock:^(CGFloat value) {
        QMImageFilter *filter = (QMImageFilter *)wself.filter;
        [filter setAlpha:value];
    }];

    // 滤镜显示回调
    [[self cameraFilterView] setFilterWillShowBlock:^{
        // 先缩放
        [UIView animateWithDuration:0.3f animations:^{
            picBtn.alpha = 0.0f;
            filterBtn.alpha = 0.0f;
            wself.takePhotoBtn.frame = CGRectMake(kScreenW/2-kCameraTakePhotoIconSize/4, kScreenH-kCameraViewBottomBGHeight/2-kCameraTakePhotoIconSize/4, kCameraTakePhotoIconSize/2, kCameraTakePhotoIconSize/2);
        } completion:^(BOOL finished) {
            // 再移动
            [UIView animateWithDuration:0.1f animations:^{
                wself.takePhotoBtn.frame = CGRectMake(kScreenW/2-kCameraTakePhotoIconSize/4, kScreenH - (kCameraViewBottomBGHeight - 84)/2-kCameraTakePhotoIconSize/4, kCameraTakePhotoIconSize/2, kCameraTakePhotoIconSize/2);
            } completion:^(BOOL finished) {
                // 最后交换层顺序
                [wself.view bringSubviewToFront:wself.takePhotoBtn];
            }];
        }];
    }];
    
    // 滤镜关闭回调
    [[self cameraFilterView] setFilterWillHideBlock:^{
        // 交换层顺序
        [wself.takePhotoBtn removeFromSuperview];
        [wself.view insertSubview:wself.takePhotoBtn belowSubview:[self cameraFilterView]];
        // 先回到原来位置
        [UIView animateWithDuration:0.2f animations:^{
            wself.takePhotoBtn.frame = CGRectMake(kScreenW/2-kCameraTakePhotoIconSize/4, kScreenH-kCameraViewBottomBGHeight/2-kCameraTakePhotoIconSize/4, kCameraTakePhotoIconSize/2, kCameraTakePhotoIconSize/2);
        } completion:^(BOOL finished) {
            // 再放大
            [UIView animateWithDuration:0.3f animations:^{
                picBtn.alpha = 1.0f;
                filterBtn.alpha = 1.0f;
                wself.takePhotoBtn.frame = CGRectMake(kScreenW/2-kCameraTakePhotoIconSize/2, kScreenH-kCameraViewBottomBGHeight/2-kCameraTakePhotoIconSize/2, kCameraTakePhotoIconSize, kCameraTakePhotoIconSize);
            }];
        }];
    }];
}

- (void)setupCamera
{
    // 初始化stillCamera
    _stillCamera = [[CKStillCamera alloc] init];
    _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    // 初始化滤镜
    _filter = [[GPUImageCropFilter alloc] init];
    [_stillCamera addTarget:_filter];
    [_filter addTarget:_imageView];
    
    weakSelf();
    [self.stillCamera setISOAdjustingBlock:^(BOOL adjust) {
        if (!adjust) {
            [wself.cameraFocusView setISO:wself.stillCamera.currentISOPercentage];
        }
    }];
}

#pragma mark - PrivateMethod
- (void)startCameraCapture
{
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self.stillCamera setFlashModel:self.currentFlashModel];
        [self.stillCamera setTorchModel:self.currentTorchModel];
        [self.stillCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        [self.stillCamera setExposeModel:AVCaptureExposureModeContinuousAutoExposure];
        [self.stillCamera startCameraCapture];
        dispatch_async(dispatch_get_main_queue(), ^{
           self.takePhotoBtn.userInteractionEnabled = YES;
        });
    });
}

- (void)stopCameraCapture
{
    runAsynchronouslyOnVideoProcessingQueue(^{
        [_stillCamera capturePhotoAsImageProcessedUpToFilter:_filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            [self.stillCamera stopCameraCapture];
            UIImage *image = [UIImage clipImage: [processedImage fixOrientation] withRatio:_currentCameraViewRatio];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.takePhotoBtn.userInteractionEnabled = YES;
                QMPhotoDisplayViewController *displayVC = [[QMPhotoDisplayViewController alloc] init];
                displayVC.image = image;
                [self.navigationController pushViewController:displayVC animated:YES];
            });
        }];
        
    });
}

- (void)choseImageFromPhotoLibrary
{
    RTImagePickerViewController *imagePickerController = [RTImagePickerViewController new];
    imagePickerController.delegate = self;
    imagePickerController.mediaType = RTImagePickerMediaTypeImage;
    // imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.maximumNumberOfSelection = 2;
    imagePickerController.minimumNumberOfSelection = 1;
    [self.navigationController pushViewController:imagePickerController animated:YES];
}

- (void)asyncLoadLatestImageFromPhotoLib
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [PHAsset latestImageWithSize:CGSizeMake(30, 30) completeBlock:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_picBtn setImage:image forState:UIControlStateNormal];
                [_picBtn setImage:image forState:UIControlStateHighlighted];
            });
        }];
    });
}

#pragma mark - 方向矫正
- (void)fixImageOrientation:(UIImage *)image completionBlock:(void(^)(UIImage *image))block
{
    [QMProgressHUD show];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *newImage = [image fixOrientation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [QMProgressHUD hide];
            if (block) {
                block(newImage);
            }
        });
    });
}

#pragma mark - 调整相机比例
- (void)setCameraRatio:(CGFloat)ratio
{
    _currentCameraViewRatio = ratio;
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float height = screenWidth * ratio;
    [UIView animateWithDuration:0.3f animations:^{
        CGFloat topViewHeight = screenHeight-height-kCameraViewBottomBGHeight;
        if (topViewHeight >= 0) {
            self.topBg.frame = CGRectMake(0, 0, screenWidth, screenHeight-height-kCameraViewBottomBGHeight);
            self.bottomBg.frame = CGRectMake(0, screenHeight-kCameraViewBottomBGHeight, screenWidth, kCameraViewBottomBGHeight);
            self.imageView.frame = CGRectMake(0, screenHeight-height-kCameraViewBottomBGHeight, screenWidth, height);
        }else {
            self.topBg.frame = CGRectMake(0, 0, screenWidth, screenHeight-height);
            self.imageView.frame = CGRectMake(0, screenHeight-height, screenWidth, height);
            self.bottomBg.frame = CGRectMake(0, screenHeight, screenWidth, kCameraViewBottomBGHeight);
        }
    }];
}

#pragma mark - Getter
- (QMCameraRatioSuspensionView *)ratioSuspensionView
{
    if (!_ratioSuspensionView) {
        _ratioSuspensionView = [QMCameraRatioSuspensionView ratioSuspensionView];
    }
    return _ratioSuspensionView;
}

- (QMCameraFlashSuspensionView *)flashSuspensionView
{
    if (!_flashSuspensionView) {
        _flashSuspensionView = [QMCameraFlashSuspensionView flashSuspensionView];
    }
    return _flashSuspensionView;
}

- (QMCameraFilterView *)cameraFilterView
{
    if (!_cameraFilterView) {
        _cameraFilterView = [QMCameraFilterView cameraFilterView];
    }
    return _cameraFilterView;
}

- (QMCameraFocusView *)cameraFocusView
{
    if (!_foucusView) {
        weakSelf();
        _foucusView = [QMCameraFocusView focusView];
        [self.view addSubview:_foucusView];
        [_foucusView setLuminanceChangeBlock:^(CGFloat value) {
            [wself.stillCamera setExposureModeCustomWithDuration:kCMTimeZero ISO:value completionHandler:NULL];
        }];
    }
    return _foucusView;
}

#pragma mark - RTImagePickerViewControllerDelegate
- (void)rt_imagePickerController:(RTImagePickerViewController *)imagePickerController didFinishPickingImages:(NSArray<UIImage *> *)images
{
    TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:[images lastObject]];
    cropViewController.delegate = self;
    [imagePickerController.navigationController pushViewController:cropViewController animated:YES];
}

- (void)rt_imagePickerControllerDidCancel:(RTImagePickerViewController *)imagePickerController
{
    [imagePickerController.navigationController popViewControllerAnimated:YES];
}

- (void)rt_imagePickerController:(RTImagePickerViewController *)imagePickerController didSelectAsset:(PHAsset *)asset
{
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:[UIImage imageWithData:imageData]];
        cropViewController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetOriginal;
        cropViewController.delegate = self;
        [imagePickerController.navigationController pushViewController:cropViewController animated:YES];
    }];
    
}

#pragma mark - TOCropViewControllerDelegate
- (void)cropViewController:(nonnull TOCropViewController *)cropViewController didCropToImage:(nonnull UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    [self fixImageOrientation:image completionBlock:^(UIImage *image) {
        QMPhotoEffectViewController *photoViewController = [[QMPhotoEffectViewController alloc] initWithImage:image];
        [cropViewController.navigationController pushViewController:photoViewController animated:YES];
    }];
}

@end
