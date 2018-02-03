//
//  QMCropModel.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/9/5.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

@interface QMCropModel : NSObject<YYModel>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, assign) NSInteger type;
+ (NSArray<QMCropModel *> *)buildCropModels;
@end
