//
//  QMSettingModel.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/3.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMSettingModel.h"
#import <YYModel.h>

@implementation QMSettingModel

+ (NSDictionary<NSNumber *,NSArray<QMSettingModel *> *> *)buildSettingModels
{
    NSMutableDictionary<NSNumber *, id> *settingModels = [NSMutableDictionary dictionary];
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"setting.geojson" ofType:nil]];
    NSArray *settingArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSInteger index = 0;
    for (NSArray *dictArr in settingArr) {
        NSMutableArray *settingGroupModels = [NSMutableArray array];
        for (NSDictionary *dict in dictArr) {
            QMSettingModel *model = [QMSettingModel yy_modelWithJSON:dict];
            [settingGroupModels addObject:model];
        }
        settingModels[@(index)] = settingGroupModels;
        index++;
    }
    
    return settingModels;
}

@end
