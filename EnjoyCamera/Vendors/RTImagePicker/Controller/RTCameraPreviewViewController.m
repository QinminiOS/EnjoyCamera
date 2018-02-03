//
//  RTCameraPreviewViewController.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/22/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTCameraPreviewViewController.h"
#import "RTImagePickerNavigationController.h"

@interface RTCameraPreviewViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView              *imageScrollView;
@property (nonatomic, strong) UIImage                   *image;
@property (nonatomic, strong) UIImageView               *imageView;

@end

@implementation RTCameraPreviewViewController

- (instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if(self) {
        self.image = image;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if([(RTImagePickerNavigationController *)self.navigationController toolBarView]) {
        [[(RTImagePickerNavigationController *)self.navigationController toolBarView] SwitchToMode:RTImagePickerToolbarModeCameraPreview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    [(RTImagePickerNavigationController *)self.navigationController toolBarView].cameraImage = self.image;
    
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 75.0f, ScreenWidth, ScreenHeight - 150.0f)];
    _imageScrollView.maximumZoomScale = 3.0f;
    _imageScrollView.minimumZoomScale = 1.0f;
    _imageScrollView.showsHorizontalScrollIndicator = NO;
    _imageScrollView.showsVerticalScrollIndicator = NO;
    _imageScrollView.scrollEnabled = YES;
    _imageScrollView.pagingEnabled = NO;
    _imageScrollView.delegate = self;
    _imageScrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight - 150.0f);
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _imageScrollView.width, _imageScrollView.height)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = self.image;
    [_imageScrollView addSubview:_imageView];
    
    [self.view addSubview:_imageScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return _imageView;
}


@end
