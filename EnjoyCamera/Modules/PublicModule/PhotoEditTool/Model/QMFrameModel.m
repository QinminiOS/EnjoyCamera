//
//  QMFrameModel.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/19.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMFrameModel.h"
#import <YYModel.h>

@implementation QMFrameModel

+ (NSArray<QMFrameModel *> *)buildFrameModels
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"frame" ofType:@"geojson"];
    NSData *jsonConfig = [NSData dataWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonConfig options:NSJSONReadingMutableContainers error:nil];
    if (!array) {
        return nil;
    }
    
    NSMutableArray *framesArr = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        QMFrameModel *model = [QMFrameModel yy_modelWithDictionary:dict];
        if (model) {
            [framesArr addObject:model];
        }
    }
    return framesArr;
}


@end
