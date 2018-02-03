//
//  QMSettingModel.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/3.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QMSettingType) {
    QMSettingTypeSwitch = 1,
    QMSettingTypeLink = 2
};

@interface QMSettingModel : NSObject
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) QMSettingType settingType;
@property (nonatomic, assign) BOOL switchOn;
@property (nonatomic, assign) NSString *link;

+ (NSDictionary<NSNumber *, NSArray<QMSettingModel *> *> *)buildSettingModels;
@end
