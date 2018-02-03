//
//  QMDBManager.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/3.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMDBManager.h"

@implementation QMDBManager

+ (instancetype)shareManager
{
    static QMDBManager *sManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sManager = [[self alloc] init];
    });
    return sManager;
}

@end
