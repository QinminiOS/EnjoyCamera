//
//  QMPhotoDisplayViewController.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMPhotoDisplayViewController.h"
#import "Constants.h"
#import "QMShakeButton.h"
#import "QMShareManager.h"
#import "QMPhotoEffectViewController.h"
#import "QMProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define kCameraViewBottomBGHeight   ((kScreenH)-(kScreenW)*(4.0f/3.0f))

@interface QMPhotoDisplayViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *bottomBg;
@end

@implementation QMPhotoDisplayViewController

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self setPhotoRatio];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - SETUP
- (void)setupUI
{
    // NavigationBar
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES];
    
    // GPUImageView
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*4.0/3.0);
    _imageView.image = _image;
    [self.view addSubview:_imageView];
    
    // 底部背景
    UIView *bottomBg = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH-kCameraViewBottomBGHeight, kScreenW, kCameraViewBottomBGHeight)];
    bottomBg.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:255.0];
    [self.view addSubview:bottomBg];
    _bottomBg = bottomBg;
    
    // 返回
    UIButton *backPhotoBtn = [[QMShakeButton alloc] initWithFrame:CGRectMake(kScreenW/6-40/2, kScreenH-kCameraViewBottomBGHeight/2-40/2, 40, 40)];
    [backPhotoBtn setImage:[UIImage imageNamed:@"qmkit_photo_back"] forState:UIControlStateNormal];
    [backPhotoBtn setImage:[UIImage imageNamed:@"qmkit_photo_back"] forState:UIControlStateHighlighted];
    [backPhotoBtn addTarget:self action:@selector(backPhotoBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backPhotoBtn];
    
//    UILabel *backPhotoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenW/6-40/2, kScreenH-kCameraViewBottomBGHeight/2+40/2, 40, 40)];
//    backPhotoLabel.text = @"返回";
//    backPhotoLabel.textAlignment = NSTextAlignmentCenter;
//    backPhotoLabel.font = [UIFont systemFontOfSize:14];
//    backPhotoLabel.textColor = [UIColor whiteColor];
//    [self.view addSubview:backPhotoLabel];
    
    // 保存
    UIButton *savePhotoBtn = [[QMShakeButton alloc] initWithFrame:CGRectMake(kScreenW/2-70/2, kScreenH-kCameraViewBottomBGHeight/2-80/2, 80, 80)];
    [savePhotoBtn setImage:[UIImage imageNamed:@"qmkit_save_photo_btn"] forState:UIControlStateNormal];
    [savePhotoBtn setImage:[UIImage imageNamed:@"qmkit_save_photo_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:savePhotoBtn];
    [savePhotoBtn addTarget:self action:@selector(savePhotoBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // 滤镜
    UIButton *filterPhotoBtn = [[QMShakeButton alloc] initWithFrame:CGRectMake(kScreenW/6*4, kScreenH-kCameraViewBottomBGHeight/2-35/2, 35, 35)];
    [filterPhotoBtn setImage:[UIImage imageNamed:@"qmkit_photo_filter"] forState:UIControlStateNormal];
    [filterPhotoBtn setImage:[UIImage imageNamed:@"qmkit_photo_filter"] forState:UIControlStateHighlighted];
    [filterPhotoBtn addTarget:self action:@selector(filterPhotoBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:filterPhotoBtn];
    
//    UILabel *filterPhotoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenW/6*4, kScreenH-kCameraViewBottomBGHeight/2+30/2, 30, 40)];
//    filterPhotoLabel.text = @"滤镜";
//    filterPhotoLabel.textAlignment = NSTextAlignmentCenter;
//    filterPhotoLabel.font = [UIFont systemFontOfSize:14];
//    filterPhotoLabel.textColor = [UIColor whiteColor];
//    [self.view addSubview:filterPhotoLabel];
    
    // 分享
    UIButton *sharePhotoBtn = [[QMShakeButton alloc] initWithFrame:CGRectMake(kScreenW/6*5, kScreenH-kCameraViewBottomBGHeight/2-25/2, 25, 25)];
    [sharePhotoBtn setImage:[UIImage imageNamed:@"qmkit_photo_share"] forState:UIControlStateNormal];
    [sharePhotoBtn setImage:[UIImage imageNamed:@"qmkit_photo_share"] forState:UIControlStateHighlighted];
    [sharePhotoBtn addTarget:self action:@selector(sharePhotoBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sharePhotoBtn];
    
//    UILabel *sharePhotoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenW/6*5, kScreenH-kCameraViewBottomBGHeight/2+30/2, 30, 30)];
//    sharePhotoLabel.text = @"分享";
//    sharePhotoLabel.textAlignment = NSTextAlignmentLeft;
//    sharePhotoLabel.font = [UIFont systemFontOfSize:14];
//    sharePhotoLabel.textColor = [UIColor whiteColor];
//    [self.view addSubview:sharePhotoLabel];
}

- (void)setPhotoRatio
{
    CGFloat ratio = (float)CGImageGetHeight(_image.CGImage)/(float)CGImageGetWidth(_image.CGImage);
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float height = screenWidth * ratio;
    CGFloat topHeight = screenHeight-height-kCameraViewBottomBGHeight;
    if (topHeight >= 0) {
        self.bottomBg.frame = CGRectMake(0, screenHeight-kCameraViewBottomBGHeight, screenWidth, kCameraViewBottomBGHeight);
        self.imageView.frame = CGRectMake(0, screenHeight-height-kCameraViewBottomBGHeight, screenWidth, height);
    }else {
        self.imageView.frame = CGRectMake(0, screenHeight-height, screenWidth, height);
        self.bottomBg.frame = CGRectMake(0, screenHeight, screenWidth, kCameraViewBottomBGHeight);
    }
}

- (void)saveImage
{
    [QMProgressHUD show];
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
    [assetsLib writeImageToSavedPhotosAlbum:_image.CGImage
                                orientation:(NSInteger)_image.imageOrientation
                            completionBlock:^(NSURL *assetURL, NSError *error) {
                                [QMProgressHUD hide];
                            }];
}


#pragma mark - PublicMethod
- (void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = _image;
}

#pragma mark - Event
- (void)backPhotoBtnTapped:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)savePhotoBtnTapped:(UIButton *)sender
{
    [self saveImage];
}
- (void)filterPhotoBtnTapped:(UIButton *)sender
{
    QMPhotoEffectViewController *photoEdit = [[QMPhotoEffectViewController alloc] initWithImage:self.image];
    [self.navigationController pushViewController:photoEdit animated:YES];
}

- (void)sharePhotoBtnTapped:(UIButton *)sender
{
    [QMShareManager shareThumbImage:self.image inViewController:self];
}

@end
