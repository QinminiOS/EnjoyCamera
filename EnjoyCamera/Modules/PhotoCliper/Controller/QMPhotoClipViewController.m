//
//  QMPhotoClipViewController.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/26.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMPhotoClipViewController.h"
#import "Constants.h"
#import "UIColor+Additions.h"
#import <Masonry.h>

@interface QMPhotoClipViewController ()
//@property (nonatomic, strong) dispatch_queue_t imageProcessQueue;
@property (nonatomic, assign) CGPoint offsetPoint;
@property (nonatomic, assign) CGPoint currentPoint;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *leftMaskView;
@property (nonatomic, strong) UIView *topMaskView;
@property (nonatomic, strong) UIView *rightMaskView;
@property (nonatomic, strong) UIView *bottomMaskView;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *scaleButton;
@property (nonatomic, strong) UIButton *rotateButton;
@property (nonatomic, strong) UIButton *finishButton;
@end

@implementation QMPhotoClipViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self setupGesture];
    //[self setupImageProcessQueue];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - SETUP
- (void)setupUI
{
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    // 图像
    CGRect rect = self.view.bounds;
    _currentPoint = rect.origin;
    _imageView = [[UIImageView alloc] initWithFrame:rect];
    _imageView.image = _image;
    [self.view addSubview:_imageView];

    // 上遮罩
    _topMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    _topMaskView.backgroundColor = [UIColor blackColor];
    _topMaskView.layer.opacity = 0.5;
    [self.view addSubview:_topMaskView];
    [_topMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
    // 下遮罩
    _bottomMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomMaskView.backgroundColor = [UIColor blackColor];
    _bottomMaskView.layer.opacity = 0.5;
    [self.view addSubview:_bottomMaskView];
    [_bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(100);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    // 左遮罩
    _leftMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    _leftMaskView.backgroundColor = [UIColor blackColor];
    _leftMaskView.layer.opacity = 0.5;
    [self.view addSubview:_leftMaskView];
    [_leftMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.equalTo(_topMaskView.mas_bottom);
        make.width.mas_equalTo(50);
        make.bottom.mas_equalTo(_bottomMaskView.mas_top);
    }];
    
    // 右遮罩
    _rightMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    _rightMaskView.backgroundColor = [UIColor blackColor];
    _rightMaskView.layer.opacity = 0.5;
    [self.view addSubview:_rightMaskView];
    [_rightMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.width.mas_equalTo(50);
        make.top.equalTo(_topMaskView.mas_bottom);
        make.bottom.mas_equalTo(_bottomMaskView.mas_top);
    }];
    
    // 底部背景
    UIView *bottomBg = [[UIView alloc] initWithFrame:CGRectZero];
    bottomBg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomBg];
    [bottomBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.width.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    
    // 取消按钮
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor colorWithRGBHex:0x63dab9] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomBg.mas_centerY);
        make.centerX.equalTo(self.view.mas_left).offset(self.view.bounds.size.width/8);
    }];
    
    // 尺寸按钮
    _scaleButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_scaleButton setTitle:@"3:4" forState:UIControlStateNormal];
    [_scaleButton setTitleColor:[UIColor colorWithRGBHex:0x63dab9] forState:UIControlStateNormal];
    [_scaleButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_scaleButton];
    [_scaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomBg.mas_centerY);
        make.centerX.equalTo(self.view.mas_left).offset(self.view.bounds.size.width*3/8);
    }];
    
    // 旋转按钮
    _rotateButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_rotateButton setTitle:@"旋转" forState:UIControlStateNormal];
    [_rotateButton setTitleColor:[UIColor colorWithRGBHex:0x63dab9] forState:UIControlStateNormal];
    [_rotateButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rotateButton];
    [_rotateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomBg.mas_centerY);
        make.centerX.equalTo(self.view.mas_left).offset(self.view.bounds.size.width*5/8);
    }];
    
    // 完成按钮
    _finishButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [_finishButton setTitleColor:[UIColor colorWithRGBHex:0x63dab9] forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_finishButton];
    [_finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomBg.mas_centerY);
        make.centerX.equalTo(self.view.mas_left).offset(self.view.bounds.size.width*7/8);
    }];
}

