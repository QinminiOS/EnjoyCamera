//
//  QMFilterModel.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/8/21.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMFilterModel.h"

#define kFilterShaderDefaultAlphaValue 0.6f

@implementation QMFilterModel

 + (QMFilterModel *)buildFilterModelWithFilterPath:(NSString *)filter
{
    // filterPath
    NSString *currentFolder = filter;
    
    // config
    NSString *config = [currentFolder stringByAppendingPathComponent:@"config.json"];
    NSData *configData = [NSData dataWithContentsOfFile:config];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingMutableContainers error:nil];
    if (!dict) {
        return nil;
    }
    
    // model
    QMFilterModel *model = [[QMFilterModel alloc] init];
    model.enName = [[currentFolder lastPathComponent] lowercaseString];
    model.name = dict[@"name"];
    model.fragmentShader = [currentFolder stringByAppendingPathComponent:dict[@"fragment"]];
    model.icon = [currentFolder stringByAppendingPathComponent:dict[@"icon"]];
    model.currentAlphaValue = kFilterShaderDefaultAlphaValue;
    NSMutableArray *imageArray = [NSMutableArray array];
    for (NSString *image in dict[@"images"]) {
        [imageArray addObject:[currentFolder stringByAppendingPathComponent:image]];
    }
    model.textureImages = imageArray;
    
    return model;
}

+ (NSArray<QMFilterModel *> *)buildFilterModelsWithPath:(NSString *)folder
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
        return nil;
    }
    
    NSMutableArray<QMFilterModel *> *filters = [NSMutableArray array];
    NSArray<NSString *> *filterFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
    
    for (NSString *filter in filterFolder) {
        NSString *currentFolder = [folder stringByAppendingPathComponent:filter];
        // build
        QMFilterModel *model = [self buildFilterModelWithFilterPath:currentFolder];
        
         // add
        if (model) {
            [filters addObject:model];
        }
    }
    
    return filters;
}
@end
