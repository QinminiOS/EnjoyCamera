//
//  AppDelegate.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "AppDelegate.h"
#import "ECMainViewController.h"
#import "QMCameraViewController.h"
#import "QMPhotoClipViewController.h"
#import "QMBaseNavigationController.h"
#import <UMSocialCore/UMSocialCore.h>
#import "QMPhotoEffectViewController.h"
#import "ECMainViewController.h"
#import "QMPhotoDisplayViewController.h"
#import <Bugly/Bugly.h>
#import <UMMobClick/MobClick.h>

#define kUmengAPPKey @"57d4c98fe0f55ad429000376"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] openLog:YES];
    [[UMSocialManager defaultManager] setUmSocialAppkey:kUmengAPPKey];
    [self configUSharePlatforms];
    
    // 统计
    UMConfigInstance.appKey = kUmengAPPKey;
    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
    
    // Bugly
    [self setupBugly];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    QMCameraViewController *mainVC = [[QMCameraViewController alloc] init];
    QMBaseNavigationController *navVC = [[QMBaseNavigationController alloc] initWithRootViewController:mainVC];
    
//    QMPhotoEffectViewController *mainVC = [[QMPhotoEffectViewController alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]];
//    QMBaseNavigationController *navVC = [[QMBaseNavigationController alloc] initWithRootViewController:mainVC];
//    mainVC.navigationController.navigationBarHidden = YES;

    //Test
//    ECMainViewController *mainVC = [[ECMainViewController alloc] init];
//    QMBaseNavigationController *navVC = [[QMBaseNavigationController alloc] initWithRootViewController:mainVC];
//    mainVC.navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = navVC;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 支持所有iOS系统
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

#pragma mark - PrivateMethod
- (void)configUSharePlatforms
{
    /*
     设置微信的appKey和appSecret
     [微信平台从U-Share 4/5升级说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_1
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession
                                          appKey:@"wx9cf791d66b467674"
                                       appSecret:@"c31e2de9806530618f2e9b5542a1cae4"
                                     redirectURL:nil];
   
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     100424468.no permission of union id
     [QQ/QZone平台集成说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_3
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ
                                          appKey:@"1106419235"/*设置QQ平台的appID*/
                                       appSecret:nil
                                     redirectURL:@"http://mobile.umeng.com/social"];
}

- (void)setupBugly
{
    // Get the default config
    BuglyConfig * config = [[BuglyConfig alloc] init];
    
#if DEBUG
    config.debugMode = YES;
#endif
    
    // Default value is NO
    config.blockMonitorEnable = YES;
    
    // Set the STUCK THRESHOLD time, when STUCK time > THRESHOLD it will record an event and report data when the app launched next time.
    // Default value is 3.5 second.
    config.blockMonitorTimeout = 1.5;
    
    // Set the app channel to deployment
    config.channel = @"AppStore";
    
    config.consolelogEnable = NO;
    config.viewControllerTrackingEnable = NO;
    
    // Start the Bugly sdk with APP_ID and your config
    [Bugly startWithAppId:@"d31a6091d0" config:config];
}

@end
