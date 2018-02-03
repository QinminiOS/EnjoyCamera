//
//  RTShortVideoViewController.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/23/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTShortVideoViewController.h"
#import "LLSimpleCamera.h"
#import "RTImagePickerUnauthorizedView.h"
#import "UIView+Geometry.h"
#import "RTImagePickerNavigationController.h"
#import "VIMVideoPlayerView.h"
#import "VIMVideoPlayer.h"

@interface RTShortVideoViewController () <VIMVideoPlayerViewDelegate>
{
    CGFloat button_width;
    CGFloat max_videoLength;
    
    NSTimer *timer;
    
    CGFloat seconds;
    
    NSURL *videoURL;
    NSString *videoFileName;

    CGFloat time;
}

@property (nonatomic, strong) LLSimpleCamera *camera;
@property (nonatomic, strong) RTImagePickerUnauthorizedView *unAuthorizedView;

@property (nonatomic, strong) VIMVideoPlayerView *playerView;

@property (nonatomic, strong) UIView *bottomBarView;
@property (nonatomic, strong) UIView *progressBarView;

@property (nonatomic, strong) UILabel *alertLabel;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *snapButton;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) UIImage *captureImage;

@end

@implementation RTShortVideoViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [UIView animateWithDuration:0.3f animations:^{
        [(RTImagePickerNavigationController *)self.navigationController toolBarView].top = ScreenHeight;
        self.bottomBarView.top = self.navigationController.view.height - self.bottomBarView.height;
    } completion:^(BOOL finished) {
        
    }];
    
    [self.camera start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    [UIView animateWithDuration:0.3f animations:^{
        [(RTImagePickerNavigationController *)self.navigationController toolBarView].top = ScreenHeight - [(RTImagePickerNavigationController *)self.navigationController toolBarView].height;
        self.bottomBarView.top = self.navigationController.view.height;
    } completion:^(BOOL finished) {
        [self.bottomBarView removeFromSuperview];
    }];
    
    [self.camera stop];
    [self.playerView.player reset];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self.playerView.player pause];
    time = [self.playerView.player.player currentTime].value;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self.playerView.player seekToTime:time];
    [self.playerView.player play];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // Register application notification observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    button_width = 46.0f;
    max_videoLength = 20.0f;
    seconds = 0.0f;
    videoURL = [NSURL URLWithString:@""];
    
    self.playerView = [[VIMVideoPlayerView alloc] initWithFrame:CGRectMake(0, 150.0f, screenRect.size.width, screenRect.size.height - 300.0f)];
    self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.playerView.delegate = self;
    [self.playerView.player setMuted:NO];
    [self.playerView.player setVolume:1.0f];
    
    [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
    
    self.playerView.hidden = YES;
    [self.view addSubview:self.playerView];
    
    [self initSubViews];
    
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetMedium
                                                 position:LLCameraPositionRear
                                             videoEnabled:YES];
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 150.0f, screenRect.size.width, screenRect.size.height - 300.0f)];
    
    self.camera.fixOrientationAfterCapture = NO;
    [self.camera updateFlashMode:LLCameraFlashOff];
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        [weakSelf UnAuthorizedViewHidden:YES];
        NSLog(@"Device changed.");
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission) {
                [weakSelf UnAuthorizedViewHidden:NO];
                weakSelf.unAuthorizedView.permissionTitleLabel.text = @"您关闭了您的相机权限";
            } else if(error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                [weakSelf UnAuthorizedViewHidden:NO];
                weakSelf.unAuthorizedView.permissionTitleLabel.text = @"您关闭了您的麦克风权限";
            }
        }
    }];

    self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    
    // Do any additional setup after loading the view.
}

- (void)initSubViews
{
    self.bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.navigationController.view.height, self.navigationController.view.width, 150.0f)];
    _bottomBarView.backgroundColor = [UIColor blackColor];
    [self.navigationController.view addSubview:_bottomBarView];
    
    self.alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, _bottomBarView.height/2.0f - 55.0f, ScreenWidth, 20.0f)];
    _alertLabel.font = [UIFont systemFontOfSize:13.0f];
    _alertLabel.textColor = [UIColor whiteColor];
    _alertLabel.textAlignment = NSTextAlignmentCenter;
    _alertLabel.text = @"长按录制小视频";
    [_bottomBarView addSubview:_alertLabel];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(38.0f, _bottomBarView.height/2.0f, button_width, button_width)];
    [_cancelButton setImage:[UIImage imageNamed:@"rtimagepicker_cancel"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBarView addSubview:_cancelButton];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(_bottomBarView.width - 38.0f - button_width, _cancelButton.top, button_width, button_width)];
    [_sendButton setImage:[UIImage imageNamed:@"rtimagepicker_send"] forState:UIControlStateNormal];
    [_sendButton setImage:[UIImage imageNamed:@"rtimagepicker_send_unselected"] forState:UIControlStateDisabled];
    [_sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _sendButton.enabled = NO;
    [_bottomBarView addSubview:_sendButton];
    
    CGFloat snapButtonHeight = 75.0f;
    self.snapButton = [[UIView alloc] initWithFrame:CGRectMake((_bottomBarView.width - snapButtonHeight)/2.0f, _cancelButton.top - 20.0f, snapButtonHeight, snapButtonHeight)];
    _snapButton.backgroundColor = [UIColor whiteColor];
    _snapButton.layer.cornerRadius = snapButtonHeight/2.0f;
    
    UILongPressGestureRecognizer *snapLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(snapButtonPressed:)];
    [_snapButton addGestureRecognizer:snapLongPress];
    
    [_bottomBarView addSubview:_snapButton];
    
    self.progressBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 147.0f, 0.0f, 3.0f)];
    _progressBarView.backgroundColor = [UIColor colorWithRed:80/255.0f green:227/255.0f blue:194/255.0f alpha:1.0f];
    
    UIView *pointerView = [[UIView alloc] initWithFrame:CGRectMake((3.0f/max_videoLength) * self.view.width - 2.0f, 0.0, 2.0, 3.0f)];
    pointerView.backgroundColor = [UIColor whiteColor];
    [_progressBarView addSubview:pointerView];
    
    [self.view addSubview:_progressBarView];
}

