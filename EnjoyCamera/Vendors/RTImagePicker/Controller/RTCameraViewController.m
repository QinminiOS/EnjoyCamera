//
//  RTCameraViewController.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/22/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTCameraViewController.h"
#import "RTCameraPreviewViewController.h"
#import "RTImagePickerNavigationController.h"
#import "RTImagePickerUnauthorizedView.h"

@interface RTCameraViewController ()

@property (strong, nonatomic) LLSimpleCamera *camera;
@property (nonatomic, weak) RTImagePickerToolbarView *rt_toolbarView;
@property (nonatomic, strong) RTImagePickerUnauthorizedView *unAuthorizedView;

@end

@implementation RTCameraViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionRear
                                             videoEnabled:NO];
    
    self.rt_toolbarView = [(RTImagePickerNavigationController *)self.navigationController toolBarView];
    [_rt_toolbarView.cameraFlashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_rt_toolbarView.cameraSwitchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_rt_toolbarView.cameraSnapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 150.0f)];
    
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = NO;
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        
        [weakSelf UnAuthorizedViewHidden:YES];
        NSLog(@"Device changed.");
        if(weakSelf.rt_toolbarView) {
            // device changed, check if flash is available
            if([camera isFlashAvailable]) {
                // show the flash button here
                [weakSelf.rt_toolbarView setFlashEnabled:YES];
                if(camera.flash == LLCameraFlashOff) {
                    // turn off the flash button
                    [weakSelf.rt_toolbarView setFlashState:NO];
                } else {
                    // turn on the flash button
                    [weakSelf.rt_toolbarView setFlashState:YES];
                }
            } else {
                // hide the flash button here
                [weakSelf.rt_toolbarView setFlashEnabled:NO];
            }
        }
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission ||
               error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                [weakSelf UnAuthorizedViewHidden:NO];
            }
        }
    }];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([(RTImagePickerNavigationController *)self.navigationController toolBarView]) {
        [[(RTImagePickerNavigationController *)self.navigationController toolBarView] SwitchToMode:RTImagePickerToolbarModeCamera];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.camera start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.camera stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)switchButtonPressed:(id)sender
{
    [self.camera togglePosition];
}

- (void)flashButtonPressed:(id)sender
{
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            [_rt_toolbarView setFlashState:YES];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            [_rt_toolbarView setFlashState:NO];
        }
    }
}

- (void)snapButtonPressed:(id)sender
{
    [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            
            // We should stop the camera, we are opening a new vc, thus we don't need it anymore.
            // This is important, otherwise you may experience memory crashes.
            // Camera is started again at viewWillAppear after the user comes back to this view.
            // I put the delay, because in iOS9 the shutter sound gets interrupted if we call it directly.
            
            [camera performSelector:@selector(stop) withObject:nil afterDelay:0.2];
            RTCameraPreviewViewController *vc = [[RTCameraPreviewViewController alloc]initWithImage:image];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

- (void)UnAuthorizedViewHidden:(BOOL)hidden
{
    if(!self.unAuthorizedView) {
        self.unAuthorizedView = [[RTImagePickerUnauthorizedView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, ScreenWidth, ScreenHeight - [(RTImagePickerNavigationController *)self.navigationController toolBarView].height)];
        _unAuthorizedView.permissionTitleLabel.text = @"Flow想开启你的相机";
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
