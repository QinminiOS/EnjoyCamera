//
//  RTImagePickerNavigationController.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/22/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTImagePickerNavigationController.h"

@interface RTImagePickerNavigationController ()

@end

@implementation RTImagePickerNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupToolBarView:(RTImagePickerToolbarView *)toolBarView
{
    self.toolBarView = (RTImagePickerToolbarView *)toolBarView;
    [self.view addSubview:_toolBarView];
}


@end