#pragma mark - Actions

- (void)sendButtonPressed:(id)sender
{
    [self.camera stop];
    [self.playerView.player reset];
    [[(RTImagePickerNavigationController *)self.navigationController toolBarView] didSelectVideoWithFileName:videoFileName captureImage:self.captureImage];}

- (void)cancelButtonPressed:(id)sender
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)snapButtonPressed:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerRefresh) userInfo:nil repeats:YES];//[NSTimer timerWithTimeInterval:0.1f target:self selector:@selector(timerRefresh) userInfo:nil repeats:YES];
            //[timer fire];
            [UIView animateWithDuration:0.3f animations:^{
                _snapButton.backgroundColor = [UIColor colorWithRed:80/255.0f green:227/255.0f blue:194/255.0f alpha:1.0f];
            }];
            
            seconds = 0.0f;
            [self triggerBeginRecord];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            if(timer) [timer invalidate];
            timer = nil;
            [UIView animateWithDuration:0.3f animations:^{
                _snapButton.backgroundColor = [UIColor whiteColor];
            }];
            [self triggerEndRecord];
        }
            break;
        default:
        {
            // reset timer and UI
            if(timer) [timer invalidate];
            timer = nil;
            [UIView animateWithDuration:0.3f animations:^{
                _snapButton.backgroundColor = [UIColor whiteColor];
            }];
            [self triggerEndRecord];
        }
            break;
    }
}

#pragma mark - Timer Action

- (void)timerRefresh
{
    if(seconds > 20.0f) {
        if(timer) [timer invalidate];
        timer = nil;
        [UIView animateWithDuration:0.3f animations:^{
            _snapButton.backgroundColor = [UIColor whiteColor];
        }];
        [self triggerEndRecord];
        return;
    }
    seconds += 0.1f;
    [UIView animateWithDuration:0.09f animations:^{
        _progressBarView.width = (seconds / max_videoLength) * ScreenWidth;
    }];
}

#pragma mark - Record control Actions

- (void)triggerBeginRecord
{
    _sendButton.enabled = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.alertLabel.alpha = 0.0f;
        self.playerView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.playerView.player pause];
        self.playerView.hidden = YES;
    }];
    
    if(!self.camera.isRecording) {
        
        NSInteger timestamp = [NSDate timeIntervalSinceReferenceDate];
        
        // start recording
        NSString *fileName = [NSString stringWithFormat:@"%ld",timestamp];
        NSURL *outputURL = [[[self applicationDocumentsDirectory]
                             URLByAppendingPathComponent:fileName] URLByAppendingPathExtension:@"mp4"];
        videoFileName = [NSString stringWithFormat:@"%@.mp4",fileName];
        
        [self.camera startRecordingWithOutputUrl:outputURL];
    }
}

- (void)triggerEndRecord
{
     if(self.camera.isRecording)  {
        [self.camera stopRecording:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
            
            if(seconds <= 3.0f) {
                // Less than 3 seconds
                seconds = 0.0f;
                self.sendButton.enabled = NO;
                self.progressBarView.width = 0.0f;
                [self setAlertTitle:@"录制时间不能小于3秒"];
            } else {
                seconds = 0.0f;
                self.sendButton.enabled = YES;
                if(error == nil) {
                    videoURL = outputFileUrl;
                    self.playerView.hidden = NO;
                    self.playerView.alpha = 1.0f;
                    [self.view bringSubviewToFront:self.playerView];
                    
                    [self.playerView.player setURL:videoURL];
                    [self.playerView.player play];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        self.captureImage = [self thumbnailImageForVideo:videoURL];
                    });
                } else {
                    NSLog(@"fuck error with short video :%@",error);
                }
            }
        }];
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)UnAuthorizedViewHidden:(BOOL)hidden
{
    if(!self.unAuthorizedView) {
        self.unAuthorizedView = [[RTImagePickerUnauthorizedView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, ScreenWidth, ScreenHeight - 150.0f)];
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

- (void)videoPlayerViewDidReachEnd:(VIMVideoPlayerView *)videoPlayerView
{
    [videoPlayerView.player seekToTime:0.0f];
    [videoPlayerView.player play];
}

- (void)setAlertTitle:(NSString *)alertTitle
{
    self.alertLabel.alpha = 0.0f;
    self.alertLabel.text = alertTitle;
    [UIView animateWithDuration:0.3f animations:^{
        self.alertLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f delay:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.alertLabel.alpha = 0.0f;
        } completion:^(BOOL finished) {
        }];
    }];
}

- (UIImage*) thumbnailImageForVideo:(NSURL *)t_videoURL{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:t_videoURL options:nil];
    if(!asset) {
        return nil;
    }
    
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = 0.1f;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    return thumbnailImage;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
