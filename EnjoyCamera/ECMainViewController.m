//
//  ECMainViewController.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "ECMainViewController.h"
#import "QMDragView.h"

@interface ECMainViewController ()

@end

@implementation ECMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor greenColor]];
    
    QMDragView *drag = [[QMDragView alloc] initWithFrame:self.view.bounds image:[UIImage imageNamed:@"Love140"]];
    [drag hideToolBar];
    [drag showToolBar];
    [self.view addSubview:drag];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]];
//        //cropViewController.delegate = self;
//        [self presentViewController:cropViewController animated:YES completion:nil];
//    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


@end
