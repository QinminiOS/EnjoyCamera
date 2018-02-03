//
//  QMShareManager.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/8/23.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMShareManager.h"
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UMSocialUIManager.h>
#import "Constants.h"

@implementation QMShareManager

+ (void)shareThumbImage:(UIImage *)image inViewController:(UIViewController *)controller
{
    __weak typeof(controller) wcontroller = controller;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        [self shareInViewController:wcontroller platformType:platformType thumbImage:image];
    }];
}

+ (void)shareInViewController:(UIViewController *)controller
                 platformType:(UMSocialPlatformType)platformType
                   thumbImage:(UIImage *)thumbImage
{
        //创建分享消息对象
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
        //创建内容对象
        UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:@"图片来自乐享相机" descr:@"欢迎使用乐享相机，拍出最美的你！" thumImage:nil];
        shareObject.shareImage = thumbImage;
    
        //分享消息对象设置分享内容对象
        messageObject.shareObject = shareObject;
    
        //调用分享接口
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:controller completion:^(id data, NSError *error) {
            if (error) {
                UMSocialLogInfo(@"************Share fail with error %@*********",error);
            }else{
                if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                    UMSocialShareResponse *resp = data;
                    //分享结果消息
                    UMSocialLogInfo(@"response message is %@",resp.message);
                    //第三方原始返回的数据
                    UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
    
                }else{
                    UMSocialLogInfo(@"response data is %@",data);
                }
            }
        }];
}
@end
