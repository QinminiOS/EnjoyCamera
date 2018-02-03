//
//  QMCameraFlashSuspensionView.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/10.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMCameraFlashSuspensionView.h"
#import <ReactiveObjC.h>

#define kCameraRatioSuspensionViewHeight   50
#define kCameraRatioSuspensionViewMargin   11

NSString * const FlashConfigJson = @"[{\"name\":\"闪光灯关闭\",\"icon\":\"qmkit_no_flash_btn\",\"type\":1},{\"name\":\"自动闪关灯\",\"icon\":\"qmkit_auto_flash_btn\",\"type\":2},{\"name\":\"闪光灯开启\",\"icon\":\"qmkit_always_flash_btn\",\"type\":3},{\"name\":\"手电筒\",\"icon\":\"qmkit_torch_flash_btn\",\"type\":4}]";

@implementation QMCameraFlashSuspensionView

+ (instancetype)flashSuspensionView
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect rect = CGRectMake(kCameraRatioSuspensionViewMargin, 0, size.width - 2*kCameraRatioSuspensionViewMargin, kCameraRatioSuspensionViewHeight);
    QMCameraFlashSuspensionView *view = [[QMCameraFlashSuspensionView alloc] initWithFrame:rect];
    view.suspensionModels = [QMSuspensionModel buildSuspensionModelsWithJson:FlashConfigJson];
    view.hidden = YES;
    
    @weakify(view);
    [view setSuspensionItemClickBlock:^(QMSuspensionModel *item) {
        @strongify(view);
        [view hide];
        if (view.flashCallBack) {
            AVCaptureFlashMode flash = AVCaptureFlashModeOff;
            AVCaptureTorchMode torch = AVCaptureTorchModeOff;
            switch (item.type) {
                case QMFlashTypeNone:
                    flash = AVCaptureFlashModeOff;
                    break;
                case QMFlashTypeAuto:
                    flash = AVCaptureFlashModeAuto;
                    break;
                case QMFlashTypeAlways:
                    flash = AVCaptureFlashModeOn;
                    break;
                case QMFlashTypeTorch:
                    torch = AVCaptureTorchModeOn;
                    break;
                default:
                    break;
            }
            view.flashCallBack(flash, torch, item.icon);
        }
    }];
    
    return view;
}

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60,self.frame.size.height-20);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    return layout;
}

@end