- (void)setupGesture
{
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    gesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:gesture];
}

//- (void)setupImageProcessQueue
//{
//    _imageProcessQueue = dispatch_queue_create("com.qm.imageprocess", NULL);
//}

#pragma mark - Events
- (void)buttonTapped:(UIButton *)sender
{
    if (_cancelButton == sender) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }else if (_scaleButton == sender) {
        [self scaleImage];
    }else if (_rotateButton == sender) {
        [self rotateImage];
    }else if (_finishButton == sender) {
        [self dismissViewControllerAnimated:YES completion:NULL];
        if (_completionBlock) {
            _completionBlock(_image, CGSizeZero, M_PI_2);
        }
    }
}

#pragma mark - Touch
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [gesture locationInView:self.view];
        _offsetPoint = CGPointMake(location.x - _currentPoint.x, location.y - _currentPoint.y);
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [gesture locationInView:self.view];
        _currentPoint = CGPointMake(location.x - _offsetPoint.x, location.y - _offsetPoint.y);
        
        CGRect rect = _imageView.frame;
        rect.origin = _currentPoint;
        _imageView.frame = rect;
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGRect maskRect = CGRectMake(50, 100, self.view.bounds.size.width-50*2, self.view.bounds.size.height-100*2);
        CGRect imageRect = _imageView.frame;
        if (maskRect.origin.x <= imageRect.origin.x && maskRect.origin.y <= imageRect.origin.y) {
            [UIView animateWithDuration:0.4 animations:^{
                CGRect rect = _imageView.frame;
                rect.origin = maskRect.origin;
                _imageView.frame = rect;
            } completion:^(BOOL finished) {
                _currentPoint = _imageView.frame.origin;
            }];
        }else if (maskRect.origin.x + maskRect.size.width >= imageRect.size.width + imageRect.origin.x && maskRect.origin.y <= imageRect.origin.y) {
            CGFloat x = maskRect.origin.x + maskRect.size.width - _imageView.bounds.size.width;
            [UIView animateWithDuration:0.4 animations:^{
                CGRect rect = _imageView.frame;
                rect.origin = maskRect.origin;
                rect.origin.x = x;
                _imageView.frame = rect;
            } completion:^(BOOL finished) {
                _currentPoint = _imageView.frame.origin;
            }];
        }else if (maskRect.origin.x <= imageRect.origin.x && maskRect.origin.y + maskRect.size.height >= imageRect.origin.y + imageRect.size.height) {
            CGFloat y = maskRect.origin.y + maskRect.size.height - _imageView.bounds.size.height;
            [UIView animateWithDuration:0.4 animations:^{
                CGRect rect = _imageView.frame;
                rect.origin = maskRect.origin;
                rect.origin.y = y;
                _imageView.frame = rect;
            } completion:^(BOOL finished) {
                _currentPoint = _imageView.frame.origin;
            }];
        }else if (maskRect.origin.x + maskRect.size.width >= imageRect.size.width + imageRect.origin.x && maskRect.origin.y + maskRect.size.height >= imageRect.origin.y + imageRect.size.height) {
            CGFloat x = maskRect.origin.x + maskRect.size.width - _imageView.bounds.size.width;
            CGFloat y = maskRect.origin.y + maskRect.size.height - _imageView.bounds.size.height;
            [UIView animateWithDuration:0.4 animations:^{
                CGRect rect = _imageView.frame;
                rect.origin.x = x;
                rect.origin.y = y;
                _imageView.frame = rect;
            } completion:^(BOOL finished) {
                _currentPoint = _imageView.frame.origin;
            }];
        }else if (maskRect.origin.x <= imageRect.origin.x) {
            [UIView animateWithDuration:0.4 animations:^{
                CGRect rect = _imageView.frame;
                rect.origin.x = maskRect.origin.x;
                _imageView.frame = rect;
            } completion:^(BOOL finished) {
                _currentPoint = _imageView.frame.origin;
            }];
        }else if (maskRect.origin.x + maskRect.size.width >= imageRect.size.width + imageRect.origin.x ) {
            CGFloat x = maskRect.origin.x + maskRect.size.width - _imageView.bounds.size.width;
            [UIView animateWithDuration:0.4 animations:^{
                CGRect rect = _imageView.frame;
                rect.origin.x = x;
                _imageView.frame = rect;
            } completion:^(BOOL finished) {
                _currentPoint = _imageView.frame.origin;
            }];
        }else if (maskRect.origin.y <= imageRect.origin.y) {
            [UIView animateWithDuration:0.4 animations:^{
                CGRect rect = _imageView.frame;
                rect.origin.y = maskRect.origin.y;
                _imageView.frame = rect;
            } completion:^(BOOL finished) {
                _currentPoint = _imageView.frame.origin;
            }];
        }else if (maskRect.origin.y + maskRect.size.height >= imageRect.size.height + imageRect.origin.y ) {
            CGFloat y = maskRect.origin.y + maskRect.size.height - _imageView.bounds.size.height;
            [UIView animateWithDuration:0.4 animations:^{
                CGRect rect = _imageView.frame;
                rect.origin.y = y;
                _imageView.frame = rect;
            } completion:^(BOOL finished) {
                _currentPoint = _imageView.frame.origin;
            }];
        }
        
    }
}

//- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
//{
//    if (gesture.state == UIGestureRecognizerStateBegan) {
//        CGPoint location = [gesture locationInView:self.view];
//        CGPoint current = CGPointMake(location.x, self.view.bounds.size.height - location.y);
//        _offsetPoint = CGPointMake(current.x - _currentPoint.x, current.y - _currentPoint.y);
//    }else if (gesture.state == UIGestureRecognizerStateChanged) {
//        CGPoint location = [gesture locationInView:self.view];
//        CGPoint current = CGPointMake(location.x, self.view.bounds.size.height - location.y);
//        _currentPoint = CGPointMake(current.x - _offsetPoint.x, current.y - _offsetPoint.y);
//        dispatch_async(_imageProcessQueue, ^{
//            UIImage *image = [self draw];
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                self.view.layer.contents = (id)image.CGImage;
//            });
//        });
//    }
//}

#pragma mark - Private
- (void)rotateImage
{
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_2);
}

- (void)scaleImage
{
    
}

#pragma mark - DRAW
//- (UIImage *)draw
//{
//    UIGraphicsBeginImageContext(self.view.bounds.size);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//
//    // 坐标变换
//    CGContextTranslateCTM(ctx, 0, self.view.bounds.size.height);
//    CGContextScaleCTM(ctx, 1.0, -1.0);
//    
//    // 图像
//    CGRect rect = CGRectMake(_currentPoint.x, _currentPoint.y, self.view.bounds.size.width, self.view.bounds.size.height);
//    CGContextDrawImage(ctx, rect, _image.CGImage);
//    
//    // alpha
//    CGContextSetAlpha(ctx, 0.6);
//    
//    // 黑布
//    [[UIColor blackColor] setFill];
//    CGContextFillRect(ctx, self.view.bounds);
//    
////    // 选择框
////    CGContextSetLineWidth(ctx, 1.0);
////    [[UIColor whiteColor] setStroke];
////    CGContextStrokeRect(ctx, CGRectMake(50, 100, self.view.bounds.size.width - 100, self.view.bounds.size.height - 200));
//    
//    // 混合部分
//    [[UIColor whiteColor] setFill];
//    CGContextSetBlendMode(ctx, kCGBlendModePlusLighter);
//    CGContextFillRect(ctx, CGRectMake(50, 100, self.view.bounds.size.width - 100, self.view.bounds.size.height - 200));
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//}

//- (void)setImage:(UIImage *)image
//{
//    _image = image;
//    self.view.layer.contents = (id)[self draw].CGImage;
//}

@end
